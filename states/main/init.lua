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
	'playVideo'
}) do
	local ssmn = requireppName(mn, ss)
	require(ssmn)(mainstateSubstates)
	package.loaded[ssmn] = nil
end

function mainstateSubstates:initialize()
	self.screen = nil
	
	self.pendingStateChanges = {}
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
	UIshortcut.drawAll()
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

local mssFnc = mainstateSubstates:new()

function mainUpdateAllForSave()
	mssFnc.pendingStateChanges = {}
	mssFnc:queueChange({
		state = 'transition',
		delay = 0
	})
	mssFnc:queueChange({state = 'progressing'})
	mssFnc:gotoState('transition')
end

--main state
function mainstate:enteredState()
	mssFnc:gotoState('progressing')
	mainstate.enteredState = nil
end
function mainstate:draw()
	mssFnc:draw()
end
function mainstate:update(dt) mssFnc:update(dt) end
function mainstate:input(action) mssFnc:input(action) end
function mainstate:rawInput(...) mssFnc:rawInput(...) end

return mainstate