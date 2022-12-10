return function(settings)
	local folderShape = {}
	local arrowShape = {}
	
	local arrowFlip = false
	
	local timeOffset = 0
	
	return {
		sendInfo = (function(flip)
			arrowFlip = not not flip
		end),
		
		reset = (function()
			timeOffset = now()
		end),
		
		draw = (function(x, y, w, h)
			if(userSettings.hideLoadingIndicator) then return end
		
			local s = math.min(w, h)
			local nx = x + (w / 2) - (s / 2)
			local ny = y + (h / 2) - (s / 2)
			
			--folder
			local bottom = ny + s
			local topLabel = ny + (s * 0.2)
			local top = ny + (s * 0.43)
			
			local topLabelEnd = nx + (s * 0.29)
			local topNormalEnd = nx + (s * 0.43)
			
			local sidesPadding = 0.07
			local left = nx + (s * sidesPadding)
			local right = nx + (s * (1 - sidesPadding))
			sidesPadding = nil
			
			folderShape[1], folderShape[2] = left, bottom
			folderShape[3], folderShape[4] = right, bottom
			folderShape[5], folderShape[6] = right, top
			folderShape[7], folderShape[8] = topNormalEnd, top
			folderShape[9], folderShape[10] = topLabelEnd, topLabel
			folderShape[11], folderShape[12] = left, topLabel
			
			--folder border
			if(settings.borderWidth > 0) then 
				love.graphics.setColor(settings.borderColor)
				love.graphics.setLineWidth(settings.lineWidth + (settings.borderWidth * 2))
				love.graphics.polygon('line', unpack(folderShape))
			end
			
			--actual folder
			love.graphics.setColor(settings.color)
			love.graphics.setLineWidth(settings.lineWidth)
			love.graphics.polygon('line', unpack(folderShape))
			
			
			if((math.floor((now() - timeOffset) * 15) % 2) == 0) then
				--arrow
				local arrowXpos = nx + (s * 0.64)
				local arrowBottom = ny + (s * 0.67)
				local arrowTop = ny
				local arrowHeadSides = settings.lineWidth * 2
				local arrowHeadHeight = settings.lineWidth * 2
				
				if(arrowFlip) then 
					love.graphics.push()
					local osx, osy = arrowXpos, arrowTop + ((arrowBottom - arrowTop) / 2)
					love.graphics.translate(osx, osy)
					love.graphics.scale(1, -1)
					love.graphics.translate(-osx, -osy)
				end
				
				arrowShape[1], arrowShape[2] = arrowXpos, arrowTop
				arrowShape[3], arrowShape[4] = arrowXpos - arrowHeadSides, arrowTop + arrowHeadHeight
				arrowShape[5], arrowShape[6] = arrowXpos + (settings.lineWidth / 2), arrowTop + arrowHeadHeight
				arrowShape[7], arrowShape[8] = arrowXpos + (settings.lineWidth / 2), arrowBottom
				arrowShape[9], arrowShape[10] = arrowXpos - (settings.lineWidth / 2), arrowBottom
				arrowShape[11], arrowShape[12] = arrowXpos - (settings.lineWidth / 2), arrowTop + arrowHeadHeight
				arrowShape[13], arrowShape[14] = arrowXpos + arrowHeadSides, arrowTop + arrowHeadHeight
				
				--arrow border
				if(settings.borderWidth > 0) then 
					love.graphics.setColor(settings.borderColor)
					love.graphics.setLineWidth(settings.borderWidth * 2)
					love.graphics.polygon('line', unpack(arrowShape))
				end
				
				--actual arrow
				love.graphics.setColor(settings.color)
				love.graphics.setLineWidth(settings.lineWidth)
				love.graphics.polygon('fill', unpack(arrowShape))
				
				if(arrowFlip) then 
					love.graphics.pop()
				end
			end
		end)
	}
end
