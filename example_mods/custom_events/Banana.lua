function onCreate()
	makeAnimatedLuaSprite('banana', 'stopeverything', 50, 380);
	setObjectCamera('banana', 'other');
	setScrollFactor('banana', 0, 0);
	addAnimationByPrefix('banana', 'Stop_Everything', 'Stop_Everything', 20, true)
	setProperty('banana.visible', false)
	addLuaSprite('banana',true)
end

function onEvent(name, value1, value2)
    if name == "Banana" then
		setProperty('banana.alpha', value1);
		setProperty('banana.visible', true)
		runTimer('startbana', value2);
	end
end

function onTimerCompleted(tag)
	if tag == 'startbana' then
		setProperty('banana.visible', false)
	end
end