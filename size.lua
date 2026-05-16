SCREEN.resizeEvent = eventTarget:new()
SCREEN.w = 800
SCREEN.h = 600

function SCREEN.setAspectRatio(ratio) --w/h
	SCREEN.h = 600
	SCREEN.w = SCREEN.h * ratio
	SCREEN.resizeEvent:broadcast(SCREEN.w, SCREEN.h)
end

function SCREEN.getTransformInfo()
	local sysw, sysh = love.graphics.getDimensions()
	local scale = aspectRatioScaler(
		SCREEN.w, SCREEN.h,
		sysw, sysh
	)

	return
		(sysw * 0.5) - (scale * SCREEN.w * 0.5),
		(sysh * 0.5) - (scale * SCREEN.h * 0.5),
		scale
end

function love.resize(w, h)
	SCREEN.resizeEvent:broadcast(SCREEN.w, SCREEN.h)
end