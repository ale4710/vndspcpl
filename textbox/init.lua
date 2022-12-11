local mn = ...
local interface = {}

local previousPendingText
--pendingText = {} --global variable

local boxMargin = 15
local boxPadding = 15
local boxBackgroundColor = {colora(colors.black, 0.75)}
local boxDefaultTextColor = colors.white
local boxMinHeight
local boxInnerWidth
local textInverseScale
local lineHeight

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
	characterAnimator
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
	lineHeight = font:getHeight() * userSettings.textScale
	boxMinHeight = lineHeight * 4
	
	boxInnerWidth = SCREEN.w - (boxMargin * 2)
	
	local textDisplayWidth = boxInnerWidth - (boxPadding * 2)
	characterAnimator.setWidth(textDisplayWidth)
	fullscreenTextRenderer.setWidth(textDisplayWidth)
	
	--idk...
	local sm = fullscreenTextRenderer.setMargin
	sm(boxPadding + boxMargin)
	--fullScreenTextRenderer.setMargin(boxMargin)
	
	if(previousPendingText) then
		pendingText = previousPendingText
		interface.processPendingText()
	end
end

function calculateLineHeights(recentOnly)
	mostRecentLineHeight = 0
	local lines = (recentOnly and mostRecent) or buffer
	for index, line in ipairs(lines) do 
		if(line) then
			local success, errorIfNotSuccess, wt = pcall(font.getWrap, font,
				line.actualText, boxInnerWidth / userSettings.textScale
			)

			if(not success) then 
				print('[textbox] invalid utf8 string "' .. line.actualText .. '"')
				error(errorIfNotSuccess)
			end
			
			errorIfNotSuccess = nil
			success = nil
			
			line.height = #wt
			
			if(
				recentOnly or
				(
					(not recentOnly) and
					(index >= #lines - #mostRecent)
				)
			) then 
				mostRecentLineHeight = mostRecentLineHeight + #wt
			end
		end
	end
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
					table.insert(pfcText, VNDS_COLOR_CODES[fragment.color] or boxDefaultTextColor)
					
					local text = fragment.text or ''
					table.insert(pfcText, text)
					actualText = actualText .. text
					
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
			if(userSettings.textBoxMode == 0) then 
				characterAnimator.forceDone()
			end
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

		love.graphics.setColor(boxBackgroundColor)
		love.graphics.rectangle('fill', 0, 0, SCREEN.w, SCREEN.h)
		
		--fullscreenTextRenderer.draw()
		
		love.graphics.setColor(colors.white)
		love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.draw(
			fullscreenTextRenderer.canvas,
			boxPadding + boxMargin,
			0,
			0, 
			userSettings.textScale
		)
		love.graphics.setBlendMode('alpha')
	else
		if(
			userSettings.hideTextBoxWhenEmpty and 
			empty and
			not forceShow
		) then
			return
		end

		local boxInnerHeight = (boxPadding * 2) + math.max(
			boxMinHeight,
			mostRecentLineHeight * lineHeight
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
		
		love.graphics.setColor(colors.white)

		if(not empty) then
			if(not characterAnimator.checkDone()) then characterAnimator.draw() end
			love.graphics.setBlendMode('alpha', 'premultiplied')
			love.graphics.draw(
				characterAnimator.canvas,
				left + boxPadding,
				top + boxPadding,
				0, 
				userSettings.textScale
			)
			love.graphics.setBlendMode('alpha')
		end
	end
end

return interface
