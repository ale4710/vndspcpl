INPUT_ACTIONS = table.invert({
	'continue',
	'select',
	'skip',
	'cancel',
	'up',
	'down',
	'left',
	'right'
})

SKIP_INPUTS = {}

INPUT_NAVIGATION_LIST_HELPER = {
	[INPUT_ACTIONS.up] = {vertical = true, move = -1},
	[INPUT_ACTIONS.left] = {vertical = false, move = -1},
	[INPUT_ACTIONS.down] = {vertical = true, move = 1},
	[INPUT_ACTIONS.right] = {vertical = false, move = 1}
}

--keyboard
INPUT_KEYBOARD_MAP = {
	['space'] = INPUT_ACTIONS.continue,
	['return'] = INPUT_ACTIONS.select,
	['up'] = INPUT_ACTIONS.up,
	['down'] = INPUT_ACTIONS.down,
	['left'] = INPUT_ACTIONS.left,
	['right'] = INPUT_ACTIONS.right,
	['lctrl'] = INPUT_ACTIONS.skip,
	['rctrl'] = INPUT_ACTIONS.skip,
	['escape'] = INPUT_ACTIONS.cancel,
	['backspace'] = INPUT_ACTIONS.cancel
}
INPUT_KEYBOARD_REVERSE_MAP = {}

for key, action in pairs(INPUT_KEYBOARD_MAP) do
	if(action == INPUT_ACTIONS.skip) then 
		table.insert(SKIP_INPUTS, key)
	end
	
	local reverseMap = INPUT_KEYBOARD_REVERSE_MAP[action] or {}
	table.insert(
		reverseMap,
		key
	)
	INPUT_KEYBOARD_REVERSE_MAP[action] = reverseMap
end

function love.keypressed(...)
	game:rawInput(0, ...)

	local key = ...
	key = INPUT_KEYBOARD_MAP[key]
	
	if(key) then
		game:input(key)
	end
end

function checkInputActionDown(action)
	--keyboard
	do 
		local tocheck = INPUT_KEYBOARD_REVERSE_MAP[action]
		if(tocheck) then
			local down = love.keyboard.isDown(unpack(tocheck))
			if(down) then 
				return true
			end
		end
	end
	
	--gamepad
	--    TODO
end

do --mouse
	local lastMouseMoved = -math.huge
	function _updateMouseVisibility()
		love.mouse.setVisible(not(
			(now() - lastMouseMoved > 5) and
			userSettings.hideMouseOnInactivity
		))
	end
	
	local function setLMM()
		lastMouseMoved = now()
	end
	
	function love.mousemoved(...)
		setLMM()
	end
	
	function love.mousepressed(...)
		setLMM()
	end
end
