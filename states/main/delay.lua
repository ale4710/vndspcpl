local delayStart
local delayLength

return function(mss)
	local delaystate = mss:addState('delay')
	
	function delaystate:enteredState()
		local delayInfo = self:nextChange()
		delayStart = now()
		delayLength = delayInfo.delay
		
		statusIcon.setCurrentState('delay')
		statusIcon.sendInfo(0)
		
		print('[delay] delay for ' .. delayInfo.delay .. ' sec')
	end
	
	function delaystate:input(action)
		if(
			(
				action == INPUT_ACTIONS.continue or
				action == INPUT_ACTIONS.select
			) and
			userSettings.allowSkippingDelays
		) then
			delayStart = -math.huge
		end
	end
	
	function delaystate:update()
		local delayProgress = (now() - delayStart) / delayLength
		
		--print(delayProgress)
		
		statusIcon.sendInfo(delayProgress)
		
		if(
			(delayProgress >= 1) or
			(
				love.keyboard.isDown(unpack(SKIP_INPUTS)) and
				userSettings.allowSkippingDelays
			)
		) then
			print('[delay] goto ' .. self:getChange().state)
			self:gotoState(self:getChange().state)
		end
	end
	
	function delaystate:exitedState()
		delayEnd = nil
	end
end