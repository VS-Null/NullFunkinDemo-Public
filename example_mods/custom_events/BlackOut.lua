function onEvent(name, value1, value2)
	if name == 'BlackOut' then
		if value1 == 'true' then
		makeLuaSprite('BlackFlash', 'BlackFlash', -700, 0);
		scaleObject('BlackFlash', 18, 22);
		addLuaSprite('BlackFlash', true)
		setProperty('BlackFlash.visible', true);
		elseif value1 == 'false' then
		setProperty('BlackFlash.visible', false)
			end
		end
	end