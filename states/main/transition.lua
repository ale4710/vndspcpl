local newscreen
local fadelength
local currentOpacity

return function(mss)
	local transitionstate = mss:addState('transition')
	
	function transitionstate:enteredState()
		newscreen = love.graphics.newImage(renderer:get())
		fadelength = self:nextChange().delay or 0
		currentOpacity = 0
		
		statusIcon.setCurrentState()
		
		print('[transitionState] screen fade for ' .. fadelength .. 'sec (' .. (fadelength * 60) .. ' frames)')
	end
	
	function transitionstate:input(action)
		if(
			(
				action == INPUT_ACTIONS.continue or
				action == INPUT_ACTIONS.select
			) and
			userSettings.allowSkippingTransitions
		) then
			currentOpacity = 1
		end
	end
	
	function transitionstate:update(dt)
		if(
			love.keyboard.isDown(unpack(SKIP_INPUTS)) and
			userSettings.allowSkippingTransitions
		) then
			currentOpacity = 1
		else
			currentOpacity = currentOpacity + (dt / fadelength)
		end
		
		if(currentOpacity >= 1) then 
			self:gotoState(self:getChange().state)
		end
	end
	
	function transitionstate:draw()
		love.graphics.setColor(colors.white)
		mss.drawScreen(self)
		love.graphics.setColor(colora(colors.white, currentOpacity))
		mss.drawScreen(self, newscreen)
		UIshortcut.drawAll()
	end
	
	function transitionstate:exitedState()
		if(self.screen) then 
			self.screen:release() 
		end
		self.screen = newscreen
		newscreen = nil
		--print('[transitionState] fade complete')
	end
end