local cbh = class('callbackHelper')

function cbh:initialize()
	self.pending = {}
end

function cbh:addCallback(callback)
	local id = #self.pending + 1
	self.pending[id] = callback
	return id
end

function cbh:executeCallback(id, ...)
	local callback = self:pullCallback(id)
	callback(...)
end

function cbh:pullCallback(id)
	local callback = self.pending[id]
	self.pending[id] = nil
	return callback
end

return cbh