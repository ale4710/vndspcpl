CHANNEL_SEND_NAME, CHANNEL_RECEIVE_NAME, gamepath = ...
sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)
CHANNEL_SEND_NAME = nil
CHANNEL_RECEIVE_NAME = nil

--isThread = true

require('love.system')
getSaveFilePath = require('tools.getSaveFilePath')

request = receiveChannel:pop()
if(request) then 
	--print(request.slot, request.file)
	
	success = false
	
	filepath = getSaveFilePath(request.slot)
	
	if(request.file) then 
		mode = 'w+'
		if(love.system.getOS() == 'Windows') then 
			mode = mode .. 'b'
		end
		
		file = io.open(
			filepath,
			mode
		)
		if(file) then	
			file:write(request.file)
			file:close()
			success = true
		end
	else
		_, err = os.remove(filepath)
		success = not err
	end
	
	sendChannel:push(success)
end