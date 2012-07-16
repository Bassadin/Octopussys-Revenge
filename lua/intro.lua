
------------------------------------------------------------------ INTRO . LUA ----------------------------------------------------------------------------


-- Create Table
intro = {}



function intro.load()
		
		sx, sy = .85, .85
		sx2, sy2 = 32, 32
		
	-- Load Audio files
		splash = love.audio.newSource("sfx/splash.ogg", stream)
		splash:setVolume(config.soundsVolume)
		
	-- Load Image files
		splashImg = lg.newImage ("gfx/gui/splash.png")
		lovepowered = lg.newImage ("gfx/gui/lovepowered.png")
		
		splash:play()
			
end



function intro.update(dt)

			--Gwee
			pauseMenu.enabled = false
			mainMenu.enabled = false
			highscoreMenu.enabled = false
	
		if fadeAlpha > 0 and timer ~= .75 then
			fadeAlpha = fadeAlpha - 150 * dt
		end

			if fadeAlpha <= 0 then timer = timer + dt
			end
			
				if timer >= .75 then
					timer = .75
					fadeAlpha = fadeAlpha + 150 * dt 
					end
					
				if fadeAlpha < 0 then fadeAlpha = 0 
				elseif fadeAlpha >= 255 then 
				
				gameState = "mainMenu"
				fadeAlpha = 255
				end
				
			-- Logo 1
				if sx < 1 then sx = sx + .1*dt
				elseif sy >= 1 then sx = sx + 10*dt
				end

				if sy < 1 then sy = sy + .1*dt
				elseif sy >= 1 then sy = sy + 10*dt
				end
							
			-- Logo 2
				if sx > .95 and sx2 > 1 then sx2 = sx2 - 36*dt
				end

				if sy > .95 and sy2 > 1 then sy2 = sy2 - 36*dt
				end
				
end



function intro.draw()
		
	-- Draw the Destructive Reality Logo
	lg.setColor(255,255,255)
	lg.draw( splashImg, lg.getWidth() / 2  , lg.getHeight() / 2 , 0,sx,sy, splashImg:getWidth() / 2, splashImg:getHeight() / 2 )
	
	-- Draw the Löve Powered Logo
	if sy > 1 then
		lg.setColor(255,255,255, 255)
		lg.draw(lovepowered, lg.getWidth() / 2  , lg.getHeight() / 2 - lovepowered:getHeight() / 10, .2,sx2,sy2, lovepowered:getWidth() / 2, lovepowered:getHeight() / 2)
	end
	
	lg.setColor(0, 0, 0, fadeAlpha)
	lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
	
end