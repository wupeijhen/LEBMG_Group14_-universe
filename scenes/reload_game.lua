-- This a helper buffer scene.
-- It reloads game scene (game scene can't reload by itself) and shows a loading animation.

local composer = require('composer')
local relayout = require('libs.relayout')

local scene = composer.newScene()

function scene:create()
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

    local group = self.view

    local background = display.newRect(group, _CX, _CY, _W, _H)
    background.fill = {
        type = 'gradient',
        color1 = {255, 255, 255},
        color2 = {255, 255, 255}
    }
    relayout.add(background)


    local swordsGroup = display.newGroup()
	swordsGroup.x, swordsGroup.y = _CX, _CY
	group:insert(swordsGroup)
	relayout.add(swordsGroup)

    -- Display three revolving cannon balls
    for i = 0, 2 do
        local swords = display.newImageRect(swordsGroup, 'images/ammo/normal.png', 29, 50)
        swords.x, swords.y = 0, 0
        swords.anchorX = 2
        swords.rotation = 120 * i
        transition.to(swords, {time = 1500, rotation = 360, delta = true, iterations = -1})
    end
end

function scene:show(event)
    if event.phase == 'will' then
        -- Preload the scene
        composer.loadScene('scenes.game', {params = event.params})
    elseif event.phase == 'did' then
        -- Show it after a moment
        timer.performWithDelay(500, function()
            composer.gotoScene('scenes.game', {params = event.params})
        end)
    end
end

scene:addEventListener('create')
scene:addEventListener('show')

return scene
