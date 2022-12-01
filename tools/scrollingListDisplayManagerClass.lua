local sldmc = class('scrollingListDisplayManager')

local active = {}
function _sldmcUpdate(dt)
	for _, lmi in pairs(active) do
		lmi:_update(dt)
	end
end

function sldmc:initialize(maxSize)
	self.maxSize = maxSize
	self.drawTopPosition = 0
	self.targetPosition = 0
	
	--self.scrollSpeed
	self.normalScrollSpeed = self.maxSize * 2
	self.fastScrollSpeed = self.maxSize * 10
	
	self.currentElement = 1
	self.elementSize = 0
	self.elementPadding = 0
	--self.element1
	--self.element2
	--self.elementSizes
	
	self.scrolling = false
	self.scrollStartEvent = eventTarget:new()
	self.scrollStopEvent = eventTarget:new()
	
	self._activeId = #active + 1
	active[self._activeId] = self
end

function sldmc:release()
	table.remove(active, self._activeId)
	self.released = true
end

function sldmc:scrollElementIntoView(elementIndex)
	self.currentElement = elementIndex
	local elementTop, elementBottom, elementHeight
	if(self.elementSizes) then 
		assert(self.elementSizes[elementIndex], 'target element does not exist.')
		
		local height = 0
		for index, elHeight in ipairs(self.elementSizes) do 
			
			if(index == elementIndex) then 
				elementTop = height
				elementHeight = elHeight
				break
			else
				height = height + elHeight + self.elementPadding
			end
		end
	else
		elementTop = (elementIndex - 1) * (self.elementSize + self.elementPadding)
		elementHeight = self.elementSize
	end
	
	local elementBottom = elementTop + elementHeight
	
	
	if(not(
		math.between(self.drawTopPosition, self.drawTopPosition + self.maxSize, elementTop, false) and
		math.between(self.drawTopPosition, self.drawTopPosition + self.maxSize, elementBottom, false)
	)) then 
		if(elementBottom < (self.drawTopPosition + self.maxSize)) then 
			--is target above us?
			self.targetPosition = elementTop
		elseif(elementTop > self.drawTopPosition) then
			--is target below us?
			self.targetPosition = elementBottom - self.maxSize
		end
	end
end

function sldmc:_update(dt)
	local drawNotTarget = (self.drawTopPosition ~= self.targetPosition)
	
	if(drawNotTarget ~= self.scrolling) then
		if(drawNotTarget) then
			--start scrolling
			self.scrollStartEvent:broadcast()
		else
			--stop scrolling
			self.scrollStopEvent:broadcast()
		end
		
		self.scrolling = drawNotTarget
	end

	if(self.scrolling) then 
		local drawToTargetDiff = (self.targetPosition - self.drawTopPosition)
		local dirMult = (((drawToTargetDiff) < 0) and -1) or 1
		local move
		
		if(math.abs(drawToTargetDiff) > self.maxSize) then 
			move = self.fastScrollSpeed
		else
			move = self.normalScrollSpeed
		end
		move = move * dt * dirMult
		
		local init = self.drawTopPosition
		self.drawTopPosition = init + move
		
		if(math.between(init, self.drawTopPosition, self.targetPosition)) then 
			self.drawTopPosition = self.targetPosition
		end
	end
end

return sldmc