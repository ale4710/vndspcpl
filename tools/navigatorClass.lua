local navigatorClass = class('navigator')

function navigatorClass:initialize()
	self.current = 1
	self.total = 0
	self.snapToEdge = false
	self.movedEvent = eventTarget:new()
end

function navigatorClass:jump(current)
	assert(
		type(current) == 'number',
		'current needs to be a number'
	)

	self.current = current
	self.movedEvent:broadcast(current)
end

function navigatorClass:move(move)
	assert(
		type(move) == 'number',
		'move needs to be a number'
	)
	
	if(self.total == 0) then
		self.current = 1
		return
	end
	
	self.current = navigateList(
		self.current,
		move,
		self.total,
		self.snapToEdge
	)
	
	self:jump(self.current)
end

return navigatorClass