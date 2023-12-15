local interface = {}

local width

local text
function interface.getTextInstance()
	return text
end
local function setText(fstr)
	text:setf(
		fstr,
		width, 
		'left'
	)
end

local baseCharacters
local remainingCharacters = {}
local printedCharacters = {}
local function clearCharacterTables()
	for id in pairs(remainingCharacters) do remainingCharacters[id] = nil end
	for id in pairs(printedCharacters) do printedCharacters[id] = nil end
end
local function copyBaseToRemain()
	for i, c in pairs(baseCharacters) do 
		remainingCharacters[i] = c
	end
end
local passedTime = 0

function interface.start(wl)
	if(wl and #wl ~= 0) then 
		print('[characterTicker] start animating')
		--reset text
		if(text) then text:release() end
		text = nil
		--clear remainingCharacters and printedCharacters
		clearCharacterTables()
		--okay now turn fragments of text into characters
		baseCharacters = {}
		for _, line in ipairs(wl) do 
			for _, textInfo in ipairs(line.rawFragments) do 
				local text = textInfo.text or ''
				for character = 1, #text, 1 do 
					table.insert(baseCharacters, textInfo.color)
					table.insert(baseCharacters, string.sub(text, character, character))
				end
			end
			--insert newline if not the last line
			if(line ~= #wl) then
				table.insert(baseCharacters, VNDS_COLOR_CODES[37])
				table.insert(baseCharacters, '\n')
			end
		end
		copyBaseToRemain()
		--reset vars
		currentCharacter = 1
		done = false
		passedTime = 0
	end
end

local function checkDone() 
	return #remainingCharacters == 0
end
interface.checkDone = checkDone

local function forceDone()
	if(not done) then 
		print('[characterTicker] forcing finish on next update')
		passedTime = math.huge
	end
end
interface.forceDone = forceDone

function interface.setWidth(w)
	width = math.ceil(w / userSettings.textScale)
	if(text) then 
		text:set('')
		if(checkDone()) then
			setText(baseCharacters)
		end
	end
end

function interface.update(dt) --this will return true when it is done with what it's doing
	if(checkDone()) then 
		--already done
		return true
	else
		if(not text) then 
			text = love.graphics.newText(font)
		end
	
		passedTime = passedTime + dt
		if(passedTime >= userSettings.textProgressionSpeed) then 
			--timer
			local charactersToAdd = math.floor(passedTime / userSettings.textProgressionSpeed)
			passedTime = passedTime - (charactersToAdd * userSettings.textProgressionSpeed)
			charactersToAdd = math.min(charactersToAdd, #remainingCharacters)
			--shove text
			for i = 1, charactersToAdd, 1 do
				table.insert(
					printedCharacters,
					table.remove(remainingCharacters, 1)
				)
			end
			setText(printedCharacters)
		end
		
		if(#remainingCharacters == 0) then 
			print('[characterTicker] all done')
			clearCharacterTables()
			return true
		end
		return false
	end
end

return interface