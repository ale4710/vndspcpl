local messageBoxSounds = {
	['error'] = 'ddd.ogg',
	['warning'] = 'ding.wav',
	['info'] = 'ding.wav'
}

return function(...)

	local src
	do
		local _, _, infoOrButtonList, typeIfNotBeforeIsNotButtonList = ...
		if(
			typeIfNotBeforeIsNotButtonList or
			(type(infoOrButtonList) == 'string') or
			(type(infoOrButtonList) == 'nil')
		) then
			local fileName = messageBoxSounds[
				typeIfNotBeforeIsNotButtonList or
				infoOrButtonList or 
				'info'
			]
			if(fileName) then
				local suc, srcFP = pcall(love.audio.newSource,
					'/resources/sound/' .. fileName,
					'stream'
				)
				if(suc) then
					src = srcFP
					src:play()
				end
			end
		end
	end
	
	local result = love.window.showMessageBox(...)
	
	if(src) then 
		src:pause()
		src:release()
	end
	
	return result
end