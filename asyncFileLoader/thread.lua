local CHANNEL_SEND_NAME, CHANNEL_RECEIVE_NAME = ...
local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)
CHANNEL_SEND_NAME = nil
CHANNEL_RECEIVE_NAME = nil

require('love.system')
operatingSystem = love.system.getOS()
local qr = require('tools.fileGet')

while(true) do 
	local request = receiveChannel:pop()
	if(request) then
		local data, _, errcode = qr(
			request.filePath,
			request.flags
		)
		
		if(errcode) then 
			print(
				'[asyncFileLoader] could not load file "' .. (request.filePath or '?') .. '" - given error is... ',
				errcode
			)
		end
	
		sendChannel:push({
			data = data,
			error = errcode,
			id = request.id
		})
	else
		break
	end
end