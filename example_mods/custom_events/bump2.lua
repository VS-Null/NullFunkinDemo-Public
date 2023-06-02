--ALTER be like

local defaultNotePos = {}

function onCreatePost()
    for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
        --remember first in array is 1: x = 1, y = 2
    end
end

function onEvent(name, val1, val2)
    if name == "bump2" then
        bump(tonumber(val1), tonumber(val2))
    end
end

function bump(gap,delay)
	for i = 0, 7 do
		amountX = gap * ((i % 4) - 1.5)
		setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + amountX)
		noteTweenX("bumpIn"..i, i, defaultNotePos[i + 1][1], delay, 'quadOut')
	end
end