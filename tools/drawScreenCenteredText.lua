return function(text, scale)
	scale = (scale or 1) * userSettings.textScale
	love.graphics.printf(
		text,
		0,
		(SCREEN.h / 2) - ((love.graphics.getFont():getHeight() * scale) / 2),
		SCREEN.w / scale,
		'center',
		0,
		scale
	)
end