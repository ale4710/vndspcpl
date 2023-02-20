local mn = ...

local menuState = gameclass:addState('menu')

local bgColor = {colora(colors.black, 0.75)}
local textColor = colors.white
local bgColorSelected = {colora(colors.white, 0.75)}
local textColorSelected = colors.black
local textScale = 1
local headerTextScale = 1.5
local menuWidth = SCREEN.w * 0.3
local headerPadding = 8
local paddingLeft = 15

--menu actions
local MenuAction = class('MenuAction')
function MenuAction:initialize(label) 
	self.label = label
end
function MenuAction:getLabel()
	return self.label or 'No Label'
end

local menuActions = {}

do --reset
	local e = MenuAction:new('Reset')
	function e:execute() 
		mainReset()
		return true
	end
	menuActions['reset'] = e
	e = nil
end

do --cycle textbox
	local e = MenuAction:new('Cycle Textbox')
	function e:execute() 
		local tdm = userSettings.textBoxMode + 1
		if(tdm > 2) then
			tdm = 0
		end
		userSettings.textBoxMode = tdm
	end
	menuActions['cycletextbox'] = e
	e = nil
end

do --save file man
	local e = MenuAction:new('Save File Manager')
	function e:execute() 
		game:gotoState('loadsave')
	end
	menuActions['saveload'] = e
	e = nil
end

do --quit
	local e = MenuAction:new('Quit')
	function e:execute() 
		love.event.quit()
		return true
	end
	menuActions['quit'] = e
	e = nil
end

do --volume control
	local VcClass = MenuAction:subclass('MenuActionVolumeControl')
	
	function VcClass:getVolume()
		return soundHandler['get' .. self.spacename .. 'Volume']()
	end
	function VcClass:changeVolume(up)
		--form name for change function thing
		local newVolume = math.clamp(0, 100,
			--current volume
			(self:getVolume() * 100) +
			--change
			(((up and 1) or -1) * 5)
		) / 100
		
		soundHandler['set' .. self.spacename .. 'Volume'](newVolume)
	end
	function VcClass:getLabel()
		return self.label .. ' (' .. math.floor(self:getVolume() * 100) .. '%)'
	end
	function VcClass:initialize(label, soundSpace)
		MenuAction.initialize(self, label)
		self.spacename = soundSpace
	end
	function VcClass:horizontalMovement(move) 
		self:changeVolume(move == 1)
	end
	
	menuActions['musctrl'] = VcClass:new('Music', 'Bgm')
	menuActions['sfxctrl'] = VcClass:new('Sounds', 'Sfx')
end
--end menu actions
local menuOrder = {
	'saveload',
	'musctrl',
	'sfxctrl',
	'cycletextbox',
	'reset',
	'quit'
}

local navigator = navigatorClass:new()
navigator.total = #menuOrder

function menuState:enteredState()
	navigator:jump(1)
end

function menuState:input(action)
	local selectedEntry = menuActions[menuOrder[navigator.current]]

	do --movement
		local move = INPUT_NAVIGATION_LIST_HELPER[action]
		if(move) then
			if(move.vertical) then
				navigator:move(move.move)
			elseif(
				selectedEntry and 
				selectedEntry.horizontalMovement
			) then
				selectedEntry:horizontalMovement(move.move)
			end
			return
		end
	end
	
	--select
	local quit
	if(
		selectedEntry and
		(action == INPUT_ACTIONS.select)
	) then 
		quit = selectedEntry:execute()
		if(not quit) then return end
	end
	
	--quit
	if(
		(action == INPUT_ACTIONS.cancel) or
		quit
	) then 
		self:gotoState('main')
		return
	end
end

function menuState:draw() 
	states['main']:draw()
	--background
	love.graphics.setColor(colora(colors.black, 0.75))
	love.graphics.rectangle(
		'fill', 
		0, 0,
		menuWidth,
		SCREEN.h
	)
	
	--text
	local textScale = userSettings.textScale * textScale
	local headerTextScale = userSettings.textScale * headerTextScale
	
	love.graphics.setFont(globalFont)
	
	--header
	love.graphics.setColor(textColor)
	love.graphics.print('Menu', paddingLeft, headerPadding, 0, headerTextScale)
	local paddingTop = (globalFont:getHeight() * headerTextScale) + (headerPadding * 2)
	--optins
	local optionHeight = globalFont:getHeight() * textScale
	for index, actionName in ipairs(menuOrder) do 
		local y = paddingTop + (optionHeight * (index - 1))
		local selected = (navigator.current == index)
		--cursor
		if(selected) then 
			love.graphics.setColor(bgColorSelected)
			love.graphics.rectangle(
				'fill',
				0,
				y,
				menuWidth,
				optionHeight
			)
		end
		--text
		love.graphics.setColor(
			(selected and textColorSelected) or
			textColor
		)
		love.graphics.print(
			menuActions[actionName]:getLabel(),
			paddingLeft,
			y,
			0,
			textScale
		)
	end
end

return menuState
