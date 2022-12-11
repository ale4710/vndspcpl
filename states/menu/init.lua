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

local menuActions = {
	['reset'] = {
		fn = (function()end),
		label = 'Reset'
	},
	['saveload'] = {
		fn = (function(self)
			self:gotoState('loadsave')
			--game:gotoState('loadsave')
		end),
		label = 'Save File Manager'
	},
	['cycletextbox'] = {
		fn = (function()
			local tdm = userSettings.textBoxMode + 1
			if(tdm > 2) then
				tdm = 0
			end
			userSettings.textBoxMode = tdm
			--return true
		end),
		label = 'Text Display'
	}
}
local menuOrder = {
	'saveload',
	'cycletextbox',
	'reset'
}

local navigator = navigatorClass:new()
navigator.total = #menuOrder

function menuState:enteredState()
	navigator:jump(1)
end

function menuState:input(action)
	do --movement
		local move = INPUT_NAVIGATION_LIST_HELPER[action]
		if(
			move and
			move.vertical
		) then 
				navigator:move(move.move)
				return
		end
	end
	
	--select
	local quit
	if(action == INPUT_ACTIONS.select) then 
		quit = menuActions[menuOrder[navigator.current]].fn(self)
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
			menuActions[actionName].label,
			paddingLeft,
			y,
			0,
			textScale
		)
	end
end

return menuState
