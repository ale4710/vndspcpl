--check the os
if(love) then
	operatingSystem = love.system.getOS()
	
	if(
		operatingSystem == 'Android' or
		operatingSystem == 'iOS'
	) then
		error('Cannot run on mobile.')
	end
else
	error('File must be run with love2d')
end

function love.load(cmdArguments)
	--delete self
	love.load = nil
	
	--libs
	class = require('lib.middleclass')
	stateful = require('lib.stateful')
	--Promise = require('lib.promise')
	require('lib.AndThen')
	utf8 = require('utf8')

	function emptyfn()end
	emptytable = {}
	math.randomseed(os.time())
	now = love.timer.getTime

	colors = require('colors')
	require('constants')
	require('tools')
	require('etc')

	local afl = require('asyncFileLoader')
	io.asqread = afl.load
	_aflCheck = afl.check
	afl = nil

	--stuff
	vnResource = require('loader')
	saveFileManager = require('saveFileManager')
	getZipFileHandler = require('storeZipReader')
	--renderer = require('renderer')
	rendererClass = require('rendererClass')
	variableHandler = require('variableHandler')
	soundHandler = require('soundHandler')
	textbox = require('textbox')
	statusIcon = require('statusIcon')
	UIshortcut = require('drawUiShortcut')
	--love.keyboard.setKeyRepeat(true)
	collectgarbage('setstepmul', 400)

	--window
	windowTitleAdditional = ' [VNDS PC Player]'
	function updateWindowTitle(text)
		love.window.setTitle(text .. windowTitleAdditional)
	end
	
	--initialize some settings
	userSettings = {
		oneSoundEffectOnly = false,
		--whether or not multiple sound effects are allowed to be played
		
		textBoxMode = 1,
		--  how will the textbox be display **on startup**?
		--  (it can be changed during gameplay.)
		--0 = fullscreen
		--1 = bottom
		--2 = top
		
		textProgressionSpeed = 0.005,
		--  how fast will the text progress?
		--it is how many seconds each character will get.
		
		textScale = 0.4,
		--  scale factor of text.
		
		hideTextBoxWhenEmpty = true,
		
		ignoreNovelFont = false,
		
		allowSkippingTransitions = true,
		
		allowSkippingDelays = true,
		
		maxCacheEntries = 50,
		--  it is how many resources can be cached at one time
		
		hideMouseOnInactivity = true,
		
		hideDelayTimer = false,
		
		hideLoadingIndicator = false,
		
		hideAwaitingUserIndicator = false
	}
	fontSize = 64

	--parsing arguments
	do
		local flagActions = {
			['window-title-additional'] = {
				after = (function(title)
					if(#title ~= 0) then 
						title = ' ' .. title
					end
					windowTitleAdditional = title
				end)
			},
			
			['one-sound-effect-only'] = {
				during = (function()
					userSettings.oneSoundEffectOnly = true
				end)
			},
			
			['base-font-size'] = {
				after = (function(size)
					fontSize = tonumber(size) or fontSize
				end)
			},
			
			['text-box-mode'] = {
				after = (function(mode)
					userSettings.textBoxMode = math.clamp(
						0, 2, 
						math.floor(
							tonumber(mode) or userSettings.textBoxMode
						)
					)
				end)
			},
			
			['text-progression-speed'] = {
				after = (function(sec)
					userSettings.textProgressionSpeed = tonumber(sec) or userSettings.textProgressionSpeed
				end)
			},
			
			['text-scale'] = {
				after = (function(scale)
					userSettings.textScale = tonumber(scale) or userSettings.textScale
				end)
			},
			
			['show-textbox-when-empty'] = {
				during = (function()
					userSettings.hideTextBoxWhenEmpty = false
				end)
			},
			
			['ignore-novel-font'] = {
				during = (function()
					userSettings.ignoreNovelFont = true
				end)
			},
			
			['disallow-skipping-transitions'] = {
				during = (function()
					userSettings.allowSkippingTransitions = false
				end)
			},
			
			['disallow-skipping-delays'] = {
				during = (function()
					userSettings.allowSkippingDelays = false
				end)
			},
			
			['maximum-cache-entries'] = {
				after = (function(e)
					userSettings.maxCacheEntries = tonumber(e) or userSettings.maxCacheEntries
				end)
			},
			
			['keep-mouse-visible'] = {
				during = (function()
					userSettings.hideMouseOnInactivity = false
				end)
			},
			
			['hide-delay-timer'] = {
				during = (function()
					userSettings.hideDelayTimer = true
				end)
			},
			
			['hide-loading-indicator'] = {
				during = (function()
					userSettings.hideLoadingIndicator = true
				end)
			},
			
			['hide-awaiting-user-indicator'] = {
				during = (function()
					userSettings.hideAwaitingUserIndicator = true
				end)
			},

			['debug-overlay'] = {
				during = (function()
					debugOverlay = require('debugOverlay')
				end)
			}
		}
		local lastFlagAction
		
		for argOrder, arg in ipairs(cmdArguments) do
			if(lastFlagAction) then
				if(type(lastFlagAction) == 'function') then 
					lastFlagAction(arg)
				end
				lastFlagAction = nil
			else
				if(argOrder == #cmdArguments) then
					gamepath = arg
				else
					local fa = flagActions[arg:sub(3)]
					if(fa) then
						if(fa.during) then
							fa.during()
						end

						lastFlagAction = fa.after
					end
				end
			end
		end
	end
	
	--font
	globalFont = love.graphics.newFont('resources/font/default.ttf', fontSize)
	font = globalFont
	
	textbox.calculateSizes()
	SCREEN.resizeEvent:add(
		textbox.calculateSizes
	)
	
	--icon
	love.window.setIcon(
		love.image.newImageData('resources/image/icon.png')
	)
	
	--game and gameclass
	gameclass = class('game'):include(stateful)
	gameclass.update = emptyfn
	gameclass.draw = emptyfn
	gameclass.input = emptyfn
	gameclass.rawInput = emptyfn

	states = {}
	for _, state in pairs({
		'boot',
		'main',
		'loadsave',
		'waiting'
	}) do
		states[state] = require('states.' .. state)
	end

	game = gameclass:new()
	
	--script handler
	scriptHandler = require('scriptHandler')
	
	--input...
	require('input')
	
	--set callbacks
	function love.draw()
		game:draw()
		if(debugOverlay) then debugOverlay.draw() end
	end

	function love.update(dt)
		_aflCheck()
		_zipOperationsCheck()
		_processingCheck()
		saveFileManager.update()
		_tempFilePeriodicDelete()
		soundHandler.update()

		game:update(dt)
		textbox.update(dt)
		statusIcon.update(dt)
		_sldmcUpdate(dt)
		_updateMouseVisibility()
		
		_andThenPendingCheck()
	end
	
	function love.quit()
		local buttonPressed = messageBoxWS(
			'Quit The Game',
			'Are you sure you wish to quit? Unsaved progress will be lost.',
			{
				'Quit',
				'Cancel',
				
				enterbutton = 2,
				escapebutton = 2
			},
			'warning'
		)
		
		local quit = (buttonPressed == 2)
		
		if(quit) then 
			_tempFilePeriodicDelete(true)
		end
		
		return quit
	end
	
	--begin loading data
	if(gamepath) then
		game:gotoState('boot')
	else
		game:gotoState('waiting')
	end
end