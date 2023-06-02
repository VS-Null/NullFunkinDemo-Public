local doBumping = false
local doCamZoomies = false

function onUpdate(elapsed)
    if curDecBeat > 16.45 then
        doBumping = true
    end

    if curBeat > 29 then
        doCamZoomies = true
    end
end

function onBeatHit()
    if doBumping then
        triggerEvent('bump2', 20, 0.5)
    end

    if doCamZoomies then
        triggerEvent('Add Camera Zoom')
    end
end