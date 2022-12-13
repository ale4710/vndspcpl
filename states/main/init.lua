local mn = ...
local mainstate = gameclass:addState('main')

--substate
local mainstateSubstates = class('mainstateSubstates'):include(stateful)
for _, ss in pairs({
	'awaitingUser',
	'progressing',
	'delay',
	'transition',
	'choices',
	'jump',
	'flushGlobalVariables',
	'playVideo',
	'error'
}) do
	local ssmn = requireppName(mn, ss)
	require(ssmn)(mainstateSubstates)
	package.loaded[ssmn] = nil
end

function mainstateSubstates:initialize()
	self.screen = nil
end

function mainstateSubstates:queueChange(change)
	table.insert(self.pendingStateChanges, change)
end

function mainstateSubstates:getChange()
	return self.pendingStateChanges[1]
end

function mainstateSubstates:nextChange()
	return table.remove(self.pendingStateChanges, 1)
end

mainstateSubstates.update = emptyfn
mainstateSubstates.input = emptyfn
mainstateSubstates.rawInput = emptyfn
function mainstateSubstates:draw()
	love.graphics.setColor(colors.white)
	self:drawScreen()
	textbox.draw()
	mainstateSubstates.drawStatusIcon()
	mainstateSubstates.drawSoundEffectsTimes() 
end

function mainstateSubstates:drawScreen(screenOverride)
	local screen = screenOverride or self.screen
	if(screen) then
		--screen is NOT a canvas, no need to setblendmode
		love.graphics.draw(
			screen,
			unpack(renderer.drawArguments)
		)
	end
end

--common fns
do 
	local sis = 24
	function mainstateSubstates.drawStatusIcon()
		statusIcon.draw(
			SCREEN.w - (sis * 2),
			SCREEN.h - (sis * 2),
			sis, sis
		)
	end
	
	local progressWidth = SCREEN.w * 0.07
	local progressHeight = 3
	local progressIndefiniteWidth = 0.3 --relative to progressWidth
	local progressIndefiniteSpeed = 2 --interval in seconds between hitting the edge
	local progressMargin = 1
	local progressRightMargin = 8
	local progressColor = colors.white
	local progressBgColor = {colora(colors.white, 0.3)}
	local progressWindowBgColor = colors.black
	function mainstateSubstates.drawSoundEffectsTimes() 
		local progressTimes = soundHandler.getSfxProgress()
		if(progressTimes) then
			local proceed = false
			
			if(userSettings.indicateInfiniteSfx) then 
				proceed = true
			else
				do 
					local index = 1
					while(index <= #progressTimes) do 
						local progress = progressTimes[index]
						if(progress == true) then 
							table.remove(progressTimes, index)
						else
							proceed = true
							index = index + 1
						end
					end
				end
			end
			
			if(proceed) then
				local initY = SCREEN.h - sis
				local height = ((progressHeight + progressMargin) * #progressTimes) + progressMargin
				if(height < sis) then
					initY = initY - (sis / 2) - (height / 2)
				else
					initY = initY - height
				end
				initY = initY + progressMargin
				local x = SCREEN.w - (sis * 2) - progressRightMargin - (progressMargin * 2) - progressWidth
				--draw background
				love.graphics.setColor(progressWindowBgColor)
				love.graphics.rectangle(
					'fill',
					x - progressMargin,
					initY - progressMargin,
					progressWidth + (progressMargin * 2),
					height
				)
				--draw bars
				for index, thisProgress in ipairs(progressTimes) do 
					local y = initY + ((progressHeight + progressMargin) * (index - 1))
					
					love.graphics.setColor(progressBgColor)
					love.graphics.rectangle(
						'fill',
						x, y,
						progressWidth,
						progressHeight
					)
					
					love.graphics.setColor(progressColor)
					--check infinite
					if(thisProgress == true) then
						local lnow = now() * progressIndefiniteSpeed
						local currentOffset = (lnow % 1)
						if(math.floor(lnow % 2) == 0) then 
							currentOffset = 1 - currentOffset
						end
						local currentOffsetPosition = currentOffset * (progressWidth * (1 - progressIndefiniteWidth))
						love.graphics.rectangle(
							'fill',
							x + currentOffsetPosition, y,
							progressWidth * progressIndefiniteWidth,
							progressHeight
						)
					else
						love.graphics.rectangle(
							'fill',
							x, y,
							(progressWidth * thisProgress),
							progressHeight
						)
					end
				end
			end
		end
	end
end

local mssFnc = mainstateSubstates:new()

local function doVisualClear() 
	--set screen update
	mssFnc:queueChange({
		state = 'transition',
		delay = 0
	})
	
	--text
	pendingText = {}
	textbox.animator.forceDone()
	textbox.processPendingText()
	
	--queue after the screen update
	mssFnc:queueChange({state = 'progressing'})
	
	--go
	mssFnc:gotoState('transition')
end

function mainUpdateAllForSave()
	mssFnc.pendingStateChanges = {}
	doVisualClear() 
end

function mainInit() 
	mssFnc.pendingStateChanges = {}
	variableHandler.reset()
	doVisualClear()
end

function mainReset() 
	return vnResource.get('script', MAIN_SCR_FILE_NAME):and_then(function(script)
		if(script == false) then
			messageBoxWS(
				'Fatal Error',
				'Fatal Error: Failed to find file main.scr (was the novel modified?)',
				'error'
			)
			self:gotoState('error')
		else
			scriptHandler.loadScript(script)
			mainInit()
		end
	end)
end

--main state
function mainstate:draw()
	mssFnc:draw()
end
function mainstate:update(dt) mssFnc:update(dt) end
function mainstate:input(action) mssFnc:input(action) end
function mainstate:rawInput(...) mssFnc:rawInput(...) end

return mainstate
