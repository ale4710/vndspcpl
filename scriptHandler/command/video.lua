return function(ci)
	local function video(args)
		if(args) then 
			args = variableHandler.convertVariables(args)
			args = ci.splitSpace(args)
			
			local filename, fadeDuration
			if(#args <= 2) then 
				filename, fadeDuration = unpack(args)
			else
				filename = args[1]
				fadeDuration = args[3]
			end
			args = nil
			
			fadeDuration = durationConverter(fadeDuration or DEFAULT_FADE_LENGTH)
			
			--action, delay, screenUpdate, stop, flushGlobalVariables
			return {
				type = 'video',
				file = filename,
				fade = fadeDuration
			}, nil, nil, true, nil
		else
			print('[scriptHandler/video] malformed command')
		end
	end

	return {
		['video'] = video,
		['vid'] = video
	}
end