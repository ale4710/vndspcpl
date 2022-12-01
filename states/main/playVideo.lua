local playingVideo
local tempFile

local skipKeyHeldTime
local HOLD_TIME_TO_SKIP = 3

return function(mss)
	local playVideoState = mss:addState('playVideo')

	function playVideoState:enteredState()
		statusIcon.setCurrentState('delay')

		skipKeyHeldTime = 0
		
		local videoInfo = self:nextChange()
		
			newTempFile(gamepath .. '/video/' .. videoInfo.file):and_then(function(handler)
				tempFile = handler
				playingVideo = love.graphics.newVideo(handler.filePath)
				playingVideo:play()
			end)
	end
	
	function playVideoState:draw()
		if(playingVideo) then 
			renderer:clear()
			renderer:draw(
				playingVideo,
				0, 0
			)
			love.graphics.setBlendMode('alpha', 'premultiplied')
			love.graphics.draw(
				renderer.screen,
				unpack(renderer.drawArguments)
			)
			love.graphics.setBlendMode('alpha')
			
			--skip osd
			if(skipKeyHeldTime == 0) then
			else
				statusIcon.sendInfo(skipKeyHeldTime / HOLD_TIME_TO_SKIP)
				UIshortcut.drawStatusIcon()
			end
		end
	end
	
	function playVideoState:update(dt)
		if(tempFile) then
			if(checkInputActionDown(INPUT_ACTIONS.skip)) then 
				self:gotoState(
					self:getChange().state
				)
			elseif(playingVideo) then
				if(
					(not playingVideo:isPlaying()) or
					(skipKeyHeldTime >= HOLD_TIME_TO_SKIP)
				) then 
					self:gotoState(
						self:getChange().state
					)
				else
					if(
						checkInputActionDown(INPUT_ACTIONS.continue) or
						checkInputActionDown(INPUT_ACTIONS.select)
					) then
						skipKeyHeldTime = skipKeyHeldTime + dt
					else
						skipKeyHeldTime = math.max(
							skipKeyHeldTime - (dt * 25),
							0
						)
					end
				end
			end
		end
	end
	
	function playVideoState:exitedState()
		if(playingVideo) then
			playingVideo:pause()
			playingVideo:release()
			playingVideo = nil
			print('release playingVideo')
		end
		
		tempFile:remove()
		tempFile = nil
	end
end