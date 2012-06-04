function love.conf(t)
	
	--Titeleinstellungen
		t.title = "Octopussy's Revenge"
		t.author = "Destructive Reality"
	
	--Bildschirmgröße und Grafikeinstellungen
		t.screen.fullscreen = false
		t.screen.width = 800		
		t.screen.height = 600
		t.screen.vsync = false
		t.screen.fsaa = 0
	
	--Kontrollmodule
		t.modules.joystick = false
		t.modules.audio = true
		t.modules.event = true
		t.modules.physics = false
		t.modules.sound = true
	
	--Filesystem
		t.identity = "Octopussy's Revenge"
		
	--Anderes
		t.console = false
end