local interface = {}

local screen

local function screenResizeTasks()
	--calculate scaling
	interface.scale = aspectRatioScaler(
		screen:getWidth(),
		screen:getHeight(),
		SCREEN.w,
		SCREEN.h
	)

	--update draw arguments
	interface.drawArguments = {
		SCREEN.w / 2,
		SCREEN.h / 2,
		0,
		interface.scale,
		interface.scale,
		screen:getWidth() / 2,
		screen:getHeight() / 2
	}
end

SCREEN.resizeEvent:add(screenResizeTasks)

local function makeCanvas(w, h) 
	if(screen) then screen:release() end
	screen = love.graphics.newCanvas(w, h)
	screenResizeTasks()
end
makeCanvas(VN_SCREEN.w, VN_SCREEN.h)
interface.resize = makeCanvas

function interface.draw(image, x, y)
	love.graphics.setCanvas(screen)
	love.graphics.setColor(colors.white)
	love.graphics.draw(
		image, 
		screen:getWidth() * (x / VN_SCREEN.w), 
		screen:getHeight() * (y / VN_SCREEN.h)
	)
	love.graphics.setCanvas()
end

function interface.clear()
	love.graphics.setCanvas(screen)
	love.graphics.clear()
	love.graphics.setCanvas()
end

function interface.get() 
	return screen:newImageData()
end

return interface