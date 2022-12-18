local pendingDraw
local pendingVideo
local pendingSfx
local stopExistingSounds
local pendingBgm
local stopExistingBgm
local pendingChoices
local lPendingText
local nextLabel
local latestAction
local pendingFileOperation

local saveFileSprites

--actions...
local actionFns = {}
actionFns['image'] = function(at)
	local isBg = (at.ground == 'background')
	
	local promise = vnResource.get(at.ground, at.path):and_then(function(image)
		return {
			x = at.x,
			y = at.y,
			image = image,
			isBackground = isBg
		}
	end):catch(function()
		if(isBg) then
			return {isBackground = true}
		end
	end)
	
	if(isBg) then
		table.insert(pendingDraw, 1, promise)
		saveFileManager.updateSaveFile(nil, nil, nil, at.path or '')
	else
		if(not saveFileSprites) then
			saveFileSprites = {}
		end
		table.insert(pendingDraw, promise)
		table.insert(saveFileSprites, {
			path = at.path,
			x = at.x,
			y = at.y
		})
	end
	
	pendingFileOperation = true
end

actionFns['video'] = function(at)
	stopExistingBgm = true
end

actionFns['sfx'] = function(at)
	if(at.stopSound) then 
		--empty previous sounds...
		pendingSfx = {}
		stopExistingSounds = true
	else
		pendingFileOperation = true
		local sndPromise = vnResource.get('sound', at.path):and_then(function(sound)
			return Promise({
				loops = at.loops,
				sound = sound
			})
		end)
		table.insert(pendingSfx, sndPromise)
	end
end

actionFns['bgm'] = function(at)
	if(at.stopSound) then
		pendingBgm = nil
		stopExistingBgm = true
		saveFileManager.updateSaveFile(nil, nil, '')
	else
		pendingFileOperation = true
		saveFileManager.updateSaveFile(nil, nil, at.path or '')
		pendingBgm = vnResource.get('sound', at.path):and_then(function(bgm)
			pendingBgm = bgm
		end):catch(function()
			pendingBgm = nil
		end)
	end
end

actionFns['choices'] = function(at)
	pendingChoices = at.choices
end

actionFns['text'] = function(at)
	if(not lPendingText) then
		lPendingText = {}
	end
	table.insert(lPendingText, at)
end

do 
	local function snl(label)
		nextLabel = label
	end
	
	actionFns['jump'] = function(at)
		nextFile = at.file
		snl(at.label)
	end

	actionFns['goto'] = function(at) 
		snl(at.label)
	end
end

--state stuff
local stopActionsToState = {
	['text'] = (function()
		local t = {state = 'awaitingUser'}
		return function() return t end
	end)(),

	['choices'] = (function()
		return {
			state = 'choices',
			choices = latestAction.choices
		}
	end),
	
	['jump'] = (function() 
		return {
			state = 'jump',
			file = latestAction.file,
			label = latestAction.label
		}
	end),
	
	['goto'] = (function() 
		return {
			state = 'jump',
			label = latestAction.label
		}
	end),
	
	['video'] = (function()
		return {
			state = 'playVideo',
			file = latestAction.file,
			fade = latestAction.fade
		}
	end)
}

--main stuff
return function(mss)
	local progressingState = mss:addState('progressing')
	
	function progressingState:enteredState()
		--forward change
		self:nextChange()
		
		--setup...
		pendingDraw = {}
		pendingSfx = {}
		stopExistingSounds = false
		--pendingBgm = nil
		stopExistingBgm = false
		--pendingChoices = nil
		--lPendingText = {}
		--nextLabel = nil
		--latestAction = nil
		pendingFileOperation = false
		
		currentCycle = scriptHandler.progress()
		latestAction = currentCycle[#currentCycle]
		for index, action in ipairs(currentCycle.actions) do
			local actionFn = actionFns[action.type]
			if(actionFn) then
				--man i really wish lua had switches
				actionFn(action)
			else
				print('[progressing state] unhandled action "' .. (action.type or '(nil)') .. '"')
			end
			
			if(index == #currentCycle.actions) then 
				latestAction = action
			end
		end
		
		--set icon
		if(pendingFileOperation) then
			statusIcon.setCurrentState('fileOperation')
			statusIcon.sendInfo(false)
		else
			statusIcon.setCurrentState()
		end
		
		local promiseWaitingAll = {}
		
		--graphics
		if(#pendingDraw ~= 0) then
			--if we are here then the screen updated
			--update save file
			--note: the background has already been updated
			saveFileManager.updateSaveFile(
				nil, nil, nil, nil,
				saveFileSprites or emptytable
			)
			saveFileSprites = nil
		
			--promises
			local dp = Promise(pendingDraw):all_settled():and_then(function(images)
				for _, imgInfo in ipairs(images) do 
					imgInfo = imgInfo.value
					if(imgInfo) then
						local params
						if(imgInfo.isBackground) then 
							renderer:clear()
							if(userSettings.centerBackgrounds) then
								params = {'center'}
							else
								params = {0, 0}
							end
						else
							params = {
								imgInfo.x,
								imgInfo.y
							}
						end
						
						if(imgInfo.image) then 
							renderer:draw(
								imgInfo.image,
								unpack(params)
							)
						end
					end
				end
			end)
			
			table.insert(promiseWaitingAll, dp)
		end
		
		--sounds
		if(#pendingSfx ~= 0) then
			local sp = Promise(pendingSfx):all_settled():and_then(function(sfxs)
				pendingSfx = {}
				for _, sfxInfo in pairs(sfxs) do 
					sfxInfo = sfxInfo.value
					if(
						sfxInfo and
						sfxInfo.sound
					) then 
						table.insert(
							pendingSfx,
							sfxInfo
						)
					end
				end
			end)
			
			table.insert(promiseWaitingAll, sp)
		end
		
		--bgm
		if(pendingBgm) then
			if(pendingBgm.and_then) then 
				--it is promise
				table.insert(promiseWaitingAll, pendingBgm)
			end
		end
		
		--everything
		local mainPromise
		if(#promiseWaitingAll ~= 0) then
			mainPromise = Promise(promiseWaitingAll):all_settled()
		else
			mainPromise = Promise()
		end
		
		mainPromise:and_then(function()
			--graphics
			--(have already been drawn)
			
			--bgm
			if(stopExistingBgm) then 
				soundHandler.changeBgm()
			end
			if(pendingBgm) then
				soundHandler.changeBgm(pendingBgm)
			end
			
			--sfx
			if(stopExistingSounds) then
				soundHandler.playSfx()
			end
			for _, sound in pairs(pendingSfx) do 
				soundHandler.playSfx(
					sound.sound,
					sound.loops
				)
			end
			
			--next states
			if(currentCycle.flushGlobalVariables) then 
				self:queueChange({state = 'flushGlobalVariables'})
			end
			
			if(currentCycle.delay) then
				self:queueChange({
					state = (
						(currentCycle.screenUpdate and 'transition') or
						'delay'
					),
					delay = currentCycle.delay
				})
			end
			
			if(currentCycle.stop) then
				self:queueChange(
					stopActionsToState[
						latestAction.type
					]()
				)
			end
			
			self:queueChange({
				state = 'progressing'
			})
			
			--put it in the normal pending texts
			if(lPendingText) then
				pendingText = lPendingText
				
				textbox.animator.forceDone()
				textbox.processPendingText()
			end
			
			--go...
			print('[progressingState] switch to ' .. self:getChange().state)
			self:gotoState(self:getChange().state)
		end)
	end
	
	function progressingState:exitedState()
		pendingDraw = nil
		pendingSfx = nil
		pendingBgm = nil
		pendingChoices = nil
		lPendingText = nil
		nextLabel = nil
		latestAction = nil
	end
end
