function onCreate()
    	makeAnimatedLuaSprite('CyberCity', 'queen/city/bg1', -600, -200)
    	addAnimationByPrefix('CyberCity', 'queen/city/bg1', 'bg', 16, true)
	setProperty("CyberCity.scale.x", 1.37);
	setProperty("CyberCity.scale.y", 1.37);
	addLuaSprite('CyberCity', false);
end

