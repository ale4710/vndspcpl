local interface = {}

local buffer
local characterAnimator
function interface.initialize(b, ca)
	buffer = b
	characterAnimator = ca
	interface.initialize = nil
end

local screen

function interface.setWidth(w)
	if(screen) then
		screen:release()
	end

	screen = love.graphics.newCanvas(
		math.ceil(w / userSettings.textScale), 
		math.ceil(SCREEN.h / userSettings.textScale)
	)

	interface.canvas = screen
end

local margin = 0
function interface.setMargin(m)
	margin = m / userSettings.textScale
end

local separatorHeight = 1.5
local offsetDraw = 0

function interface.draw()
	local lh = font:getHeight() --line height
	local movedPx = margin
	
	love.graphics.setCanvas(screen)
	love.graphics.clear()
	love.graphics.setColor(colors.white)
	love.graphics.setFont(font)

	for 
		i = 1,
		#buffer, 
		1
	do 
		local cur = buffer[#buffer - (i + offsetDraw - 1)]
		--print(#buffer - (i + offsetDraw - 1), #buffer)
		
		local textLineCount
		
		if(cur) then
			local _, wl = font:getWrap(
				cur.actualText, 
				screen:getWidth()
			)
			textLineCount = #wl
		else
			textLineCount = 1
		end

		local textHeight = (textLineCount * lh)
		movedPx = movedPx + textHeight
		
		if(cur and cur.text) then
			local y, w = (screen:getHeight() - movedPx), (screen:getWidth())
			
			if(i == 1) then 
				local sh = (separatorHeight / userSettings.textScale)
				love.graphics.rectangle(
					'fill',
					0, y - (sh / 2),
					w, sh
				)
			end
			love.graphics.printf(cur.text, 0, y, w)
			
			-- if(
				-- i == 1 and
				-- not characterAnimator.checkDone()
			-- ) then
				-- print('[fullscrenTextRenderer] drawing characterAnimator')
				-- characterAnimator.draw()
				-- love.graphics.setCanvas(screen)
				-- love.graphics.setBlendMode('alpha', 'premultiplied')
				-- love.graphics.draw(
					-- characterAnimator.canvas,
					-- 0,
					-- screen:getHeight() - movedPx
				-- )
				-- love.graphics.setBlendMode('alpha')
			-- else
				-- love.graphics.setFont(font)
				-- love.graphics.printf(
					-- cur.text,
					-- 0,
					-- screen:getHeight() - movedPx,
					-- screen:getWidth()
				-- )
			-- end
		end
		
		if(movedPx > screen:getHeight()) then
			break
		end
	end
	
	love.graphics.setCanvas()
end

return interface
