local interface = {}

local sis = 24

function interface.drawStatusIcon()
	statusIcon.draw(
		SCREEN.w - (sis * 2),
		SCREEN.h - (sis * 2),
		sis, sis
	)
end

function interface.drawAll()
	textbox.draw()
	interface.drawStatusIcon()
end

return interface