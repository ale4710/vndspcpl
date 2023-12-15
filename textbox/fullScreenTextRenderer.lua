local interface = {}

local buffer
local characterAnimator
local mostRecent
function interface.initialize(b, ca, mr)
	buffer = b
	characterAnimator = ca
	mostRecent = mr
	interface.initialize = nil
end

local text
local function initializeText()
	if(not text) then
		text = love.graphics.newText(font)
	end
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
	initializeText()

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
		
		movedPx = movedPx + (cur.height or font:getHeight())
		
		if(cur and cur.text) then
			local y, w = (screen:getHeight() - movedPx), (screen:getWidth())
			
			--separator
			if(i == #mostRecent) then 
				local sh = (separatorHeight / userSettings.textScale)
				love.graphics.rectangle(
					'fill',
					0, y - (sh / 2),
					w, sh
				)
			end
			
			--text
			local characterAnimatorDone = characterAnimator.checkDone()
			if(
				i == #mostRecent and
				not characterAnimatorDone
			) then 
				--first and animating
				local ti = characterAnimator.getTextInstance()
				if(ti) then
					love.graphics.draw(ti, 0, y)
				end
			elseif(
				i > #mostRecent or
				characterAnimatorDone
			) then
				love.graphics.printf(cur.text, 0, y, w)
			end
		end
		
		if(movedPx > screen:getHeight()) then
			break
		end
	end
	
	love.graphics.setCanvas()
end

return interface
