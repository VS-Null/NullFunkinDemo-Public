local shakeAmount = 0

local defaultNotePos = {}

local isOpponent = true

-- ALTER/GUILTY! be like..
function onCreatePost()
	for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
		--remember first in array is 1: x = 1, y = 2
    end
end

function onUpdatePost()
	sussy = 7
	if isOpponent then
		sussy = 3
	end

	for i=0,sussy do
		setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + math.random(-shakeAmount, shakeAmount))
		setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + math.random(-shakeAmount, shakeAmount))
	end
end

function onEvent(name, value1, value2)
	if name == "ShakeyStrums" then
		shakeAmount = tonumber(value1)
		if value2 == 'true' or value2 == '' or value2 == nil then 
			isOpponent = true
		else
			isOpponent = false
		end
	end
end