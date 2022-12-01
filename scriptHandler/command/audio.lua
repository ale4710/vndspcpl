return function(ci)
	local cmds = {}
	
	cmds['sound'] = function(args)
		if(args) then 
			args = variableHandler.convertVariables(args)
			local path, loops = ci.upkSplitSpace(args)
			
			if(path == '~') then
				return {
					type = 'sfx',
					stopSound = true
				}
			else
				return {
					type = 'sfx',
					path = path,
					loops = (loops and tonumber(loops)) or 1
				}
			end
		end
	end
	
	cmds['music'] = function(path) 
		if(path) then 
			path = variableHandler.convertVariables(path)
			if(path == '~') then
				return {
					type = 'bgm',
					stopSound = true
				}
			else
				return {
					type = 'bgm',
					path = path
				}	
			end
		end
	end
	
	return cmds
end