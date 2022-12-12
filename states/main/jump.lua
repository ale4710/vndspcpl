local nextLabel

return function(mss)
	local jumpState = mss:addState('jump')

	function jumpState:enteredState()
		statusIcon.setCurrentState()
		
		local jumpInfo = self:nextChange()
		
		print('[jumpState] jumping! pounding the rock')
		
		if(jumpInfo.label) then 
			print('[jumpState] the next label is ' .. jumpInfo.label) 
		end

		if(jumpInfo.file) then 
			nextLabel = jumpInfo.label
			print('[jumpState] loading '..jumpInfo.file)
			statusIcon.setCurrentState('fileOperation')
			statusIcon.sendInfo(false)
			saveFileManager.updateSaveFile(jumpInfo.file)
			vnResource.get('script', jumpInfo.file):and_then(function(script)
				assert(script, '[jumpState] script could not be found!')
				scriptHandler.loadScript(script)
				if(nextLabel) then
					local success = scriptHandler.jumpToLabel(nextLabel)
					if(not success) then 
						print('[jumpState] warning! label "' .. nextLabel .. '" was not found!')
					end
				end
				self:gotoState(self:getChange().state)
			end):catch(function()
				messageBoxWS(
					'Fatal Error',
						'Fatal Error: Failed to find file ' .. 
						(
							((type(jumpInfo.file) == 'string') and jumpInfo.file) or 
							'(nil)'
						),
					'error'
				)
				self:gotoState('error')
			end)
		else
			scriptHandler.jumpToLabel(jumpInfo.label)
			self:gotoState(self:getChange().state)
			
		end
	end
	
	function jumpState:exitedState()
		nextLabel = nil
	end
end