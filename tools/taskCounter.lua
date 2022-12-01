local taskCounter = class('taskCounter')
function taskCounter:initialize()
	self.pending = 0
	self.eventTarget = eventTarget:new()
end

function taskCounter:add()
	self.pending = self.pending + 1
end

function taskCounter:remove()
	self.pending = math.max(
		self.pending - 1,
		0
	)
	
	--print(self.pending)
	
	if(not self:checkTasksPending()) then
		self.eventTarget:broadcast()
		--print('!')
	end
end

function taskCounter:checkTasksPending() 
	return self.pending ~= 0
end

return taskCounter