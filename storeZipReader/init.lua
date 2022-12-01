local modname = ...

local CHANNEL_SEND_NAME = getUniqueId()
local CHANNEL_RECEIVE_NAME = getUniqueId()

local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)

local readerThread = love.thread.newThread(modname .. '/thread.lua')

local pendingOps = callbackHelper:new()

modname = nil

function _zipOperationsCheck()
	while(true) do 
		local result = receiveChannel:pop()
		if(result) then 
			pendingOps:executeCallback(
				result.id,
				result.data
			)
		else
			break
		end
	end
end

local function startThreadIfNot()
	if(not readerThread:isRunning()) then 
		readerThread:start(
			CHANNEL_RECEIVE_NAME,
			CHANNEL_SEND_NAME
		)
	end
end

local function queueOperation(operation, data, callback)
	local id = pendingOps:addCallback(callback)
	sendChannel:push({
		id = id,
		operation = operation,
		data = data
	})
	startThreadIfNot()
	return id
end

--zip class
local zipClass = class('zip')
function zipClass:initialize(path, loadedCallback)
	queueOperation(
		'openArchive',
		path,
		(function(id)
			if(id) then
				self.id = id
				loadedCallback(true)
			else
				self.killed = true
				loadedCallback(false)
			end
			loadedCallback = nil
		end)
	)
end

function zipClass:checkKilled()
	if(self.killed) then
		return Promise():then_reject('thing has been killed.')
	end
end

function zipClass:getFile(path)
	if(not self.id) then
		return Promise():then_reject('wait...')
	else
		local killedp = self:checkKilled()
		if(killedp) then
			return killedp
		else
			return Promise(function(responder)
				queueOperation(
					'getFile',
					{
						id = self.id,
						path = path
					},
					(function(file)
						if(file) then
							responder:resolve(file)
						else
							responder:reject(false)
						end
					end)
				)
			end)
		end
	end
end
function zipClass:kill()
	local killedp = self:checkKilled()
	if(killedp) then
		return killedp
	else
		return Promise(function(responder)
			queueOperation(
				'kill',
				self.id,
				(function()
					self.killed = true
					responder:resolve(true)
				end)
			)
		end)
	end
end

return function(path)
	return Promise(function(responder)
		local zci 
		zci = zipClass:new(path, function(success)
			if(success) then
				print('[storeZipReader] ' .. path .. ' is ready.', zci)
				responder:resolve(zci)
			else
				print('[storeZipReader] ' .. path .. ' not loaded.')
				responder:reject(false)
			end
		end)
	end)
	
end