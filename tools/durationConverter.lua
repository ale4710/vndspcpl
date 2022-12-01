local DURATION_SECONDS_PATTERN = '(%d+)(m?s)'

return function(duration)
	local durationType = type(duration)
	if(durationType == 'number') then
		return duration * FRAME_LENGTH
	elseif(durationType == 'string') then
		local found, _, extractedDuration, unit = duration:find(DURATION_SECONDS_PATTERN)
		if(found) then
			duration = tonumber(extractedDuration)
			if(unit == 'ms') then
				duration = duration / 1000
			end
			return duration
		else
			return (tonumber(duration) or DEFAULT_FADE_LENGTH) * FRAME_LENGTH
		end
	end
end