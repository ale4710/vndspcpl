return function(settings)
	local params = {}

	return {
		draw = (function(x, y, w, h)
			if(userSettings.hideAwaitingUserIndicator) then return end
			
			local s = math.min(w, h)
			local hs = s / 2
			local cx = x + (w / 2)
			local cy = y + (h / 2)
			
			params[1], params[2] = cx + hs, cy
			params[3], params[4] = cx - hs, cy + hs
			params[5], params[6] = cx - hs, cy - hs
			
			if(settings.borderWidth > 0) then 
				love.graphics.setLineWidth(settings.borderWidth * 2)
				love.graphics.setColor(settings.borderColor)
				love.graphics.polygon('line', unpack(params))
			end
			
			love.graphics.setColor(settings.color)
			love.graphics.polygon('fill', unpack(params))
		end)
	}
end