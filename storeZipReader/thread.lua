local CHANNEL_SEND_NAME, CHANNEL_RECEIVE_NAME = ...
local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)
CHANNEL_SEND_NAME = nil
CHANNEL_RECEIVE_NAME = nil

require('love.system')
socket = require("socket") --we will use this for sleeeping of all things...
local zip = require('zip')

local activeZip = {}

local ops = {}
ops['openArchive'] = (function(path)
	local id = #activeZip + 1
	local instance = zip.open(path)
	if(instance) then
		activeZip[id] = instance
		return id
	end
end)

ops['getFile'] = (function(data)
	local path = data.path
	
	local zi = activeZip[data.id]
	if(zi) then
		local file, err = zi:getFile(path)
		if(err) then
			print('[zip] error occured: ' .. err)
		else
			return file
		end
	else
		print('[zip] archive does not exist', data.id)
	end
end)

ops['kill']	= (function(id)
	activeZip[id]:kill()
	activeZip[id] = nil
end)

while(true) do
	local request = receiveChannel:pop()
	if(request) then
		local data
		local op = ops[request.operation]
		if(op) then
			data = op(request.data)
		end
		sendChannel:push({
			data = data,
			id = request.id
		})
	elseif(#activeZip == 0) then
		break
	else
		socket.sleep(0.25)
	end
end