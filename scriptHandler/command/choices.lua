return function(ci)
	local cmds = {}
	
	cmds['choice'] = function(choices)
		if(choices) then 
			--choices = variableHandler.convertVariables(choices)

			choices = string.split(choices, '|', true)
			for index, choice in pairs(choices) do 
				choices[index] = variableHandler.convertVariables(choice)
			end
			
			return {
				type = 'choices',
				choices = choices
			}, nil, nil, true
		end
	end
	
	return cmds
end