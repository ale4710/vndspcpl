return function(ci)
	local cmds = {}
	
	cmds['delay'] = function(delay)
		if(delay) then
			delay = variableHandler.convertVariables(delay)
			delay = durationConverter(delay)
			if(delay) then 
				return {type = 'delay'}, delay
			end
		end
	end
	
	cmds['jump'] = function(args)
		if(args) then
			args = variableHandler.convertVariables(args)
			local file, label = ci.upkSplitSpace(args)
			
			return {
				type = 'jump',
				file = file,
				label = label
			}, nil, nil, true
		end
	end
	
	cmds['goto'] = function(label)
		if(label) then
			label = variableHandler.convertVariables(label)
			return {
				type = 'goto',
				label = label
			}, nil, nil, true
		end
	end
	
	cmds['label'] = emptyfn
	
	do 
		local function randomHandler(args)
			if(args) then
				args = variableHandler.convertVariables(args)
				local variable, min, max = ci.upkSplitSpace(args)
				
				min = tonumber(min)
				max = tonumber(max)
				
				if(
					variable and
					min
				) then
					if(not max) then 
						min = 0
					end
					
					local result
					
					if(min < max) then
						result = math.random(
							math.floor(min), 
							math.floor(max)
						)
					elseif(min == max) then
						result = max
					else
						--min > max
						print('[scriptHandler/random] malformed random. ignored.')
						--is broken.
						return
					end
					
					variableHandler.variables[variable] = result
				end
			end
		end
		
		cmds['random'] = randomHandler
		cmds['rand'] = randomHandler
	end
	
	return cmds
end