-- Menu Scene
-- Displays game's name, the cannon and a couple buttons.

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local relayout = require('libs.relayout')
local sounds = require('libs.sounds')

local scene = composer.newScene()

-- Settings sidebar
local newSidebar = require('classes.sidebar').newSidebar

function scene:create()
	local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local group = self.view

	local Background = display.newImageRect( 'Images/Background/background01.png', 480, 320 )
	Background.x = _CX
	Background.y = _CY
	Background:toBack()
	group:insert(Background)

	self.playButton = widget.newButton({
		defaultFile = 'images/buttons/play.png',
		overFile = 'images/buttons/play.png',
		width = 105, height = 60,
		x = 400 - 300, y = -200 - 100,
		onRelease = function()
			sounds.play('tap')
			composer.gotoScene('scenes.level_select', {time = 500, effect = 'fade'})
		end
	})

	self.exitButton = widget.newButton({
		defaultFile = 'images/buttons/exit.png',
		overFile = 'images/buttons/exit.png',
		width = 105, height = 60,
		x = 400 - 20, y = -200 - 100,
		onRelease = function()
			sounds.play('tap')
			os.exit ( )
		end
	})
	group:insert(self.playButton)
	group:insert(self.exitButton)

	transition.to(self.playButton, {time = 2000, y = _H - 128 - self.playButton.height / 2, transition = easing.inExpo, onComplete = function(object1)
			relayout.add(object1)
		end})

	transition.to(self.exitButton, {time = 2000, y = _H - 128 - self.exitButton.height / 2, transition = easing.inExpo, onComplete = function(object2)
			relayout.add(object2)
		end})

	local sidebar = newSidebar({g = group, onHide = function()
		self:setVisualButtons()
	end})

	self.settingsButton = widget.newButton({
		defaultFile = 'images/buttons/settings.png',
		overFile = 'images/buttons/settings-over.png',
		width = 48, height = 52,
		x = _CX+200, y = _CY+120,
		onRelease = function()
			sounds.play('tap')
			sidebar:show()
		end
	})
	self.settingsButton.isRound = true
	group:insert(self.settingsButton)
	--relayout.add(self.settingsButton)

	self:setVisualButtons()
	sounds.playStream('menu_music')
end

function scene:setVisualButtons()
	controller.setVisualButtons({self.playButton, self.settingsButton})
end

-- Android's back button action
function scene:gotoPreviousScene()
		if event.action == 'clicked' and event.index == 1 then
			native.requestExit()
		end
end

function scene:show(event)
	if event.phase == 'did' then
		-- Tell tvOS that the menu button should be handled by the OS and exit the app
		system.activate('controllerUserInteraction')
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		-- Take control over the menu button on tvOS
		system.deactivate('controllerUserInteraction')
	end
end

scene:addEventListener('create')
scene:addEventListener('show')
scene:addEventListener('hide')

return scene
