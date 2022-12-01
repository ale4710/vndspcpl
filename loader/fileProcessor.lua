return function(cache, mn)
	local CHANNEL_SEND_NAME = getUniqueId()
	local CHANNEL_RECEIVE_NAME = getUniqueId()

	local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
	local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)

	local processorThread = love.thread.newThread(mn .. '/thread.lua')
	
	mn = nil
	
	--after loader
	--after the main loader from the thread 
	--it is due to some limitation in love
	local afterLoader = {}
	do 
		local function imgload(imgdata)
			local success, image = pcall(
				love.graphics.newImage,
				imgdata
			)
			if(success) then 
				return image
			else
				print('[loader/fileProcessor/imgload] image "' .. imgdata:getFilename() .. '" could not be loaded')
			end
		end
		
		afterLoader['foreground'] = imgload
		afterLoader['background'] = imgload
	end

	local pendingProcess = {}

	function _processingCheck()
	while(true) do
		local processed = receiveChannel:pop()
		if(processed) then
			local jobInfo = pendingProcess[processed.id]
			pendingProcess[processed.id] = nil
			local result = processed.result
			processed = nil
			
			if(result) then
				local al = afterLoader[jobInfo.which]
				if(al) then 
					result = al(result)
				end
			end
			
			cache.set(
				jobInfo.which,
				jobInfo.path,
				result or true
			)
			
			if(result) then
				jobInfo.promiseResponder:resolve(result)
			else
				jobInfo.promiseResponder:reject(false)
			end
		else
			break
		end
	end
end

	return (function(
		data,
		which,
		path
	)
		return Promise(function(responder)
			local id = #pendingProcess + 1
			pendingProcess[id] = {
				promiseResponder = responder,
				which = which,
				path = path
			}
			sendChannel:push({
				data = data,
				path = path,
				which = which,
				id = id
			})
			
			if(not processorThread:isRunning()) then 
				processorThread:start(
					CHANNEL_RECEIVE_NAME,
					CHANNEL_SEND_NAME
				)
			end
			
		end)
	end)
end