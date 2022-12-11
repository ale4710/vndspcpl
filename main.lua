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
	
	--parse arguments
	require('arguments')(cmdArguments)
	package.loaded['arguments'] = nil
	
	--font
	-- note: fontSize is defined during the parsing of the arguments
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
