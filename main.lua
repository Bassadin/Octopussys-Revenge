--Libraries:	
	
	require("Libraries.AnAL") --Initialisiert AnAL
	
	gwee = require ("Libraries.gwee") --Initialisiert Gwee
	
	highscore = require ("Libraries.sick") --Initialisiert SICK
	
	require ("Libraries.TSerial") --Initialisiert TSerial
	
	
	--Load other Lua's
		require "lua/intro"
	
	
	--Shortcuts
		lg = love.graphics
		lf = love.filesystem
		lkid = love.keyboard.isDown
		
	--Filesystem		
		pathToAppData = lf.getAppdataDirectory()
		
		--Standart Config-Datei-Table
			defaultConfig = {
			
				soundsVolume = 0.5,
				musicVolume = 0.5,
				musicActivated = true
			
			}
		
		--Config
		
			--Neues Configfile erstellen falls keines existiert
				if lf.exists("config.sav") == false or lkid("p") then
					configFile = love.filesystem.newFile("config.sav")
					configFile:open('w')
					configFile:write(TSerial.pack(defaultConfig))
					configFile:close()
				end
			
			--Configfile laden
				configFile = love.filesystem.newFile("config.sav")
				config = TSerial.unpack(configFile:read())
				configFile:close()
				
				
function love.load()

	--Load other load functions
		intro.load()
	
	--Allgemeine Variablen
		cursorVisible = false
		gameState = "optionsMenu"
		gameActive = false
		versionNumber = "0.5.4"
		
		--[[			
			Gamestates:			
				intro = Destructive Reality Splash Screen
				mainMenu = Hauptmenü ^^
				pauseMenu = Pausenmenü ^^
				game = Im Spiel
				highscores = Highscores :P
				optionsMenu = Optionsmenü
				gameOver = Game Over-Bildschirm
				upgrades = Ingame-Upgrade-Bildschirm				
		--]]
		
		
	--Bildschirm	
		local width, height, fullscreen, vsync, fsaa = love.graphics.getMode()
		
		systemScreen = {
		
			width = width,
			height = height,
			fullscreen = fullscreen,
			vsync = vsync,
			fsaa = fsaa
		
		}
		
		
	--Intro fade
		lg.setColorMode("replace")
		fadeAlpha = 255
		--Intro timer
			timer = 0
		
	--Punkte/Highscore/Geld		
		points = 0
		money = 0
		--SICK
			highscore.set("highscores.txt", 10, "Nobody", 0)
		
		
	--GUI
		--Gwee
			--Hauptmenü
			mainMenu = gwee.Group(gwee.Box(243, 198, 323, 375), gwee.VerticalLayout(38),"", gwee.loadSkin("styles/pauseMenuGweeStyle"))
				mainMenu:add(gwee.Button(function() gameState = "game" end, "Start game"))
				mainMenu:add(gwee.Button(function() gameState = "optionsMenu" end, "Options"))
				mainMenu:add(gwee.Button(function() gameState = "highscores" end, "Highscores"))
				mainMenu:add(gwee.Button(function() love.event.push("quit") end, "Quit"))
				mainMenu.enabled = false
				

			--Pausenmenü
			pauseMenu = gwee.Group(gwee.Box(275, 190, 250, 230), gwee.VerticalLayout(25),"",  gwee.loadSkin("styles/pauseMenuGweeStyle"))
				pauseMenu:add(gwee.Button(function() gameState = "game" end, "Continue"))
				pauseMenu:add(gwee.Button(function() gameState = "optionsMenu" end, "Options"))
				pauseMenu:add(gwee.Button(function()
				
					gameState = "mainMenu"
					gameActive = false 	
				end, "Main Menu"))
				pauseMenu:add(gwee.Button(function() love.event.push('quit') end, "Quit"))
				pauseMenu.enabled = false
				
			--Highscoremenü
			highscoreMenu = gwee.Group(gwee.Box(290, 490, 200, 80), gwee.VerticalLayout(10),"",  gwee.loadSkin("styles/pauseMenuGweeStyle"))
				highscoreMenu:add(gwee.Button(function()
					lf.remove("highscores.txt")
					highscore.set("highscores.txt", 10, "Nobody", 0)
					end, "Reset"))
				highscoreMenu:add(gwee.Button(function() gameState = "mainMenu" end, "Main Menu"))
				highscoreMenu.enabled = false
				
			--Game Over
				--Menü
				gameOverMenu = gwee.Group(gwee.Box(250, 380, 300, 120), gwee.VerticalLayout(20),"",  gwee.loadSkin("styles/pauseMenuGweeStyle"))
					highscoreName = gameOverMenu:add(gwee.TextField(""))
					gameOverMenu:add(gwee.Button(function()
						
						if highscoreName.text ~= "" then
							highscore.add(highscoreName.text, points)
							points = 0
							gameState = "mainMenu" 
						end
							
						end, "Save"))						
					gameOverMenu.enabled = false
	
			--Optionsmenü Sound
			optionsMenuSound = gwee.Group(gwee.Box(120, 260, 300, 190), gwee.VerticalLayout(35), "",  gwee.loadSkin("styles/pauseMenuGweeStyle"))				
				soundsVolume = optionsMenuSound:add(gwee.Slider(0, 1, "Sound Volume"))
					soundsVolume.value = config.soundsVolume
				musicVolume = optionsMenuSound:add(gwee.Slider(0, 1, "Music Volume"))
					musicVolume.value = config.musicVolume
				optionsMenuSound.enabled = false
				
				
			--Optionsmenü Grafik
				optionsMenuGraphics = gwee.Group(gwee.Box(230, 200, 350, 250), gwee.VerticalLayout(35), "",  gwee.loadSkin("styles/pauseMenuGweeStyle"))	
				
				optionsMenuGraphics.enabled = false
				
				
			--Optionsmenü Zurück-Button
				optionsMenuBackButton = gwee.Group(gwee.Box(220, 520, 360, 40), gwee.VerticalLayout(0), "",  gwee.loadSkin("styles/pauseMenuGweeStyle"))
					optionsMenuBackButton:add(gwee.Button(function() 
						if gameActive then 
							gameState = "pauseMenu"
						else gameState = "mainMenu" end
					end, "Back to Main Menu"))
					
				optionsMenuBackButton.enabled = false
			
			
			--Upgrade List Table
				
				upgradeItem = {}
				
					for line in love.filesystem.lines("upgradeList.txt") do
						
						table.insert(upgradeItem, line)
				
					end		
					
					--[[
					
						1 = lmg
						2 = laser
						3 = SIN-Shot
						4 = Mines
					
					]]--
					
					
				weaponLevel = {[1] = 1, [2] = 0, [3] = 0, [4] = 0}	
				weaponDefaultLevel = weaponLevel	
				weaponMaxLevel = {[1] = 5, [2] = 5, [3] = 2, [4] = 3}	

				weaponUpgradePrices = {
								
					[1] = {
					
						[1] = 100,
						[2] = 200,
						[3] = 300,
						[4] = 400,
						[5] = 500
					
					},

					[2] = {
					
						[1] = 100,
						[2] = 200,
						[3] = 300,
						[4] = 600,
						[5] = 900
					
					},

					[3] = {
					
						[1] = 500,
						[2] = 1000
						
					},
					
					[4] = {
					
						[1] = 500,
						[2] = 750,
						[3] = 1000
					
					}
				
				}
				
				upgradeDelayTime = 0
				
				--Rot blinken bei zu wenig Geld / bei maximalem Level
					moneyFontIsRed = false
					moneyFontIsRedTime = 0
					moneyFontIsRedDuration = 1
					
				--Rot blinken bei maximalem Level
					levelFontIsRed = false
					levelFontIsRedTime = 0
					levelFontIsRedDuration = 1
				

	--Hintergrund
		lg.setBackgroundColor(0, 0, 0)
		parallax = 150
		parallax2 = 120
		
		
	--Bilder laden
		lg.setDefaultImageFilter("nearest","nearest")
		--Character		
			syncfighterLMGimg = lg.newImage("gfx/characters/syncfighterLMG.png")
				
			--syncfighterLaser = lg.newImage("gfx/characters/syncfighterLaser.png")
		
		--Bullets
			bullet = lg.newImage("gfx/entities/bullets/Bullet.png")
			SINbullet = lg.newImage("gfx/entities/bullets/SINBullet.png")
			
			slimeBulletIMG = lg.newImage("gfx/entities/bullets/slimeBullet.png")
			octopussyBulletIMG = lg.newImage("gfx/entities/bullets/octopussyBullet.png")
		
		--GUI
			fadenkreuz = lg.newImage("gfx/gui/fadenkreuz.png")	
			
			laser = lg.newImage("gfx/gui/laser.png")
			
			starBackground = lg.newImage("gfx/gui/stars.png")
			
			starBackground2 = lg.newImage("gfx/gui/stars2.png")
			
			highscoresTitleIMG = lg.newImage("gfx/gui/highscores.png")
				highscoresTitleIMG:setFilter("linear", "linear")
				
			mainMenuTitleIMG = lg.newImage("gfx/gui/logo.png")
				mainMenuTitleIMG:setFilter("linear", "linear")
				
			gameOverTitleIMG = lg.newImage("gfx/gui/gameOverLogo.png")
				gameOverTitleIMG:setFilter("linear", "linear")
				
			optionsMenuTitleIMG = lg.newImage("gfx/gui/optionsMenuLogo.png")
				optionsMenuTitleIMG:setFilter("nearest", "nearest")
				
			upgradesMenuTitleIMG = lg.newImage("gfx/gui/upgradeMenuLogo.png")
				upgradesMenuTitleIMG:setFilter("nearest", "nearest")
			
			mainMenuButtons = lg.newImage("gfx/gui/mainMenuButtons.png")
			
			lovelogo = lg.newImage("gfx/gui/lovelogo.png")
				lovelogo:setFilter("linear","linear")
				
				
			gui_worm = lg.newImage("gfx/gui/gui_worm.png")
			gui_bar = lg.newImage("gfx/gui/gui_bar.png")
			gui_barRed = lg.newImage("gfx/gui/gui_barRed.png")
			
			gui_healthship = lg.newImage("gfx/gui/gui_healthship.png")
			gui_back = lg.newImage("gfx/gui/gui_back.png")
			
			guiWeaponLmg = lg.newImage("gfx/gui/guiWeaponLmg.png")
			guiWeaponLaser = lg.newImage("gfx/gui/guiWeaponLaser.png")
			
			gui_heart = lg.newImage("gfx/gui/gui_heart.png")
			
		--Gegner
			octopussyIdleAnimationIMG = lg.newImage("gfx/enemies/octopussy.png")
				octopussyDieAnimationIMG = lg.newImage("gfx/enemies/octopussyDie.png")
			slimeIdleAnimationIMG = lg.newImage("gfx/enemies/slime.png")
				slimeDieAnimationIMG = lg.newImage("gfx/enemies/slimeDie.png")
			muscaBlueIdleAnimationIMG = lg.newImage("gfx/enemies/muscaBlue.png")
				muscaBlueDieAnimationIMG = lg.newImage("gfx/enemies/muscaBlueDie.png")
				
		--Icon
			windowIcon = lg.newImage("gfx/icon/octo32.png")
			lg.setIcon(windowIcon)
			
		--Powerups
			--Health 50
				health25IdleAnimationIMG = lg.newImage("gfx/entities/powerups/health25IdleAnimationIMG.png")
				health25CollectAnimationIMG = lg.newImage("gfx/entities/powerups/health25CollectAnimationIMG.png")
			--Money 50
				money50IdleAnimationIMG = lg.newImage("gfx/entities/powerups/money50IdleAnimationIMG.png")
				money50CollectAnimationIMG = lg.newImage("gfx/entities/powerups/money50CollectAnimationIMG.png")
					
							
	--Audio laden
		--Schussgeräusche
			--Standart-Schusssound	
				mgSound = love.audio.newSource("sfx/shootsounds/lmg.ogg", static)
				mgSound:setLooping(false)
				mgSound:setVolume(config.soundsVolume)
				
			--Lasersound
				laserSound = love.audio.newSource("sfx/shootsounds/laser.ogg", stream)
				laserSound:setLooping(true)
				laserSound:setVolume(config.soundsVolume)
			
			--Slimeballsound
			
				slimeShoot = love.audio.newSource("sfx/shootsounds/bulletSlimeSfx.ogg", static)
				slimeShoot:setLooping(false)
				slimeShoot:setVolume(config.soundsVolume)
				
		--Einsammelgeräusche
			--Münze
				coinSound = love.audio.newSource("sfx/collectSounds/coinCollect.ogg", static)
				coinSound:setLooping(false)
				coinSound:setVolume(config.soundsVolume)
		
		--Music
			--Background Music
				bgMusic = love.audio.newSource("sfx/music/bgMusic.ogg", stream)
				bgMusic:setLooping(true)
				bgMusic:setVolume(config.musicVolume)
				
		--Andere Soundeffekte
			--Fehlerton
				errorSound = love.audio.newSource("sfx/errorSound.ogg", static)
				errorSound:setLooping(false)
				errorSound:setVolume(config.soundsVolume)
				
			--Heilungssound
				healingSound = love.audio.newSource("sfx/healingSound.ogg", static)
				healingSound:setLooping(false)
				healingSound:setVolume(config.soundsVolume)
	
	--Fonts laden
		font = lg.newFont("fonts/font.ttf", 15)
		fontMid = lg.newFont("fonts/font.ttf", 27)
		fontBig = lg.newFont("fonts/font.ttf", 36)
			lg.setFont(font)
		
	--Gegner
		enemies = {}
		enemyBullets = {}
		
		enemySpawnRate = 1.0
		
		enemyCollideDamage = 10
			
	--Powerups
		powerups = {}
			
			
	--Charaktervariablen
		spaceship = {
		
			x = 10,
			y = 300,
			w = 64,
			h = 64,
		
			health = 100,
			maxHealth = 100,
			healthRegenerationRate = 5,
			healthRegenerationAmount = 1,
			weapon = "lmg",
			moveSpeed = 300,
			ammo = 100,
			maxAmmo = 100,
			ammoRegenSpeed = 30,
			
			lives = 3,
			
			invincible = false,
			
			syncfighterLMG = newAnimation(syncfighterLMGimg, 64, 64, 0.1, 0),
			
			
			lmg = {
			
				ammoConsumption = 10,
				defaultBulletDamage = 50,
				bulletDamage = 50,
				bulletFireRate = 0.15,
				bulletShootingTime = 0,
				bulletSpeed = 1200,
				bullets = {},
				shooting = false	
			
			},
			
			laser = {
			
				ammoConsumption = 10,
				defaultLaserDamage = 30,
				laserDamage = 30,
				laserDamageRate = 0.1,
				laserActive = false,
				laserLength = 2000,
				laserTable = {x = x, y = y, w = laserLength, h = 2}
							
			},
			
			SIN = {
			
				ammoConsumption = 10,
				defaultBulletDamage = 50,
				bulletDamage = 5,
				bulletFireRate = 0.05,
				bulletShootingTime = 0,
				bulletSpeed = 18,
				bullets = {},
				shooting = false,
				
				amplitude = 50,
				waveLength = 70
			
			},
			
			mines = {
			
				ammoConsumption = 10,
				defaultBulletDamage = 50,
				bulletDamage = 50,
				bulletFireRate = 0.15,
				bulletShootingTime = 0,
				bulletSpeed = 1200,
				mines = {},
				shooting = false	
			
			},
			
		}
		
	
	--Slimeball
		slimeball = newAnimation(slimeBulletIMG, 32, 32, 0.1, 0)
	

	--Meteoriten
		meteors = {}
		
		meteorHealth = 200
			
	--GUI Wurm
		worm = {}
		worm.scrollY = 64
		worm.x = lg.getWidth()/2 - 256 / 2
		worm.y = 0
	
	--GUI Bars
		bar = {}
		bar.health = {}
		bar.ammo = {}
		
		bar.health.x = lg.getWidth() / 2 - 60
		bar.health.y =  lg.getHeight() - gui_bar:getHeight()
		bar.health.sy = 0
		
		bar.ammo.x = lg.getWidth() / 2 + 60
		bar.ammo.y = lg.getHeight() - gui_bar:getHeight()
		bar.ammo.sy = 0
		
		
	--Nichts ändern!
		--Zufallsseed
			math.randomseed(os.time())
		
		--AnyKeyDown
			anyKeyDown = lkid(" ", "escape", "return")
			
		--Sonstiges
			mouseX = love.mouse.getX()
			mouseY = love.mouse.getY()
		
		--Loopzeiten
			spaceship.lmg.bulletshootingTime = 0
			spaceship.laser.laserDamageTime = 0
			enemySpawnTime = 0
			healthRegenerationTime = 0
	
		--FPS
			FPS = love.timer.getFPS()
		
		--Background und Parallax
			bgX = 0
			bgX2 = 800
			
			bg2X = 0
			bg2X2 = 800
		
		--Grafikeinstellungen
			screenwidth = lg.getWidth()
			screenheight = lg.getHeight()
		
		--DeltaTime
			dt = love.timer.getDelta( )

				
end

function love.update(dt)

	--Gwee
		gwee.update(dt)
		
	--Splashscreen überspringen
		if anyKeyDown == true and gameState == "intro" then
			gameState = "mainMenu"
		end
		
	--Grafikeinstellungen
		scanGraphicSettings()
	
	--Zeit
		--Schüsse
			spaceship.lmg.bulletShootingTime = spaceship.lmg.bulletShootingTime + dt
			spaceship.laser.laserDamageTime = spaceship.laser.laserDamageTime + dt
			spaceship.SIN.bulletShootingTime = spaceship.SIN.bulletShootingTime + dt
		
		enemySpawnTime = enemySpawnTime + dt
		healthRegenerationTime = healthRegenerationTime + dt
		upgradeDelayTime = upgradeDelayTime + dt
		
			if moneyFontIsRedTime > 0 then	
				moneyFontIsRedTime = moneyFontIsRedTime - dt
			elseif moneyFontIsRedTime <= 0 then
				moneyFontIsRedTime = 0
			end
			
			if levelFontIsRedTime > 0 then	
				levelFontIsRedTime = levelFontIsRedTime - dt
			elseif levelFontIsRedTime <= 0 then
				levelFontIsRedTime = 0
			end
		
			for i,v in ipairs(enemies) do
				if v["shootingTime"] ~= nil then
					v["shootingTime"] = v["shootingTime"] + dt
				end
			end
			
			for i,v in ipairs(spaceship.SIN.bullets) do
				if v["sintime"] ~= nil then
					v["sintime"] = v["sintime"] + dt * spaceship.SIN.bulletSpeed
				end
			end
		
	--Variablenaktualisierung
		screenwidth = lg.getWidth()
		screenheight = lg.getHeight()
		FPS = love.timer.getFPS()
		
		mouseX = love.mouse.getX()
		mouseY = love.mouse.getY()
		
		anyKeyDown = lkid(" ", "escape", "return")
		
		spaceship.laser.laserTable.x = spaceship.x
		spaceship.laser.laserTable.y = spaceship.y		
		spaceship.laser.laserTable.w = spaceship.laser.laserLength
		
		config.masterVolume = masterVolume
		config.soundsVolume = soundsVolume.value
		config.musicVolume = musicVolume.value
		
		currentVsync = systemScreen.vsync
		
	--Audio	
		--Lautstärken setzen
			mgSound:setVolume(config.soundsVolume )
			
			laserSound:setVolume(config.soundsVolume )
			
			bgMusic:setVolume(config.musicVolume)
		
			
		--Music
				if gameState == "game" or gameState == "upgrades" then
				
					if bgMusic:isStopped() then
						bgMusic:play()
					end
				
					if bgMusic:isPaused() then 
						if gameState == "game" or gameState == "upgrades" then
							bgMusic:resume()
						end
					end
					
				elseif gameState == "mainMenu" then bgMusic:stop() 
				
				else bgMusic:pause()
				
				end
	
	if gameState ~= "pauseMenu" and	gameState ~= "upgrades" then
	
		--Background movement
		bgX = bgX - parallax * dt
		bgX2 = bgX2 - parallax * dt
		bg2X = bg2X - parallax2 * dt
		bg2X2 = bg2X2 - parallax2 * dt				
		if bgX <= -800 then bgX = 800 end
		if bgX2 <= -800 then bgX2 = 800 end
		if bg2X <= -800 then bg2X = 800 end
		if bg2X2 <= -800 then bg2X2 = 800 end	
	
	end
	
	if gameState == "intro" then
					
		intro.update(dt)	
	
	end
	
	if gameState == "game" then
		--Gwee
			mainMenu.enabled = false
			pauseMenu.enabled = false
			highscoreMenu.enalbed = false
			optionsMenuSound.enabled = false
			optionsMenuGraphics.enabled = false
			optionsMenuBackButton.enabled = false
			
				
				
		--Resettet den Scrollfaktor vom Wurm
			worm.scrollY = 64
		
		-- Fade zurücksetzen
			fadeAlpha = 255
			
		-- Set the game as active for the options menu
		gameActive = true
		
		if gameState ~= "pauseMenu" then
		
		
			--GUI HEALTH AND AMMO BARS
				bar.health.scale = - spaceship.health  / 80
				bar.ammo.scale = - spaceship.ammo  / 80			
				
			--Animations-Updates
					spaceship.syncfighterLMG:update(dt)
				
				for i,v in ipairs(enemies) do
					enemies[i].dieAnimation:update(dt)
					enemies[i].normalAnimation:update(dt)
					if enemies[i].bulletAnimation ~= nil then	
						enemies[i].bulletAnimation:update(dt)
					end
				end

				slimeball:update(dt)
				
				for i,v in ipairs(powerups) do
					v["idleAnimation"]:update(dt)
					v["collectAnimation"]:update(dt)
				end
			
				

			--Spaceship
				--Schaden
					for i,v in ipairs(enemies) do
						
						if spaceship.invincible == false then
						
						--Wenn Gegner links aus dem Bild gehen
							if v["x"] < -v["w"] then
								spaceship.health = spaceship.health
								table.remove(enemies, i)
							end
							
						--Wenn Gegner mit dem Spaceship kollidieren
							if boxCollide(spaceship, enemies[i]) == true and v["damaging"] == true then
								spaceship.health = spaceship.health - enemyCollideDamage
								v["damaging"] = false
								v["health"] = 0
							end 
							
						--Durch Gegnerschüsse
								for i,v in ipairs(enemyBullets) do
								
									if boxCollide(enemyBullets[i], spaceship) == true  then
										spaceship.health = spaceship.health - v["damage"]
										table.remove(enemyBullets, i)
									end
								
								end
							
									
							
						--Unverwundbar wenn unverwundbar ^^	
							elseif spaceship.invincible == true then
							
								spaceship.health = spaceship.maxHealth
							
							end
							
						end
				
						--Sterben
							--Sicherheitsrücksetzung der Healthvariable
								if spaceship.health < 0 then
									spaceship.health = 0
								elseif spaceship.health > 100 then
									spaceship.health = 100
								end
						
						--Leben verlieren und Healthvariable zurücksetzen
							if spaceship.health <= 0 then
								
								spaceship.lives = spaceship.lives - 1
								
								spaceship.health = spaceship.maxHealth
								
							end
						
						--Sterben und Game Over
							if spaceship.lives <= 0 then
							
								gameState = "gameOver"
							
							end
				
						--Lebensregeneration
							if healthRegenerationTime >= spaceship.healthRegenerationRate and spaceship.health < 100  then
								spaceship.health = spaceship.health + spaceship.healthRegenerationAmount
								healthRegenerationTime = 0
							end
							
						--Bewegung		
							if lkid("up") or lkid("w") then
								if spaceship.y > 15 then
									spaceship.y = spaceship.y - spaceship.moveSpeed * dt
								end
							elseif lkid("down") or lkid("s") then
								if spaceship.y < screenheight - 50 then
									spaceship.y = spaceship.y + spaceship.moveSpeed * dt
								end
							end
							
						--Vor und Zurück
							if lkid("right") and spaceship.x <= 150  then
	
								spaceship.x = spaceship.x + (spaceship.moveSpeed - 75) * dt
	

							elseif lkid("left") and spaceship.x >= 0 then
	
								spaceship.x = spaceship.x - (spaceship.moveSpeed -75) * dt
		
							end
							
							if spaceship.y < 15 then spaceship.y = 15 end
							if spaceship.y > screenheight - 50 then spaceship.y = screenheight - 50 end
							
						--Schießen
							--LMG	
								if lkid(" ") and spaceship.weapon == "lmg" and weaponLevel[1] > 0 then
									spaceship.lmg.shooting = true
								else
									spaceship.lmg.shooting = false
								end
								
								if spaceship.lmg.shooting == true and spaceship.ammo > 0 and spaceship.lmg.bulletShootingTime >= spaceship.lmg.bulletFireRate then
									mgSound:stop()
									mgSound:play()
									
									if weaponLevel[1] == 1 then
									
										spawnLMGBullet(screenwidth + 1, spaceship.y)
									
									elseif weaponLevel[1] == 2 then
									
										spawnLMGBullet(screenwidth + 1, spaceship.y - 20)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 20)
									
									elseif weaponLevel[1] == 3 then
									
										spawnLMGBullet(screenwidth + 1, spaceship.y - 30)
										spawnLMGBullet(screenwidth + 1, spaceship.y)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 30)								
									
									elseif weaponLevel[1] == 4 then
									
										spawnLMGBullet(screenwidth + 1, spaceship.y - 40)
										spawnLMGBullet(screenwidth + 1, spaceship.y - 20)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 20)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 40)
									
									elseif weaponLevel[1] == 5 then
									
										spawnLMGBullet(screenwidth + 1, spaceship.y - 60)
										spawnLMGBullet(screenwidth + 1, spaceship.y - 30)
										spawnLMGBullet(screenwidth + 1, spaceship.y)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 30)
										spawnLMGBullet(screenwidth + 1, spaceship.y + 60)
										
									end
									
									spaceship.lmg.bulletShootingTime = 0
								end
								
								for i,v in ipairs(spaceship.lmg.bullets) do
									v["x"] = v["x"] + (v["dx"] * dt)
									v["y"] = v["y"] + (v["dy"] * dt)
								end
								
								for i,v in ipairs(spaceship.lmg.bullets) do
									if v["x"] > screenwidth + 20 then table.remove(spaceship.lmg.bullets, i) end
								end
								
								for i,v in ipairs(enemies) do
									for ii,vv in ipairs(spaceship.lmg.bullets) do
									
										if boxCollide(spaceship.lmg.bullets[ii],enemies[i]) == true and enemies[i].health > 0 then
											applyDamageToEnemy(i, spaceship.lmg.bulletDamage)
											table.remove(spaceship.lmg.bullets, ii)
										end
									
									end
								end
										
							--Laser
								if weaponLevel[2] == 1 then
									
									spaceship.laser.laserDamage = 30
									spaceship.laser.laserTable.h = 2
									spaceship.laser.laserTable.y = spaceship.y - (spaceship.laser.laserTable.h / 2)
									
								elseif weaponLevel[2] == 2 then
									
									spaceship.laser.laserDamage = 40
									spaceship.laser.laserTable.h = 3
									spaceship.laser.laserTable.y = spaceship.y - (spaceship.laser.laserTable.h / 2)
									
								elseif weaponLevel[2] == 3 then
									
									spaceship.laser.laserDamage = 50
									spaceship.laser.laserTable.h = 4
									spaceship.laser.laserTable.y = spaceship.y - (spaceship.laser.laserTable.h / 2)									
									
								elseif weaponLevel[2] == 4 then
									
									spaceship.laser.laserDamage = 75
									spaceship.laser.laserTable.h = 8
									spaceship.laser.laserTable.y = spaceship.y - (spaceship.laser.laserTable.h / 2)
									
								elseif weaponLevel[2] == 5 then
									
									spaceship.laser.laserDamage = 100
									spaceship.laser.laserTable.h = 12
									spaceship.laser.laserTable.y = spaceship.y - (spaceship.laser.laserTable.h / 2)
										
								end
								
								if lkid(" ") and spaceship.weapon == "Laser" and spaceship.ammo > 0 and weaponLevel[2] > 0 then
									spaceship.laser.laserActive = true
									
									if laserSound:isStopped() then
										laserSound:play()								
									end
									
									for i,v in ipairs(enemies) do
										
										if boxCollide(spaceship.laser.laserTable,enemies[i]) == true then
												
											if spaceship.laser.laserDamageTime >= spaceship.laser.laserDamageRate then
													
													applyDamageToEnemy(i, spaceship.laser.laserDamage)
													
													setLaserLength(v["x"])
													
												spaceship.laser.laserDamageTime = 0
											end
												
										else
										
											setLaserLength(screenwidth)
										
										end
										
									end
									
								else
									spaceship.laser.laserActive = false
									laserSound:stop()
									
								end
							--SIN-Shot
								if lkid(" ") and spaceship.weapon == "SIN-Shot" and weaponLevel[3] > 0 then
									spaceship.SIN.shooting = true
								else
									spaceship.SIN.shooting = false
								end
								
								if spaceship.SIN.shooting == true and spaceship.ammo > 0 and spaceship.SIN.bulletShootingTime >= spaceship.SIN.bulletFireRate then
									mgSound:stop()
									mgSound:play()
									
									if weaponLevel[3] == 1 then
									
										spawnSINBullet("sin")
									
									elseif weaponLevel[3] == 2 then
									
										spawnSINBullet("sin")
										spawnSINBullet("cos")
										
									end
									
									spaceship.SIN.bulletShootingTime = 0
								end
								
									
								for i,v in ipairs(spaceship.SIN.bullets) do
									if v["type"] == "sin" then
										v["x"] = math.cos(0) * v["sintime"] * (spaceship.SIN.waveLength / (2 * math.pi)) + ((spaceship.SIN.amplitude / 2) * math.sin(v["sintime"]) * math.sin(0))
										v["y"] = math.sin(0) * v["sintime"] * (spaceship.SIN.waveLength / (2 * math.pi)) - ((spaceship.SIN.amplitude / 2) * math.sin(v["sintime"]) * math.cos(0))
										v["x"] = v["x"] + v["sx"]
										v["y"] = v["y"] + v["sy"]
									elseif v["type"] == "cos" then
										v["x"] = math.cos(0) * v["sintime"] * (spaceship.SIN.waveLength / (2 * math.pi)) - ((spaceship.SIN.amplitude / 2) * math.sin(v["sintime"]) * math.sin(0))
										v["y"] = math.sin(0) * v["sintime"] * (spaceship.SIN.waveLength / (2 * math.pi)) + ((spaceship.SIN.amplitude / 2) * math.sin(v["sintime"]) * math.cos(0))
										v["x"] = v["x"] + v["sx"]
										v["y"] = v["y"] + v["sy"]
									end
								end
								
								for i,v in ipairs(spaceship.SIN.bullets) do
									if v["x"] > screenwidth + 20 then table.remove(spaceship.SIN.bullets, i) end
								end
								
								for i,v in ipairs(enemies) do
									for ii,vv in ipairs(spaceship.SIN.bullets) do
									
										if boxCollide(spaceship.SIN.bullets[ii], enemies[i]) == true and enemies[i].health > 0 then
											applyDamageToEnemy(i, spaceship.SIN.bulletDamage)
											table.remove(spaceship.SIN.bullets, ii)
										end
									
									end
								end
								
							--Mines	
								if lkid(" ") and spaceship.weapon == "mines" and weaponLevel[4] > 0 then
									spaceship.mines.shooting = true
								else
									spaceship.mines.shooting = false
								end
								
								if spaceship.mines.shooting == true and spaceship.ammo > 0 and spaceship.mines.bulletShootingTime >= spaceship.mines.bulletFireRate then
									mgSound:stop()
									mgSound:play()
									
									spawnMine()
									
									spaceship.mines.bulletShootingTime = 0
								end
								
								for i,v in ipairs(enemies) do
									for ii,vv in ipairs(spaceship.mines.mines) do
									
										if boxCollide(spaceship.mines.mines[ii],enemies[i]) == true and enemies[i].health > 0 then
											applyDamageToEnemy(i, spaceship.mines.bulletDamage)
											table.remove(spaceship.mines.mines, ii)
										end
									
									end
								end
				
			--Powerups
				--Bewegung
					for i,v in ipairs(powerups) do
					
						v["x"] = v["x"] - v["speed"] * dt
					
					end
					
					
				--Einsammeln
					for i,v in ipairs(powerups) do
						if boxCollide(powerups[i], spaceship) == true then
							v["isCollected"] = true
						end
						
						if v["isCollected"] == false then
							
							v["collectAnimation"]:reset()
						
						end
						
					end
					
				--Powerups löschen wenn sie aus dem Screen fliegen
						for i,v in ipairs(powerups) do
							if v["x"] < -v["w"] then
								table.remove(powerups, i)
							end
						end
				
				
			--Gegner
				--Bewegung
					for i,v in ipairs(enemies) do
					
						v["x"] = v["x"] - v["speed"] * dt
					
					end
				
				--Sterben
					for i,v in ipairs(enemies) do
						
							if v["health"] == 0 then
								local healthPowerupChance = math.random(1, 30)
								local moneyChance = math.random(1, 6)
									
									if healthPowerupChance == 1 and v["isDead"] == false then
										spawnPowerup("health25", v["x"], v["y"])
									end	

									if moneyChance == 1 and v["isDead"] == false then
										spawnPowerup("money50", v["x"], v["y"])
									end

								v["isDead"] = true

							end
					
							
							if v["health"] < 0 then
								v["health"] = 0
							end
							
							if v["health"] ~= 0 then
								
								enemies[i].dieAnimation:reset()
							
							end
						
					end
					
				--Gegner löschen wenn sie aus dem Screen fliegen
						for i,v in ipairs(enemies) do
							if v["x"] < -v["w"] then
								table.remove(enemies, i)
							end
						end
				
				--Gegner spawnen
					if enemySpawnTime >= enemySpawnRate then
						local randomEnemyType = math.random(1, 3)
							if randomEnemyType == 1 then
								spawnEnemy("octopussy")
							elseif randomEnemyType == 2 then
								spawnEnemy("slime")
							elseif randomEnemyType == 3 then
								spawnEnemy("muscaBlue")
							end
						
						enemySpawnTime = 0
					end
					
				--Schießen
					for i,v in ipairs(enemies) do 
						if v["shootingTime"] ~= nil then
							if v["shootingTime"] >= v["shootingRate"] then
								
									slimeShoot:stop()
									slimeShoot:play()
									
									local startX = v["x"] + 5
									local startY = v["y"] + 27
									local aimX = v["x"] - 900
									local aimY = v["y"] + 9
											
									local bulletDx = - v["bulletSpeed"]
									local bulletDy = 0
									   
									table.insert(enemyBullets, {
										x = startX,
										y = startY,
										w = 1,
										h = 1,
										dx = bulletDx, 
										dy = bulletDy,
										
										damage = v["damage"],
																				
										bulletAnimation = v["bulletAnimation"]								
									})
									
									v["shootingTime"] = 0
								
							end
						end
					end
					
					--Bulletpositionen
						for i,v in ipairs(enemyBullets) do
							v["x"] = v["x"] + (v["dx"] * dt)
							v["y"] = v["y"] + (v["dy"] * dt)
						end
						
					--Bullets löschen wenn sie aus dem Screen fliegen
						for i,v in ipairs(enemyBullets) do
							if v["x"] < -10 then
								table.remove(enemyBullets, i)
							end
						end
					
			--Meteore
		end
		
		-- Updatet die Ammo-Anzeige
			if spaceship.ammo >= 0 then
				
				if spaceship.lmg.shooting == true then		
					spaceship.ammo = spaceship.ammo - spaceship.lmg.ammoConsumption * dt			
				elseif spaceship.laser.laserActive == true then		
					spaceship.ammo = spaceship.ammo - spaceship.laser.ammoConsumption * dt			
				elseif spaceship.SIN.shooting == true then		
					spaceship.ammo = spaceship.ammo - spaceship.SIN.ammoConsumption * dt			
				end
			
			end
			
			if spaceship.ammo < spaceship.maxAmmo then 
			
				if spaceship.lmg.shooting == false and spaceship.laser.laserActive == false and spaceship.SIN.shooting == false and lkid(" ") == false then		
					spaceship.ammo = spaceship.ammo + spaceship.ammoRegenSpeed * dt						
				end
			
			end
	
		
		-- WIRD AUSGEFÜHRT WENN DIE AMMO-LEISTE BEI 100 IST
		if spaceship.ammo > 100 then
				
			spaceship.ammo = 100
					
		end
				
		-- WIRD AUSGEFÜHRT WENN DIE AMMO-LEISTE BEI 0 IST
		if  spaceship.ammo <= 0 then
					
			spaceship.ammo = 0
			
		end
		
	end
	-- GAMESTATE HIGHSCORE
	if gameState == "highscores" then
		--Gwee
			mainMenu.enabled = false
			pauseMenu.enabled = false
			highscoreMenu.enabled = true
			optionsMenuSound.enabled = false
			optionsMenuGraphics.enabled = false
			optionsMenuBackButton.enabled = false
					
	
	end
	
	if gameState == "mainMenu" then
	
		-- Einfaden vom Hauptmenu
			if fadeAlpha > 0 then
				fadeAlpha = fadeAlpha - 255 * dt			
			end
			
			if fadeAlpha < 0 then fadeAlpha = 0 end
		
		--Gwee
			mainMenu.enabled = true
			pauseMenu.enabled = false
			highscoreMenu.enabled = false
			optionsMenuSound.enabled = false
			optionsMenuGraphics.enabled = false	
			optionsMenuBackButton.enabled = false			
				
				--Tables zurücksetzen
					gameReset()
	end
	
	if gameState == "pauseMenu" then

			--Gwee
				mainMenu.enabled = false
				highscoreMenu.enabled = false
				optionsMenuSound.enabled = false
				optionsMenuGraphics.enabled = false
				optionsMenuBackButton.enabled = false
				
	
			worm.y = lg.getHeight() - worm.scrollY

			-- Führt die Bewegung aus
			if worm.scrollY <= 512 then
	
				worm.scrollY = worm.scrollY + 700 * dt
		
			end
	
			-- Wenn er höher scrollt als gewünscht, wird er auf 512 zurückgesetzt
				if worm.scrollY > 512 then
	
					worm.scrollY = 512
		
				end
				
				if worm.scrollY == 512 then
				
					pauseMenu.enabled = true
				end				
	end
	
	
	if gameState == "upgrades" then
	
		--Gwee
			mainMenu.enabled = false
			pauseMenu.enabled = false
			highscoreMenu.enabled = false
			optionsMenuSound.enabled = false
			optionsMenuGraphics.enabled = false
			optionsMenuBackButton.enabled = false
			
		--Moneyvariablenfarbe
			if moneyFontIsRedTime > 0 then
				moneyFontIsRed = true
			elseif moneyFontIsRedTime <= 0 then
				moneyFontIsRed = false
			end
			
		--Maxlevelfarbe
			if levelFontIsRedTime > 0 then
				levelFontIsRed = true
			elseif levelFontIsRedTime <= 0 then
				levelFontIsRed = false
			end
	end
	
	
	if gameState == "gameOver" then
	

	
		--Gwee
			optionsMenuSound.enabled = false
			optionsMenuGraphics.enabled = false
			optionsMenuBackButton.enabled = false
			gameOverMenu.enabled = true
			
		
		spaceship.health = 100
		spaceship.lives = 3
	
	end
	
	if gameState == "optionsMenu" then
	
		--Gwee
			mainMenu.enabled = false
			pauseMenu.enabled = false
			highscoreMenu.enabled = false
			optionsMenuSound.enabled = true
			optionsMenuGraphics.enabled = true
			optionsMenuBackButton.enabled = true
	
	end
	
	--Splashsound stoppen wenn das Intro übersprungen wird
		if gameState ~= "intro" then
			splash:stop()
		end
end

function love.draw()	

	--Background
	lg.draw(starBackground2, bg2X, 0, 0, 1, 1)
	lg.draw(starBackground2, bg2X2, 0, 0, 1, 1)
	lg.draw(starBackground, bgX, 0, 0, 1, 1)
	lg.draw(starBackground, bgX2, 0, 0, 1, 1)


	if gameState == "intro" then

	intro.draw()

	end

	if gameState == "game" or gameState == "pauseMenu" or gameState == "upgrades" then	

		--Raumschiff
			if spaceship.weapon == "lmg" then
				spaceship.syncfighterLMG:draw(spaceship.x, spaceship.y) 
			elseif spaceship.weapon == "Laser" then
				spaceship.syncfighterLMG:draw(spaceship.x, spaceship.y)
			else
				spaceship.syncfighterLMG:draw(spaceship.x, spaceship.y) 
			end
			
		--Powerups
			--Powerups zeichnen
				for i,v in ipairs(powerups) do
					if v["isCollected"] == false then
					
						v["idleAnimation"]:draw(v["x"], v["y"])
						
					elseif v["isCollected"] == true then
							
							
						v["collectAnimation"]:draw(v["x"], v["y"])
						v["collectAnimation"]:play()						
					end			
					
				if v["collectAnimation"]:getCurrentFrame() == 5 then	
						
						if v["powerupType"] == "health25" then
							healingSound:stop()
							healingSound:play()
							
							spaceship.health = spaceship.health + 25
							addPoints(v["points"])
						
								
						elseif v["powerupType"] == "money50" then
							coinSound:stop()
							coinSound:play()
							
							money = money + 50
							addPoints(v["points"])
								
						end		
						
						table.remove(powerups, i)
						end
				end	
		--Waffenschüsse
			--lmg	
				for i,v in ipairs(spaceship.lmg.bullets) do
					lg.draw(bullet, v["x"], v["y"], math.rad(90), 4, 4)
				end
			--Laser
				if spaceship.laser.laserActive == true then
					lg.draw(laser, spaceship.laser.laserTable.x + 62, spaceship.laser.laserTable.y + 27, math.rad(0), spaceship.laser.laserLength, spaceship.laser.laserTable.h, 0, 0) 
				end
			--SIN	
				for i,v in ipairs(spaceship.SIN.bullets) do
					lg.draw(SINbullet, v["x"], v["y"], math.rad(0), 2, 2)
				end
			--mines	
				for i,v in ipairs(spaceship.mines.mines) do
					lg.draw(bullet, v["x"], v["y"], math.rad(0), 4, 4)
				end
			
		--Gegner
			--Gegner zeichnen
				for i,v in ipairs(enemies) do
					if v["isDead"] == false then
						v["normalAnimation"]:draw(v["x"], v["y"])
					end
				end
				
			--Sterben	
				for i,v in ipairs(enemies) do
					if v["isDead"] == true then
						
						
						enemies[i].dieAnimation:draw(v["x"], v["y"])
						enemies[i].dieAnimation:play()
						
						if enemies[i].dieAnimation:getCurrentFrame() == 5 then						
							addPoints(v["points"])
							table.remove(enemies, i)
						end
					
					end
					
				end
				
			--Schießen
				for i,v in ipairs(enemyBullets) do
							
					v["bulletAnimation"]:draw(v["x"], v["y"])
					
				end
				
		--Fadenkreuz
			lg.draw(fadenkreuz, 700, spaceship.y + 27, 0, 0.75, 0.75, 16, 16)		
			
				
		--ZEICHNET Player HUD (Heads up display)
			if gameState ~= "pauseMenu" then
		
			--Scoreanzeige
				lg.printf("Score: "..points,30 , 10, 50, "center")
				lg.print(spaceship.health.. "%" , lg.getWidth() / 2 - 40 , 515)
				lg.print(math.floor(spaceship.ammo).. "%" , lg.getWidth() / 2 - 5 , 580)
				
			--Moneyanzeige nur wenn das Upgrade menu nicht aktiviert ist
			if gameState ~= "upgrades" then
				lg.printf("Money: "..money, screenwidth - 80 , 10, 50, "center")
			end
		
			--Zeichnet den Hintergrund
			lg.draw(gui_back, lg.getWidth() / 2 - gui_back:getWidth() / 2, lg.getHeight() - gui_back:getHeight())
		
			-- Zeichnet Lebens und Munitionsleisten
			if spaceship.health >= 40 then -- Wenn health unter 40 Prozent ist, dann wird die Leiste rot.
		
				lg.draw( gui_bar, bar.health.x- gui_bar:getWidth() / 2 , bar.health.y + 64, nil, nil, bar.health.scale)

			else
			
				lg.draw( gui_barRed, bar.health.x - gui_bar:getWidth() / 2, bar.health.y + 64, nil, nil, bar.health.scale)
		
			end
			
				if spaceship.ammo >= 40 then -- Wenn Ammo unter 40 Prozent ist, dann wird die Leiste rot.
		
					lg.draw( gui_bar, bar.ammo.x - gui_bar:getWidth() / 2, bar.ammo.y + 64 , nil, nil, bar.ammo.scale)

				else
			
					lg.draw( gui_barRed, bar.ammo.x - gui_bar:getWidth() / 2, bar.ammo.y + 64, nil, nil, bar.ammo.scale)
				end
			
			-- Zeichnet das Healthschiff und die Waffe
				lg.draw( gui_healthship, bar.health.x - 32 , lg.getHeight() - gui_healthship:getHeight() - 6 )
				
				if spaceship.weapon == "lmg" then
				
					lg.draw(guiWeaponLmg, bar.ammo.x - 32 , lg.getHeight() - guiWeaponLmg:getHeight() - 10)
					
				elseif spaceship.weapon == "Laser" then
				
					lg.draw(guiWeaponLaser, bar.ammo.x - 32 , lg.getHeight() - guiWeaponLmg:getHeight() - 10)
					
				else
				
					lg.draw(guiWeaponLaser, bar.ammo.x - 32 , lg.getHeight() - guiWeaponLmg:getHeight() - 10)
					
				end
				
			--Zeichnet die Leben
					if spaceship.lives == 3 then
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 - gui_heart:getWidth() ,10)
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 ,10)
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 + gui_heart:getWidth() ,10)
			
					elseif spaceship.lives == 2 then
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 - gui_heart:getWidth() ,10)
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 ,10)
			
					elseif spaceship.lives == 1 then
						lg.draw(gui_heart, lg.getWidth() / 2 - gui_heart:getWidth() /2 - gui_heart:getWidth() ,10)
			
					elseif spaceship.lives <= 0 then 
					
						gamestate = "game_over"
					
					end
				end				
		end
		
	--PAUSEMENU
	if gameState == "pauseMenu" then
	
	-- Game etwas ausblenden
		lg.setColor(0,0,0,150)
		lg.rectangle("fill", 0,0, 800,600)
	
		lg.draw(gui_worm, worm.x, worm.y)
		
			if worm.scrollY == 512 then
				
				
				lg.print("PAUSE", lg.getWidth()/2 - 35, 70)
				
			end
	end
	
	
	--UPGRADEMENÜ
	if gameState == "upgrades" then
		
		-- Game etwas ausblenden
			lg.setColor(0,0,0,150)
			lg.rectangle("fill", 0,0, 800,600)
	
		--Titel
			lg.draw(upgradesMenuTitleIMG, lg.getWidth() / 2 - upgradesMenuTitleIMG:getWidth() / 2, 20)
			
		--Money Variable anzeigen
			local textLength = 500 
			
				lg.setFont(fontBig)
				
					if moneyFontIsRed == true then
						lg.setColorMode('modulate')
						lg.setColor(255,0,0)					
						lg.printf("Money:"..money, lg.getWidth() / 2 - textLength / 2, 130, textLength, "center")
					elseif moneyFontIsRed == false then					
						lg.printf("Money:"..money, lg.getWidth() / 2 - textLength / 2, 130, textLength, "center")
					end
				
				lg.setFont(font)
				
				
		-- Verfügbare Upgrades anzeigen
			lg.setColorMode('replace')
			lg.setColor( 100, 100, 100, 150)
			
			for i = 1, #upgradeItem do
					lg.printf(tostring(upgradeItem[i]),30, 165 + ( 25 * i ) , textLength, "left")
				
				-- Level Anzeigen
					
					lg.rectangle("fill", 500, 165 + (25 * i), 50, 20)
					lg.print("LvL", 510, 170)
					
					if weaponLevel[i] ~= nil then
						if weaponLevel[i] >= weaponMaxLevel[i] then
							if weaponLevel[i] > 0 then	
								if levelFontIsRed == true then
									lg.setColorMode('modulate')
									lg.setColor(255,0,0)	
									lg.printf("MAX", 525- textLength / 2, 167 + (25 * i),textLength, "center")
								elseif levelFontIsRed == false then
									lg.printf("MAX", 525- textLength / 2, 167 + (25 * i),textLength, "center")
								end
							elseif weaponLevel[i] == 0 then
								if levelFontIsRed == true then
									lg.setColorMode('modulate')
									lg.setColor(255,0,0)	
									lg.printf("-", 525- textLength / 2, 167 + (25 * i),textLength, "center")
								elseif levelFontIsRed == false then
									lg.printf("-", 525- textLength / 2, 167 + (25 * i),textLength, "center")
								end
							end
						else
							lg.setColorMode('replace')
							lg.setColor( 100, 100, 100, 150)
							lg.printf(weaponLevel[i], 525- textLength / 2, 167 + (25 * i),textLength, "center")
						end
						
					end
					
				-- Preise	
					lg.setColorMode('replace')
					lg.setColor( 50, 50, 50, 150)
					lg.rectangle("fill", 600, 165 + (25 * i), 50, 20)
					lg.print("Cost", 610, 170)
					
					for ii,vv in ipairs(weaponLevel) do
						for iii,vvv in ipairs(weaponUpgradePrices) do
							
								if weaponUpgradePrices[ii][weaponLevel[ii]+1] ~= nil and weaponMaxLevel[ii] ~= nil and weaponLevel[ii] ~= nil then
									if weaponLevel[ii] < weaponMaxLevel[ii] then
										lg.print(weaponUpgradePrices[ii][weaponLevel[ii]+1], 603, 167 + (25 * ii))
									elseif weaponLevel[ii] >= weaponMaxLevel[ii] then
										lg.printf("MAX", 605, 165 + (25 * ii), textLength, "left")
									elseif weaponLevel[ii] == 0 then
										lg.printf("-", 605, 165 + (25 * ii), textLength, "left")
									end
								end
						end					
					end
				
				
				-- Upgrade / Buy Knopf	
					
					lg.setColorMode('replace')
					lg.setColor( 50, 50, 50, 150)
					lg.rectangle("fill", 650, 165 + (25 * i), 50, 20)
					lg.print( "Buy", 660, 168 + (25 * i))
					lg.print( "|", 652, 168 + (25 * i))
									
				
				end
		end
			
			
		
		
	--Gwee (muss am Anfang gezeichnet werden wegen dem Fade)
		gwee.draw()
			
			
	--MAINMENU
	if gameState == "mainMenu" then
	
	
			pauseMenu.enabled = false
			gameOverMenu.enabled = false
		
		--Titelbild
			lg.draw(mainMenuTitleIMG, 210, 20, 0, .75, .75)
			
		--Destructive Reality
			lg.print("Version "..versionNumber, 5, screenheight - 40)
			lg.print("by Destructive Reality", 5, screenheight - 20)
			
		--Buttons
			lg.draw(mainMenuButtons, 245, 150, 0, 5, 5)
			
			-- Fade Viereck
			lg.setColor(0, 0, 0, fadeAlpha)
				--LÖVE-Logo
					lg.draw(lovelogo, screenwidth - 140, screenheight - 65, 0)
			lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
			
			
			
	elseif gameState == "highscores" then
		--Gwee
			pauseMenu.enabled = false
			gameOverMenu.enabled = false
			
		--Titelbild
			lg.draw(highscoresTitleIMG, lg.getWidth() / 2 - highscoresTitleIMG:getWidth() / 2 , 0, 0, 1, 1)
		
		--Highscores
			for i, score, name in highscore() do
				
					lg.printf(name, 300, i * 30 + 130, 100, "left")
					lg.printf(score, 420, i * 30 + 130,100, "center")
				
			end	
			
	elseif gameState == "gameOver" then
		--Gwee
			pauseMenu.enabled = false
			mainMenu.enabled = false
			gameOverMenu.enabled = true
		
		--Titelbild
			lg.draw(gameOverTitleIMG, lg.getWidth() / 2 - gameOverTitleIMG:getWidth() / 2, 20, 0)
		--Score
			lg.setFont(fontBig)
			lg.printf("Score: "..points, lg.getWidth() / 2 - 25 , 230, 50, "center")
			lg.setFont(font)
	
	elseif gameState == "optionsMenu" then
			
		--Titelbild
			lg.draw(optionsMenuTitleIMG, lg.getWidth() / 2 - optionsMenuTitleIMG:getWidth() / 2 , 0, 0, 1, 1)
			
		--Unterüberschriften
			lg.setFont(fontMid)
				lg.print("Sound settings", 70, 160)
			lg.setFont(font)
	
	end
end

function love.keypressed(key, unicode)
	--Gwee
		gwee.keypressed(key, unicode)
		
		--Pausenmenü
			if gameState == "game" and key == "escape" then
			
				gameState = "pauseMenu"		

			
			elseif gameState == "pauseMenu" and key == "escape" then
			
				gameState = "game"
			
			end
			
		--Upgrademenü
			if gameState == "game" and key == "u" then
			
				gameState = "upgrades"		

			
			elseif gameState == "upgrades" and key == "u" then
			
				gameState = "game"
			
			end
			
		--Debugschaden
			if key == "k" then
				spaceship.health = spaceship.health - 50
			end
			
		--Waffenwechsel
			if key == "1" then
				if weaponLevel[1] > 0 then	
					spaceship.weapon = "lmg"
				else
					errorSound:stop()
					errorSound:play()
				end
			elseif key == "2" then
				if weaponLevel[2] > 0 then
					spaceship.weapon = "Laser"
				else
					errorSound:stop()
					errorSound:play()
				end
			elseif key == "3" then
				if weaponLevel[3] > 0 then	
					spaceship.weapon = "SIN-Shot"
				else
					errorSound:stop()
					errorSound:play()
				end
			end
			
		--Debuggeld
			if key == "m" then
				money = money + 1000
			end
	
end 

function love.mousepressed(x, y, button)
    gwee.mousepressed(x, y, button)
	
	--Kaufbuttons
		for i,v in ipairs(weaponLevel) do
			for ii,vv in ipairs(weaponMaxLevel) do
				for iii,vvv in ipairs(weaponUpgradePrices) do
										
					if button == "l" then	
						
						if boxCollide({x = mouseX, y = mouseY, w = 1, h = 1}, {x = 600, y = 165 + (25 * i), w = 100, h = 20}) then

							if weaponLevel[i] < weaponMaxLevel[i] and money >= weaponUpgradePrices[i][weaponLevel[i]+1] and upgradeDelayTime >= 0.1 then
								coinSound:stop()
								coinSound:play()
								money = money - weaponUpgradePrices[i][weaponLevel[i]+1]	
								weaponLevel[i] = weaponLevel[i] + 1
								upgradeDelayTime = 0
							elseif weaponLevel[i] < weaponMaxLevel[i] and money < weaponUpgradePrices[i][weaponLevel[i]+1] and upgradeDelayTime >= 0.1 then
								moneyFontIsRedTime = moneyFontIsRedDuration
								
								errorSound:stop()
								errorSound:play()
								upgradeDelayTime = 0
							elseif weaponLevel[i] >= weaponMaxLevel[i] and upgradeDelayTime >= 0.1 then	
								levelFontIsRedTime = levelFontIsRedDuration
							
								errorSound:stop()
								errorSound:play()
								upgradeDelayTime = 0
							end
								
						end
					
					end
					
				end			
			end			
		end
end

function love.mousereleased(x, y, button)
    gwee.mousereleased(x, y, button)
end

function setLaserLength(xPosition)
	
	if xPosition < 78 then return end
	
	spaceship.laser.laserLength = xPosition - 75
	
end

function applyDamageToEnemy(tablePlace, amount)
	if tablePlace > #enemies then
		return
	else
		enemies[tablePlace].health = enemies[tablePlace].health - amount
	end
end

function applyDamageToSpaceship(amount)

	spaceship.health = spaceship.health - amount

end
	
function boxCollide(rect1, rect2)
	
  local rect1x2 , rect1y2 , rect2x2 , rect2y2 = rect1.x + rect1.w , rect1.y + rect1.h , rect2.x + rect2.w , rect2.y + rect2.h
  
  return rect1.x < rect2x2 and rect1x2 > rect2.x and rect1.y < rect2y2 and rect1y2 > rect2.y
  
end
	
function spawnPowerup(powerupType, x, y)
	if powerupType == "health25" then
		table.insert(powerups, {
			x = x,
			y = y,
			w = 32,
			h = 32,
			
			isCollected = false,
			
			speed = 100,
			powerupType = "health25",
			points = 50,
		
			idleAnimation = newAnimation(health25IdleAnimationIMG, 32, 32, .15, 0),
			collectAnimation = newAnimation(health25CollectAnimationIMG, 32, 32, .1, 0)
			
		})	
	elseif powerupType == "money50" then
		table.insert(powerups, {
			x = x,
			y = y,
			w = 32,
			h = 32,
			
			isCollected = false,
			
			speed = math.random(80, 120),
			powerupType = "money50",
			points = 50,
			
			idleAnimation = newAnimation(money50IdleAnimationIMG, 32, 32, .15, 0),
			collectAnimation = newAnimation(money50CollectAnimationIMG, 32, 32, .1, 0)
			
		})	
	end
end
	

function spawnEnemy(enemyType)
	if enemyType == "octopussy" then
		table.insert(enemies, {
			x = 801,
			y = math.random(10, 540),
			w = 62,
			h = 62,
			
			speed = math.random(60, 100),
			health = 100, 
			damaging = true,
			enemyType = "octopussy", 
			points = 50,
			
			damage = 10,
			
			isDead = false, 
			dieAnimation = newAnimation(octopussyDieAnimationIMG, 64, 64, 0.1, 0),
			normalAnimation = newAnimation(octopussyIdleAnimationIMG, 64, 64, 0.15, 0),
			
			bulletAnimation = newAnimation(octopussyBulletIMG, 32, 32, 0.1, 0),
						
			shootingTime = 0,
			shootingRate = math.random(2, 4),
			bulletSpeed = 500
		})
		
	elseif enemyType == "slime" then
		table.insert(enemies, {
			x = 801,
			y = math.random(10, 540),
			w = 62,
			h = 62,
			
			speed = math.random(40, 65),
			health = 200, 
			damaging = true,
			enemyType = "slime", 
			points = 80,
			
			damage = 10,
			
			isDead = false, 
			dieAnimation = newAnimation(slimeDieAnimationIMG, 64, 64, 0.1, 0),
			normalAnimation = newAnimation(slimeIdleAnimationIMG, 64, 64, 0.15, 0),
			
			bulletAnimation = newAnimation(slimeBulletIMG, 32, 32, 0.1, 0),
			
			shootingTime = 0,
			shootingRate = math.random(3, 4),
			bulletSpeed = 500
		})
	elseif enemyType == "muscaBlue" then
		table.insert(enemies, {
			x = 801,
			y = math.random(10, 540),
			w = 62,
			h = 62,
				
			speed = math.random(180, 200),
			health = 50, 
			damaging = true,
			enemyType = "musca", 
			points = 30,
			isDead = false, 
			dieAnimation = newAnimation(muscaBlueDieAnimationIMG, 64, 64, 0.1, 0),
			normalAnimation = newAnimation(muscaBlueIdleAnimationIMG, 64, 64, 0.1, 0),
		})
	end

	
end

function spawnMeteor(meteorSize)
	if meteorSize == "small" then	
		table.insert(meteors, {
		
			x = 801,
			y = math.random(10, 540),
			w = 64,
			h = 64,
			
			xImgOffset = 32,
			yImgOffset = 32,
			
			xCollisionOffset = 32,
			yCollisionOffset = 32,
			
			rotation = math.rad(0),
			speed = 70,
			health = meteorHealth,
			isDestroyed = false,
			meteorType = "small"
			
		})
	elseif meteorSize == "middle" then
		table.insert(meteors, {
		
			x = 801,
			y = math.random(10, 540),
			w = 64,
			h = 64,
			
			xImgOffset = 32,
			yImgOffset = 32,
			
			xCollisionOffset = 32,
			yCollisionOffset = 32,
			
			rotation = math.rad(0),
			speed = 60,
			health = meteorHealth,
			isDestroyed = false,
			meteorType = "middle"
			
		})
	elseif meteorSize == "big" then
		table.insert(meteors, {
		
			x = 801,
			y = math.random(10, 540),
			w = 64,
			h = 64,
			
			xImgOffset = 32,
			yImgOffset = 32,
			
			xCollisionOffset = 32,
			yCollisionOffset = 32,
			
			rotation = math.rad(0),
			speed = 40,
			health = meteorHealth,
			isDestroyed = false,
			meteorType = "big"
			
		})
	end
end

function addPoints(amount)
	points = points + amount
end

function love.quit()
	--Highscores
		highscore.save()
	--Configdatei			
		file = love.filesystem.newFile("config.sav")
		file:open('w')
		file:write(TSerial.pack(config))
		file:close()
end

function love.focus(focus)
	if focus == false and gameState == "game" then
		gameState = "pauseMenu"
	end
end

function scanGraphicSettings()

	local width, height, fullscreen, vsync, fsaa = love.graphics.getMode()
	
	systemScreen.width = width
	systemScreen.height = height
	systemScreen.fullscreen = fullscreen
	systemScreen.vsync = vsync
	systemScreen.fsaa = fsaa

end

function gameReset()

	enemies = {}
	spaceship.lmg.bullets = {}
	powerups = {}
	money = 0
	spaceship.y = 300
	points = 0
	
	weaponLevel = weaponDefaultLevel
	
end

function spawnLMGBullet(aimX, aimY)

	local startX = spaceship.x + 66
	local startY = spaceship.y + 20
	local aimX = aimX
	local aimY = aimY
	
	local bulletSpeed = spaceship.lmg.bulletSpeed
											
	local angle = math.atan2((aimY - startY), (aimX - startX))
       
    local bulletDx = bulletSpeed * math.cos(angle)
    local bulletDy = bulletSpeed * math.sin(angle)
									   
	table.insert(spaceship.lmg.bullets, {x = startX, y = startY,w = 1, h = 1, dx = bulletDx, dy = bulletDy})

end

function spawnSINBullet(type)

	local startX = spaceship.x + 66
	local startY = spaceship.y + 20
	
	local bulletSpeed = spaceship.lmg.bulletSpeed
                              
	table.insert(spaceship.SIN.bullets, {x = startX, y = startY, sx = startX, sy = startY, w = 1, h = 1, mathX = 0, type = type, sintime = 0})

end

function spawnMine()

	local startX = spaceship.x + 66
	local startY = spaceship.y + 20
									   
	table.insert(spaceship.lmg.bullets, {x = startX, y = startY,w = 1, h = 1})

end
