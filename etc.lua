SCREEN.resizeEvent = eventTarget:new()
function love.resize(w, h)
	SCREEN.w = w
	SCREEN.h = h
	SCREEN.resizeEvent:broadcast(w, h)
end