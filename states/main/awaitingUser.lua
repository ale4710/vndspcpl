return function(mss)
	local awaitingUserState = mss:addState('awaitingUser')
	
	function awaitingUserState:enteredState()
		statusIcon.setCurrentState()
		
		saveFileManager.updateSaveFile(
			nil,
			currentLine
		)
		
		self:nextChange()
	end
	
	local function proceed(self)
		if(textbox.animator.checkDone()) then 
			self:gotoState(
				self:getChange().state
			)
		else
			textbox.animator.forceDone()
		end
	end
	
	function awaitingUserState:input(action)
		if(
			action == INPUT_ACTIONS.continue or
			action == INPUT_ACTIONS.select
		) then 
			proceed(self)
		elseif(action == INPUT_ACTIONS.cancel) then
			game:gotoState('loadsave')
		end
	end
	
	function awaitingUserState:update()
		if(textbox.animator.checkDone()) then 
			statusIcon.setCurrentState('awaitingUser')
		end
	
		if(love.keyboard.isDown(unpack(SKIP_INPUTS))) then 
			proceed(self)
		end
	end
	
	function awaitingUserState:exitedState()
		
	end
	
	return awaitingUserState
end