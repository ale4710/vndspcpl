return function(settings)
	local progress = 0
	
	local startangle = math.pi * -0.5
	
	local params = {
		0,
		0,
		0,
		startangle,
		startangle,
		20 --segments
	}

	local function draw(x, y, w, h)
		if(userSettings.hideDelayTimer) then return end
		
		params[1] = x + (w / 2) --x
		params[2] = y + (h / 2) --y
		params[3] = math.min(w, h) / 2 --radius
		
		--love.graphics.setLineStyle('rough')
		love.graphics.setLineWidth(settings.borderWidth * 2)
		
		if(progress >= 1) then 
			love.graphics.setColor(settings.borderColor)
			love.graphics.circle('line', params[1], params[2], params[3])
			
			love.graphics.setColor(settings.color)
			love.graphics.circle('fill', params[1], params[2], params[3])
		elseif(progress > 0) then
			params[5] = startangle + (math.pi * 2 * math.min(progress, 1)) --end angle
			
			if(settings.borderWidth > 0) then 
				love.graphics.setColor(settings.borderColor)
				love.graphics.arc('line', 'open', unpack(params))
			end
			
			love.graphics.setColor(settings.color)
			love.graphics.arc('fill', unpack(params))
		end
		
	end
	
	local function getInfo(p)
		progress = p
	end

	return {
		draw = draw,
		sendInfo = getInfo
	}
end