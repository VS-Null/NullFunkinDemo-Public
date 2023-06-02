function onEvent(name, value1, value2)
	if name == "Subtitles" then
		fade = 0
		setTextString('subtitle', value1)
		setTextColor('subtitle', value2)
        runTimer('subtitlefade', 2, 1)
    end
end

function onCreate()
	fade = 0
	makeLuaText('subtitle', '', 400, 445, 500)
	addLuaText('subtitle')
	setTextSize('subtitle', 40)
end

function onUpdate()
	fade = fade + 1
	if fade > 200 then
		setTextString('subtitle', '')
    end
end