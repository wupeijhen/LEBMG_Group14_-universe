-- End Level Popup
-- A simple popup window with three buttons - menu, restart and next.

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local relayout = require('libs.relayout')
local sounds = require('libs.sounds')

local _M = {}

local newShade = require('classes.shade').newShade

function _M.newEndLevelPopup(params)
	local popup = display.newGroup()
	params.g:insert(popup)

	local background = display.newImageRect(popup, 'images/sidebar.png', 480, 320)
	popup.x, popup.y = relayout._CX, -background.height

	local visualButtons = {}

	local label = display.newText({
		parent = popup,
		text = '',
		x = 0, y = -80,
		font = native.systemFontBold,
		fontSize = 64
	})

	local win = display.newImageRect(popup, 'images/win.png', 480, 320)

	local menuButton = widget.newButton({
		defaultFile = 'images/buttons/home.png',
		overFile = 'images/buttons/home.png',
		width = 48, height = 48,
		x = -80, y = 100,
		onRelease = function()
			sounds.play('tap')
			composer.gotoScene('scenes.menu', {time = 500, effect = 'slideRight'})
		end
	})
	menuButton.isRound = true
	popup:insert(menuButton)
	table.insert(visualButtons, menuButton)

	local restartButton = widget.newButton({
		defaultFile = 'images/buttons/restart.png',
		overFile = 'images/buttons/restart.png',
		width = 48, height = 44,
		x = 0, y = menuButton.y,
		onRelease = function()
			sounds.play('tap')
			composer.gotoScene('scenes.reload_game', {params = params.levelId})
		end
	})
	restartButton.isRound = true
	popup:insert(restartButton)
	table.insert(visualButtons, restartButton)

	-- Don't display the next button if it was the last level
	--if params.levelId < composer.getVariable('levelCount') then
		local nextButton = widget.newButton({
			defaultFile = 'images/buttons/resume.png',
			overFile = 'images/buttons/resume.png',
			width = 48, height = 48,
			x = -menuButton.x, y = menuButton.y,
			onRelease = function()
				sounds.play('tap')
				composer.gotoScene('scenes.reload_game', {params = params.levelId + 1})
			end
		})
		nextButton.isRound = true
		popup:insert(nextButton)
		table.insert(visualButtons, nextButton)
	--end

	local superParams = params
	function popup:show(params)
		-- Shade dims the background and makes it impossible to touch
		self.shade = newShade(superParams.g)
		self:toFront()

		--if params.isWin then
			--label.text = 'YOU win!'
		--else
			--win.isVisible=false
		--end

		controller.setVisualButtons(visualButtons)
		self.x = relayout._CX
		transition.to(self, {time = 250, y = relayout._CY, transition = easing.outExpo, onComplete = function()
			relayout.add(self)
		end})
	end

	return popup
end

return _M
