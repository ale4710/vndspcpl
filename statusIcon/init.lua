local mn = ...
local interface = {}

local settings = {
	color = colors.white,
	lineWidth = 2,
	
	borderColor = colors.black,
	borderWidth = 1
}

local states = {}
for _, mod in pairs({
	'awaitingUser',
	'fileOperation',
	'delay'
}) do 
	local fullmod = requireppName(mn, mod)
	states[mod] = require(fullmod)(settings)
	package.loaded[fullmod] = nil
end
local currentState
function interface.setCurrentState(state)
	currentState = state
end
local function getCurrentState()
	return currentState and states[currentState]
end

function interface.draw(x, y, w, h)
	local cs = getCurrentState()
	if(cs and cs.draw) then cs.draw(x, y, w, h) end
end

function interface.update(dt)
	local cs = getCurrentState()
	if(cs and cs.update) then cs.update(dt) end
end

function interface.sendInfo(...)
	local cs = getCurrentState()
	if(cs and cs.sendInfo) then cs.sendInfo(...) end
end

return interface