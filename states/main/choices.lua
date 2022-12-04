local choices

local choiceTop

local selected

local choicesHeight

local buttonPadding = 5 / userSettings.textScale
local buttonMargin = 5 / userSettings.textScale

local buttonColors = {
	focus = {
		fg = colors.black,
		bg = {colora(colors.white, 0.75)}
	},
	
	normal = {
		fg = colors.white,
		bg = {colora(colors.black, 0.75)}
	}
}

local screen
local function resizeScreen()
	screen = love.graphics.newCanvas(
		(SCREEN.w / userSettings.textScale) - (buttonMargin * 2),
		SCREEN.h / userSettings.textScale
	)
end
SCREEN.resizeEvent:add(resizeScreen)
resizeScreen()

local function redraw()
	love.graphics.setCanvas(screen)
	love.graphics.clear()
	
	local fontHeight = font:getHeight()
	local textWidthLimit = screen:getWidth() - (buttonPadding * 2)
	local totalMoved = 0
	
	love.graphics.setFont(font)
	
	for index, choice in ipairs(choices) do
		local sc = buttonColors[
			((index == selected) and 'focus') or
			'normal'
		]
		
		local textOccupyHeight
		do 
			local _, tl = font:getWrap(choice, textWidthLimit)
			textOccupyHeight = #tl * fontHeight
		end
		
		local buttonHeight = textOccupyHeight + (buttonPadding * 2)

		love.graphics.setColor(sc.bg)
		love.graphics.rectangle(
			'fill', 
			0, 
			totalMoved,
			screen:getWidth(),
			buttonHeight
		)
		
		love.graphics.setColor(sc.fg)
		love.graphics.printf(
			choice,
			buttonPadding,
			totalMoved + buttonPadding,
			textWidthLimit,
			'center'
		)

		totalMoved = totalMoved + buttonHeight + buttonMargin
	end
	love.graphics.setCanvas()
	
	--totalMoved = totalMoved - buttonMargin
	
	choicesHeight = totalMoved - buttonMargin
end

return function(mss)
	local choicesState = mss:addState('choices')
	
	function choicesState:enteredState()
		statusIcon.setCurrentState()
	
		choices = self:nextChange().choices
		
		selected = 1
		redraw()
		
		saveFileManager.updateSaveFile(
			nil,
			currentLine
		)
	end
	
	function choicesState:draw()
		--mss.draw(self)
		love.graphics.setColor(colors.white)
		mss.drawScreen(self)
	
		love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.draw(
			screen,
			buttonMargin * userSettings.textScale,
			(SCREEN.h / 2) - ((choicesHeight / 2) * userSettings.textScale),
			0,
			userSettings.textScale
		)
		love.graphics.setBlendMode('alpha')
	end

	function choicesState:input(action)
		local movement = INPUT_NAVIGATION_LIST_HELPER[action]
		if(movement and movement.vertical) then
			selected = selected + movement.move
			if(not choices[selected]) then 
				selected = selected + (#choices * -movement.move)
			end
			redraw()
		end
		
		movement = nil
		
		if(action == INPUT_ACTIONS.select) then
			variableHandler.variables['selected'] = selected
			self:gotoState(
				self:getChange().state
			)
		elseif(action == INPUT_ACTIONS.cancel) then
			game:gotoState('loadsave')
		end
	end
	
	function choicesState:exitedState()
		choices = nil
	end
	
	return choicesState
end
