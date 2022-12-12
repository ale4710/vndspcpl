return function(mss)
	local errorState = mss:addState('error')
	
	function errorState:enteredState()
		statusIcon.setCurrentState()
		self.pendingStateChanges = {} --empty
	end
	
	function errorState:draw()
		mss.draw(self)
		
		love.graphics.setColor(colora(colors.black, 0.85))
		love.graphics.rectangle('fill', 0, 0, SCREEN.w, SCREEN.h)
		
		love.graphics.setFont(globalFont)
		love.graphics.setColor(colors.white)
		drawScreenCenteredText('An error has occured. Please reset or load a save file.\n(You can open the menu)')
	end

	function errorState:input(action)
		if(action == INPUT_ACTIONS.cancel) then
			game:gotoState('menu')
		end
	end
	
	return errorState
end
