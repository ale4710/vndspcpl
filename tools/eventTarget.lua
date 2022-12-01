local eventTarget = class('eventTarget')
function eventTarget:initialize()
	self.listeners = {}
end

function eventTarget:add(fn) 
	local listenerId = #self.listeners + 1
	table.insert(self.listeners, fn)
	return listenerId
end

function eventTarget:remove(id)
	self.listeners[id] = nil
end

function eventTarget:broadcast(...)
	for _, fn in pairs(self.listeners) do 
		fn(...)
	end
end

return eventTarget