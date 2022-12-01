local rendererClass = class('renderer')

local active = {}

function rendererClass:initialize(width, height) 
	self._activeId = #active + 1
	table.insert(active, self)
	self:resize(width, height)
end

function rendererClass:release()
	table.remove(active, self._activeId)
	self.screen:release()
	self.released = true
end

function rendererClass:resize(width, height) 
	self.width = width or VN_SCREEN.w
	self.height = height or VN_SCREEN.h
	self:createScreen()
	self:recalculate()
end

function rendererClass:createScreen()
	if(self.screen) then
		self.screen:release()
	end
	self.screen = love.graphics.newCanvas(
		self.width,
		self.height
	)
end

function rendererClass:draw(image, x, y)
	love.graphics.setCanvas(self.screen)
	love.graphics.push()
	love.graphics.origin()
	love.graphics.setColor(colors.white)
	love.graphics.draw(
		image, 
		self.width * (x / VN_SCREEN.w),
		self.height * (y / VN_SCREEN.h)
	)
	love.graphics.setCanvas()
	love.graphics.pop()
end

function rendererClass:clear()
	love.graphics.setCanvas(self.screen)
	love.graphics.push()
	love.graphics.origin()
	love.graphics.clear()
	love.graphics.setCanvas()
	love.graphics.pop()
end

function rendererClass:recalculate()
	self.scale = aspectRatioScaler(
		self.width,
		self.height,
		SCREEN.w,
		SCREEN.h
	)
	
	self.drawArguments = {
		SCREEN.w / 2,
		SCREEN.h / 2,
		0,
		self.scale,
		self.scale,
		self.width / 2,
		self.height / 2
	}
end

function rendererClass:getThumbnail(targetWidthOrScale, targetHeight)
	local tw, th
	
	assert(
		type(targetWidthOrScale) == 'number',
		'argument 1 must be a number.'
	)
	
	if(not targetHeight) then
		tw = self.width * targetWidthOrScale
		th = self.height * targetWidthOrScale
	else
		assert(
			type(targetHeight) == 'number',
			'argument 2 must be a number'
		)
		tw = targetWidthOrScale
		th = targetHeight
	end
	
	tw = math.ceil(tw)
	th = math.ceil(th)
	
	local scale = aspectRatioScaler(
		self.width,
		self.height,
		tw,
		th
	)
	
	local cv = love.graphics.newCanvas(tw, th)
	
	tw = nil
	th = nil
	
	love.graphics.setCanvas(cv)
	love.graphics.push()
	love.graphics.origin()
	love.graphics.setBlendMode('alpha', 'premultiplied')
	
	love.graphics.draw(self.screen, 0, 0, 0, scale)
	
	love.graphics.setCanvas()
	love.graphics.pop()
	love.graphics.setBlendMode('alpha')
	
	local img = love.graphics.newImage(cv:newImageData())
	cv:release()
	
	return img
end

function rendererClass:get()
	return self.screen:newImageData()
end

SCREEN.resizeEvent:add(function()
	for _, renderer in pairs(active) do 
		renderer:recalculate()
	end
end)

return rendererClass