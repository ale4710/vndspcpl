local GROUNDS = {
	'foreground', --1
	'background'  --2
}
local function imgCommand(path, x, y, ground)
	return {
		type = 'image',
		ground = GROUNDS[ground],
		path = path,
		x = x,
		y = y
	}
end

return function(ci)
	local cmds = {}
	
	cmds['setimg'] = function(args)
		if(args) then 
			args = variableHandler.convertVariables(args)

			local path, x, y = ci.upkSplitSpace(args)
			
			return imgCommand(
				path,
				tonumber(x) or 0,
				tonumber(y) or 0,
				1
			),
			nil,
			true
		end
	end
	
	cmds['bgload'] = function(args) 
		if(args) then 
			args = variableHandler.convertVariables(args)
			local path, fade = ci.upkSplitSpace(args)
			local cmd = imgCommand(path, 0, 0, 2)
			
			fade = durationConverter(fade or DEFAULT_FADE_LENGTH)
			
			if(fade) then
				fade = tonumber(fade)
			end
			
			return 
				cmd, 
				fade,
				true
		end
	end
	
	return cmds
end