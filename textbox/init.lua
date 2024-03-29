local mn = ...
local interface = {}

local previousPendingText
--pendingText = {} --global variable

local boxMargin = 15
local boxPadding = 15
local boxBackgroundColor = {colora(colors.black, userSettings.textboxBackgroundOpacity)}
local boxDefaultTextColor = colors.white
local boxMinHeight
local boxInnerWidth
local textInverseScale

local fullscreenTextRenderer = requirepp(mn, 'fullScreenTextRenderer')


local characterAnimator = requirepp(mn, 'characterTicker')
interface.animator = {
	checkDone = characterAnimator.checkDone,
	forceDone = characterAnimator.forceDone
}

local DUMMY_TEXT = {
	actualText = '',
	rawFragments = {{
		text = '',
	}}
}
local function regenerateDummyText()
	DUMMY_TEXT.text = {boxDefaultTextColor, ''}
	DUMMY_TEXT.rawFragments[1].color = boxDefaultTextColor
end
regenerateDummyText()

function interface.changeSettings(settingTable)
	settingTable = settingTable or emptytable
	boxMargin = settingTable.margin or boxMargin
	boxPadding = settingTable.padding or boxPadding
	boxBackgroundColor = settingTable.backgroundColor or boxBackgroundColor
	boxDefaultTextColor = settingTable.textColor or boxDefaultTextColor
	
	regenerateDummyText()
end

local buffer = {}
local maximumBufferSize = 1000
local mostRecent = {}
local mostRecentLineHeight = 0
local empty = true
local forceShow = false

fullscreenTextRenderer.initialize(
	buffer,
	characterAnimator,
	mostRecent
)

function clearTextBox()
	empty = true
end
interface.clearTextBox = clearTextBox
function interface.clearBuffer() 
	--buffer = {}
	for i in pairs(buffer) do 
		buffer[i] = nil
	end
	clearTextBox()
end

function interface.toggleForceShow(toggle) 
	if(toggle == nil) then
		toggle = not forceShow
	end
	forceShow = not not toggle
	return forceShow
end

function interface.calculateSizes()
	do 
		local t = love.graphics.newText(font)
		local s = 'a'
		if(userSettings.textboxMinimumLines > 1) then 
			s = s .. ('\na'):rep(userSettings.textboxMinimumLines - 1)
		end
		t:set(s)
		boxMinHeight = t:getHeight() * userSettings.textScale
		t:release()
	end
	
	boxInnerWidth = SCREEN.w - (boxMargin * 2)
	
	local textDisplayWidth = boxInnerWidth - (boxPadding * 2)
	characterAnimator.setWidth(textDisplayWidth)
	fullscreenTextRenderer.setWidth(textDisplayWidth)
	
	--idk...
	local sm = fullscreenTextRenderer.setMargin
	sm(boxPadding + boxMargin)
end

function calculateLineHeights(recentOnly)
	mostRecentLineHeight = 0
	local lines = (recentOnly and mostRecent) or buffer
	local text = love.graphics.newText(font)
	for index, line in ipairs(lines) do 
		if(line) then
			text:setf(
				line.actualText,
				(boxInnerWidth - (boxPadding * 2)) / userSettings.textScale,
				'left'
			)
			
			line.height = text:getHeight()
			
			if(
				recentOnly or
				(
					(not recentOnly) and
					(index >= #lines - #mostRecent)
				)
			) then 
				mostRecentLineHeight = mostRecentLineHeight + line.height
			end
		end
	end
	mostRecentLineHeight = mostRecentLineHeight * userSettings.textScale
	--memory stuff
	text:release()
end
function interface.recalculateLineHeights()
	calculateLineHeights()
end

function interface.processPendingText()
	if(
		pendingText and
		#pendingText ~= 0
	) then 
		for k in pairs(mostRecent) do 
			mostRecent[k] = nil
		end
		
		previousPendingText = pendingText
		
		for _, line in ipairs(pendingText) do --each in pendingText is a line.
			if(#line == 0) then
				table.insert(buffer, DUMMY_TEXT)
				--table.insert(mostRecent, DUMMY_TEXT)
			else
				local textInfo = {} 
				local pfcText = {} --printf colored text
				local actualText = ''
				
				for _, fragment in ipairs(line) do
					fragment.text = fragment.text or ''
					fragment.color = VNDS_COLOR_CODES[fragment.color] or boxDefaultTextColor
				
					table.insert(pfcText, fragment.color)
					
					table.insert(pfcText, fragment.text)
					actualText = actualText .. fragment.text
				end
				
				textInfo.text = pfcText
				textInfo.actualText = actualText
				textInfo.rawFragments = line
				
				table.insert(buffer, textInfo)
				table.insert(mostRecent, textInfo)
				empty = false
			end
		end
		
		if(#mostRecent == 0) then 
			clearTextBox()
			print('[textbox] no lines with text, so textbox is empty')
		else
			calculateLineHeights(true)
			characterAnimator.start(mostRecent)
		end
		fullscreenTextRenderer.draw()
	else
		clearTextBox()
	end
	pendingText = nil
end

function interface.update(dt)
	characterAnimator.update(dt)
end

function interface.draw() 
	local left = boxMargin
	local top = left
	
	if(userSettings.textBoxMode == 0) then
		--full screen text box
		love.graphics.setColor(boxBackgroundColor)
		love.graphics.rectangle('fill', 0, 0, SCREEN.w, SCREEN.h)
		
		fullscreenTextRenderer.draw()
		
		love.graphics.setBlendMode('alpha', 'premultiplied')
		for i = 1, 0, -1 do
			love.graphics.setColor(
				i == 0 and colors.white or
				colors.black
			)
			local drawOffset = i * 2
			love.graphics.draw(
				fullscreenTextRenderer.canvas,
				boxPadding + boxMargin + drawOffset,
				drawOffset,
				0, 
				userSettings.textScale
			)
		end
		love.graphics.setBlendMode('alpha')
	else
		--something else...
		if(
			userSettings.hideTextBoxWhenEmpty and 
			empty and
			not forceShow
		) then
			return
		end

		local boxInnerHeight = (boxPadding * 2) + math.max(
			boxMinHeight,
			mostRecentLineHeight
		)
		
		if(userSettings.textBoxMode == 1) then
			top = SCREEN.h - boxInnerHeight - boxMargin
		end
		
		love.graphics.setColor(boxBackgroundColor)
		love.graphics.rectangle(
			'fill', 
			left, top,
			boxInnerWidth,
			boxInnerHeight
		)

		if(not empty) then
			local charAnimTextInst = characterAnimator.getTextInstance()
			if(charAnimTextInst) then
				for i = 1, 0, -1 do
					love.graphics.setColor(
						i == 0 and colors.white or
						colors.black
					)
					local drawOffset = i * 2
					love.graphics.draw(
						charAnimTextInst,
						left + boxPadding + drawOffset,
						top + boxPadding + drawOffset,
						0, 
						userSettings.textScale
					)
				end

			
				
			end
		end
	end
end

return interface
