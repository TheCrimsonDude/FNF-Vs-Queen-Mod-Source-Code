function onCreate()
		makeAnimatedLuaSprite('CityView', 'queen/hall/bg2', -600, -200)
		addAnimationByPrefix('CityView', 'queen/hall/bg2', 'bg ', 16, true)
		setProperty("CityView.scale.x", 1.56);
		setProperty("CityView.scale.y", 1.56);
		addLuaSprite('CityView', false);
end	