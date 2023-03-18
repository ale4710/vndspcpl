local mn = ...

local lsState = gameclass:addState('loadsave')

local selected

local maximumSaveFiles = 99

local normalColor = colors.white
local cardBgColor = {colora(colors.black, 0.75)}
local selectedColor = colors.green
local modalBgColor = {colora(colors.black, 0.75)}
local slotIndicatorOpacity = 0.5
local emptyThumbnailFillColor = {colora(colors.white, 0.5)}
local brokenThumbnailFillColor = {colora(colors.red, 0.5)}
local lineWidth = 2

local columns = 2
local rows = 5

local rowOffset

local headerPadding = 10
local headerFontSizeMultiplier = 2

local top = (headerPadding * 2) + (globalFont:getHeight() * headerFontSizeMultiplier * userSettings.textScale)
local bottom = 60

local leftPadding = 30
local rightPadding = leftPadding
local gridItemPadding = 10

local innerPadding = 6

local descriptionFontSizeMultiplier = 0.7
local numberFontSizeMultiplier = 2

local cardWidth, cardHeight

local thumbnailAspectRatio = 4 / 3
local thumbnailWidth, thumbnailHeight

local gridCanvas
local gridCanvasDrawBuffer = 5

local function calculateSizes()
	cardWidth = ((SCREEN.w - leftPadding - rightPadding - (gridItemPadding * (columns - 1))) / columns)
	cardHeight = ((SCREEN.h - top - bottom - (gridItemPadding * (rows - 1))) / rows)
	
	thumbnailHeight = (cardHeight) - (innerPadding * 2)
	thumbnailWidth = thumbnailHeight * thumbnailAspectRatio
	
	gridCanvas = love.graphics.newCanvas(
		SCREEN.w + (gridCanvasDrawBuffer * 2), 
		SCREEN.h + (gridCanvasDrawBuffer * 2)
	)
end
calculateSizes()
SCREEN.resizeEvent:add(calculateSizes)

local function getSaveFile(slot)
	return saveFileManager.listing[slot]
end

local function drawCard(x, y, currentSlot, selected) 
	local color

	if(selected) then 
		color = selectedColor
	else
		color = normalColor
	end
	
	love.graphics.setColor(cardBgColor)
	love.graphics.rectangle(
		'fill',
		x, y,
		cardWidth,
		cardHeight
	)
	love.graphics.setColor(color)
	love.graphics.rectangle(
		'line',
		x, y,
		cardWidth,
		cardHeight
	)
	
	local saveFile = getSaveFile(currentSlot)
	do 
		local tx = x + thumbnailWidth + (innerPadding * 2)
		local ty = y + innerPadding
		local ts = userSettings.textScale * descriptionFontSizeMultiplier
		
		love.graphics.setColor(colors.black)
		love.graphics.rectangle(
			'fill',
			x + innerPadding,
			y + innerPadding,
			thumbnailWidth,
			thumbnailHeight
		)
		love.graphics.setColor(color)
		
		if(saveFile) then
			if(saveFile.broken) then
				love.graphics.print(
					'Broken File',
					tx, ty, 0, ts
				)
				
				love.graphics.setColor(brokenThumbnailFillColor)
				love.graphics.rectangle(
					'fill',
					x + innerPadding,
					y + innerPadding,
					thumbnailWidth,
					thumbnailHeight
				)
			else
				local textInnerWidth = cardWidth - thumbnailWidth - (innerPadding * 3)
				love.graphics.setFont(font)
				love.graphics.setScissor(
					tx, ty,
					textInnerWidth,
					cardHeight - (innerPadding * 2)
				)
				love.graphics.printf(
					saveFile.text or 'No preview text available.',
					tx,
					ty,
					(textInnerWidth / ts),
					'left',
					0,
					ts
				)
				love.graphics.setScissor()
				love.graphics.setFont(globalFont)
				
				love.graphics.setColor(colors.white)
				local tbs = aspectRatioScaler(
					saveFile.thumbnail:getWidth(),
					saveFile.thumbnail:getHeight(),
					thumbnailWidth,
					thumbnailHeight
				)
				love.graphics.draw(
					saveFile.thumbnail,
					x + innerPadding,
					y + innerPadding,
					0,
					tbs
				)
			end
		else
			love.graphics.print(
				'Empty',
				tx, ty, 0, ts
			)
			
			love.graphics.setColor(emptyThumbnailFillColor)
			love.graphics.rectangle(
				'fill',
				x + innerPadding,
				y + innerPadding,
				thumbnailWidth,
				thumbnailHeight
			)
		end
	end
	
	love.graphics.setColor(colora(color, slotIndicatorOpacity))
	love.graphics.printf(
		currentSlot,
		x, 
		y + cardHeight - (globalFont:getHeight() * userSettings.textScale * numberFontSizeMultiplier), 
		(cardWidth - innerPadding) / (userSettings.textScale * numberFontSizeMultiplier),
		'right',
		0,
		userSettings.textScale * numberFontSizeMultiplier
	)
end

local lsStateSubstates = class('lsStateSubstates'):include(stateful)
local lsssMainState = lsStateSubstates:addState('main')
lsStateSubstates.draw = emptyfn
lsStateSubstates.input = emptyfn
lsStateSubstates.update = emptyfn
local lsssFunc = lsStateSubstates:new()

local scrollMan = scrollingListDisplayManagerClass:new(rows)
scrollMan.elementSize = 1

function lsState:enteredState()
	selected = 1
	rowOffset = 0
	
	scrollMan.drawTopPosition = 0
	scrollMan.targetPosition = 0
	self.currentElement = 1
	
	lsssFunc:gotoState('main')
end

local function getSaveSlotOffset()
	return (math.floor(scrollMan.drawTopPosition) * columns) + 1
end

local function setGridScissor()
	local scissorBuffer = gridItemPadding / 2
	love.graphics.setScissor(
		leftPadding - scissorBuffer,
		top - scissorBuffer, 
		SCREEN.w - leftPadding - rightPadding + (scissorBuffer * 2),
		SCREEN.h - top - bottom + (scissorBuffer * 2)
	)
end

function lsState:draw()
	--draw the game screen under everything else
	states['main']:draw()
	
	--bg
	love.graphics.setColor(colora(colors.black, 0.7))
	love.graphics.rectangle(
		'fill',
		0, 0,
		SCREEN.w, SCREEN.h
	)
	
	--[[
	--border lines
	do
		love.graphics.setColor(normalColor)
		--   top
		local blx = top - (gridItemPadding / 2)
		love.graphics.line(
			0, blx,
			SCREEN.w, blx
		)
		--   bottom
		local bly = SCREEN.h - bottom + (gridItemPadding / 2)
		love.graphics.line(
			0, bly,
			SCREEN.w, bly
		)
	end
	]]

	--header
	love.graphics.setFont(globalFont)
	love.graphics.setColor(normalColor)
	love.graphics.print(
		'Save File Manager',
		headerPadding,
		headerPadding,
		0,
		userSettings.textScale * headerFontSizeMultiplier
	)
	
	local drawingCard = 0
	local saveFileIndexOffset = getSaveSlotOffset()
	
	love.graphics.setLineWidth(lineWidth)
	
	love.graphics.setCanvas(gridCanvas)
	love.graphics.clear()
	
	
	for
		cr = 0,
		rows,
		1
	do 
		local y = gridCanvasDrawBuffer + ((cardHeight + gridItemPadding) * (cr - (scrollMan.drawTopPosition % 1)))
		for
			cc = 0,
			columns - 1,
			1
		do
			local currentSlot = (saveFileIndexOffset + drawingCard)
			local x = gridCanvasDrawBuffer + ((cardWidth + gridItemPadding) * cc)
			
			drawCard(
				x, y,
				currentSlot,
				(selected == currentSlot)
			)
			
			
			if(maximumSaveFiles == currentSlot) then 
				goto finish
			end
			
			drawingCard = drawingCard + 1
		end
	end
	
	::finish::
	love.graphics.setCanvas()
	love.graphics.setColor(colors.white)
	setGridScissor()
	love.graphics.setBlendMode('alpha', 'premultiplied')
	love.graphics.draw(
		gridCanvas,
		leftPadding - gridCanvasDrawBuffer,
		top - gridCanvasDrawBuffer
	)
	love.graphics.setBlendMode('alpha')
	love.graphics.setScissor()
	
	lsssFunc:draw()
end

function lsState:update(dt)
	lsssFunc:update(dt)
end

function lsssMainState:input(action)
	--list?
	do 
		local nav = INPUT_NAVIGATION_LIST_HELPER[action]
		if(nav) then 
			local move = nav.move
			if(nav.vertical) then 
				move = move * columns
			end
			
			selected = navigateList(
				selected, 
				move, 
				maximumSaveFiles
			)
			
			scrollMan:scrollElementIntoView(
				math.ceil(selected / columns)
			)
			
			-- print(
				-- math.ceil(selected / columns),
				-- scrollMan.targetPosition
			-- )
			return
		end
	end
	
	--other?
	if(action == INPUT_ACTIONS.select) then
		self:gotoState('saveFileAction')
	elseif(action == INPUT_ACTIONS.cancel) then
		game:gotoState('main')
	end
end
function lsState:input(action)
	lsssFunc:input(action)
end

local saveFileModal = {}
do
	saveFileModal.padding = 10
	
	local function getHeightBeforeText()
		return cardHeight + (saveFileModal.padding * 2)
	end
	
	function saveFileModal.getHeight()
		return getHeightBeforeText() + (globalFont:getHeight() * userSettings.textScale) + saveFileModal.padding
	end
	
	function saveFileModal.getTextYpos()
		return (SCREEN.h / 2) - (saveFileModal.getHeight() / 2) + getHeightBeforeText()
	end
	
	function saveFileModal.draw()
		local h = saveFileModal.getHeight()
		local y = (SCREEN.h / 2) - (h / 2)
		
		love.graphics.setColor(modalBgColor)
		love.graphics.rectangle(
			'fill', 
			0, y,
			SCREEN.w, h
		)
		
		drawCard(
			(SCREEN.w / 2) - (cardWidth / 2),
			y + saveFileModal.padding,
			selected
		)
	end
end

--[[repeat after me]]
local showFreeMessageModal
do
	local displayMessage
	local selectCallback
	local lsssFreeMessageModal = lsStateSubstates:addState('freeMessage')
	function lsssFreeMessageModal:draw()
		saveFileModal.draw()
		love.graphics.setFont(globalFont)
		love.graphics.setColor(normalColor)
		love.graphics.printf(
			displayMessage,
			0,
			saveFileModal.getTextYpos(),
			SCREEN.w / userSettings.textScale,
			'center',
			0,
			userSettings.textScale
		)
	end
	function lsssFreeMessageModal:input(action)
		--print(selectCallback)
		if(
			selectCallback and
			(
				action == INPUT_ACTIONS.select or
				action == INPUT_ACTIONS.cancel
			)
		) then 
			selectCallback()
		end
	end
	function lsssFreeMessageModal:exitedState()
		selectCallback = nil
		displayMessage = nil
	end
	
	showFreeMessageModal = (function(message, callback)
		if(not displayMessage) then 
			lsssFunc:gotoState('freeMessage')
		end
		
		displayMessage = message or '...'
		
		--print(callback, type(callback))
		selectCallback = ((type(callback) == 'function') and callback) or nil
	end)
end

--[[what can you do with a save file?]]
do
	local selectedAction
	local currentActions

	local SAVE_FILE_ACTIONS = {
		'back',
		'save', 
		'load', 
		'delete'
	}
	
	local BUTTON_LABELS = {
		['back'] = 'Back',
		['save'] = 'Save',
		['load'] = 'Load',
		['delete'] = 'Delete'
	}
	
	local buttonHoldLength = 1
	local buttonHoldStart
	function checkButtonHoldTime() 
		return (
			buttonHoldStart and ((now() - buttonHoldStart) / buttonHoldLength)
		) or 0
	end
	
	local function checkIfExists()
		return not not getSaveFile(selected)
	end

	local SAVE_FILE_ACTION_CHECK = {
		['load'] = checkIfExists,
		['delete'] = checkIfExists
	}
	
	local function returnToMain()
		lsssFunc:gotoState('main')
	end
	
	local function returnToSFAcallback()
		lsssFunc:gotoState('saveFileAction')
	end
	--print(returnToSFAcallback)

	local function finishCallback()
		showFreeMessageModal('Done.', returnToMain)
	end
	
	local function showFailedMessage()
		showFreeMessageModal('Error Occured.', returnToMain)
	end
	
	local SAVE_FILE_ACTION_FNS = {
		['back'] = returnToMain,
		['save'] = (function()
			showFreeMessageModal('Saving...')
			saveFileManager.save(selected, function(success)
				if(success) then
					finishCallback()
				else
					showFailedMessage()
				end
			end)
		end),
		['load'] = (function()
			--local loadGame = requirepp(mn, 'loader')
			local loadGame = saveFileManager.loadGame
			return function()
				local file = getSaveFile(selected)
				
				if(file.broken) then
					showFreeMessageModal('Cannot load a broken file.', returnToSFAcallback)
				else
					file = file.file
					showFreeMessageModal('Loading...')
					
					loadGame(file):and_then(function(gameInfo)
						print('[loadsave] load successful!')
						game:gotoState('main')
					end):catch(function(err)
						print(err)
						showFailedMessage()
					end)
					
				end
			end
		end)(),
		['delete'] = (function()
			showFreeMessageModal('Deleting...')
			saveFileManager.delete(selected, function(success)
				if(success) then
					finishCallback()
				else
					showFailedMessage()
				end
			end)
		end)
	}
	
	local buttonPadding = SCREEN.w * 0.25
	
	local lsssSaveFileAction = lsStateSubstates:addState('saveFileAction')
	function lsssSaveFileAction:enteredState()
		selectedAction = 1
		buttonHoldStart = nil
		
		currentActions = {}
	
		for _, action in ipairs(SAVE_FILE_ACTIONS) do
			local check = SAVE_FILE_ACTION_CHECK[action]
			if(
				(
					check and
					check(selected)
				) or (
					not check
				)
			) then 
				table.insert(
					currentActions,
					action
				)
			end
		end
	end
	
	function lsssSaveFileAction:draw()
		saveFileModal.draw()
		do
			love.graphics.setFont(globalFont)
			local y = saveFileModal.getTextYpos()
			local buttonSpace = (SCREEN.w - (buttonPadding * 2))
			if(checkButtonHoldTime() ~= 0) then 
				love.graphics.setColor(normalColor)
				love.graphics.printf(
					'Hold To Confirm ' .. (BUTTON_LABELS[currentActions[selectedAction]] or '(Unknown)'),
					buttonPadding,
					y,
					buttonSpace / userSettings.textScale,
					'center',
					0,
					userSettings.textScale
				)
			else
				local buttonWidth = (buttonSpace / #currentActions)
				for index, action in ipairs(currentActions) do 
					if(index == selectedAction) then
						love.graphics.setColor(selectedColor)
					else
						love.graphics.setColor(normalColor)
					end
					
					local x = buttonPadding + (buttonWidth * (index - 1))
					local width = buttonWidth / userSettings.textScale
					
					love.graphics.printf(
						BUTTON_LABELS[action],
						x,
						y,
						width,
						'center',
						0,
						userSettings.textScale
					)
				end
			end
			
		end
	end
	
	function lsssSaveFileAction:update()
		if(checkInputActionDown(INPUT_ACTIONS.select)) then
			if(checkButtonHoldTime() >= 1) then
				SAVE_FILE_ACTION_FNS[currentActions[selectedAction]]()
			end
		else
			buttonHoldStart = nil
		end
	end
	
	function lsssSaveFileAction:input(action)
		if(checkButtonHoldTime() == 0) then
			local nav = INPUT_NAVIGATION_LIST_HELPER[action]
			if(
				nav and
				(not nav.vertical)
			) then 
				selectedAction = navigateList(selectedAction, nav.move, #currentActions)
				return
			end
		end
		
		if(action == INPUT_ACTIONS.select) then
			buttonHoldStart = now()
			
			if(
				(not userSettings.holdToConfirmSaveFileAction) or
				currentActions[selectedAction] == 'back'
			) then
				SAVE_FILE_ACTION_FNS[currentActions[selectedAction]]()
			end
		elseif(
			(action == INPUT_ACTIONS.cancel) and
			(checkButtonHoldTime() == 0)
		) then
			self:gotoState('main')
		end
	end
end

return lsState
