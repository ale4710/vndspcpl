local modname = ...
local interface = {}

local CHANNEL_SEND_NAME = getUniqueId()
local CHANNEL_RECEIVE_NAME = getUniqueId()

local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)

local loaderThread = love.thread.newThread(modname .. '/thread.lua')

local filesWaiting = {}

modname = nil

function interface.check()
	while(true) do 
		local loadedFile = receiveChannel:pop()
		if(loadedFile) then
			local promise = filesWaiting[loadedFile.id]
			filesWaiting[loadedFile.id] = nil
			if(loadedFile.data) then
				promise:resolve(loadedFile.data)
			else
				promise:reject(loadedFile.error)
			end
		else
			break
		end
	end
end

function interface.load(filePath, ioreadFlagOverride)
	return Promise(function(responder)
		local waitId = #filesWaiting + 1
		filesWaiting[waitId] = responder
		sendChannel:push({
			filePath = filePath,
			flags = ioreadFlagOverride,
			id = waitId
		})

		if(not loaderThread:isRunning()) then 
			loaderThread:start(
				CHANNEL_RECEIVE_NAME,
				CHANNEL_SEND_NAME
			)
		end
	end)
end

return interface