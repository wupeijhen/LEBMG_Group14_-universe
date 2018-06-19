-- Sidebar
-- This is a narrow vertical bar, that appears on the left side of the screen and provides the player five buttons:
-- resume, restart, menu, music and sounds.

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local databox = require('libs.databox')
local overscan = require('libs.overscan')
local relayout = require('libs.relayout')
local sounds = require('libs.sounds')

local _M = {}

local newShade = require('classes.shade').newShade

function _M.newSidebar(params)
	local _W, _CX, _CY = relayout._W, relayout._CX, relayout._CY

	local sidebar = display.newGroup()
	params.g:insert(sidebar)

	local background = display.newImageRect(sidebar, 'images/sidebar.png', 480, 320)
	sidebar.x, sidebar.y = _CX, -background.height
	background:toFront()


	local visualButtons = {}

	local spacing = background.width / 5 + 25
	local start = -background.width / 2 + spacing / 2 

	local resumeButton = widget.newButton({
		defaultFile = 'images/buttons/resume.png',
		overFile = 'images/buttons/resume.png',
		width = 48, height = 48,
		x = start, y = 0,
		onRelease = function()
			sounds.play('tap')
			sidebar:hide()
		end
	})
	resumeButton.isRound = true
	sidebar:insert(resumeButton)
	table.insert(visualButtons, resumeButton)

    if params.levelId then
		local restartButton = widget.newButton({
			defaultFile = 'images/buttons/restart.png',
			overFile = 'images/buttons/restart.png',
			width = 48, height = 44,
			x = start + spacing, y = 0,
			onRelease = function()
				sounds.play('tap')
				composer.gotoScene('scenes.reload_game', {params = params.levelId})
			end
		})
		restartButton.isRound = true
		sidebar:insert(restartButton)
		table.insert(visualButtons, restartButton)

		local menuButton = widget.newButton({
			defaultFile = 'images/buttons/home.png',
			overFile = 'images/buttons/home.png',
			width = 48, height = 48,
			x = start + spacing * 2, y = 0,
			onRelease = function()
				sounds.play('tap')
				composer.gotoScene('scenes.menu', {time = 500, effect = 'slideRight'})
			end
		})
		menuButton.isRound = true
		sidebar:insert(menuButton)
		table.insert(visualButtons, menuButton)
	end

	local musicButtons = {}

	-- When changing music on sounds, we need to show/hide corresponding buttons and save the value into the databox
	local function updateDataboxAndVisibility()
		databox.isSoundOn = sounds.isSoundOn
		databox.isMusicOn = sounds.isMusicOn

		musicButtons.on.isVisible = false
		musicButtons.off.isVisible = false

		if databox.isMusicOn then
			musicButtons.on.isVisible = true
		else
			musicButtons.off.isVisible = true
		end
	end

	musicButtons.on = widget.newButton({
		defaultFile = 'images/buttons/music_on.png',
		overFile = 'images/buttons/music_on.png',
		width = 48, height = 48,
		x = start + spacing * 3, y = 0,
		onRelease = function()
			sounds.play('tap')
			sounds.isMusicOn = false
			sounds.isSoundOn = false
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(musicButtons.off)
			end
			sounds.stop()
		end
	})
	musicButtons.on.isRound = true
	sidebar:insert(musicButtons.on)
	table.insert(visualButtons, musicButtons.on)

	musicButtons.off = widget.newButton({
		defaultFile = 'images/buttons/music_off.png',
		overFile = 'images/buttons/music_off.png',
		width = 48, height = 48,
		x = musicButtons.on.x, y = 0,
		onRelease = function()
			sounds.play('tap')
			sounds.isMusicOn = true
			sounds.isSoundOn = true
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(musicButtons.on)
			end
			if params.levelId then
				sounds.playStream('game_music')
			else
				sounds.playStream('menu_music')
			end
		end
	})
	musicButtons.off.isRound = true
	sidebar:insert(musicButtons.off)
	table.insert(visualButtons, musicButtons.off)

	updateDataboxAndVisibility()


	
	function sidebar:show()
		self.shade = newShade(params.g)
		self:toFront()

		controller.setVisualButtons(visualButtons)
		if params.levelId then
			databox.isHelpShown = true
		end
		transition.to(self, {time = 250, y = background.height / 2, transition = easing.outExpo})
	end

	function sidebar:hide()
		self.shade:hide()
		transition.to(self, {time = 250, y = -background.height, transition = easing.outExpo, onComplete = params.onHide})
	end

	function sidebar:relayout()
		sidebar.x = relayout._CX
	end

	relayout.add(sidebar)

	return sidebar
end

return _M
