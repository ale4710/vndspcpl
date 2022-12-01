return function(mss)
	local fgvstate = mss:addState('flushGlobalVariables')
	
	function fgvstate:enteredState()
		self:nextChange()
		
		statusIcon.setCurrentState('fileOperation')
		statusIcon.sendInfo(true)
		
		variableHandler.global.flush(function()
			self:gotoState(
				self:getChange().state
			)
		end)
	end
end