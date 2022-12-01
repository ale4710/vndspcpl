local mn = ...

local menuState = gameclass:addState('menu')

local menuActions = {
	['reset'] = (function()end),
	['saveload'] = (function()
	
	end)
}

function menuState:enteredState()
	
end

function menuState:input(action)
	do --movement
		local move = INPUT_NAVIGATION_LIST_HELPER[action]
		if(
			move and
			move.vertical
		) then 
				--idk
				return
		end
	end
end

return menuState