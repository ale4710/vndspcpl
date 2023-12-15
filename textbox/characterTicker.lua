local interface = {}

local text
function interface.getTextInstance()
	return text
end

local remainingCharacters = {}
local printedCharacters = {}
local function clearCharacterTables()
	for id in pairs(remainingCharacters) do remainingCharacters[id] = nil end
	for id in pairs(printedCharacters) do printedCharacters[id] = nil end
end
local passedTime = 0

local width

function interface.start(wl)
	if(wl and #wl ~= 0) then 
		print('[characterTicker] start animating')
		--reset text
		if(text) then text:release() end
		text = nil
		--clear remainingCharacters and printedCharacters
		clearCharacterTables()
		--okay now turn fragments of text into characters
		for _, line in ipairs(wl) do 
			for _, textInfo in ipairs(line.rawFragments) do 
				local text = textInfo.text or ''
				for character = 1, #text, 1 do 
					table.insert(remainingCharacters, textInfo.color)
					table.insert(remainingCharacters, string.sub(text, character, character))
				end
			end
			--insert newline if not the last line
			if(line ~= #wl) then
				table.insert(remainingCharacters, VNDS_COLOR_CODES[37])
				table.insert(remainingCharacters, '\n')
			end
		end
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

function interface.forceDone()
	if(not done) then 
		print('[characterTicker] forcing finish on next update')
		passedTime = math.huge
	end
end

function interface.setWidth(w)
	--width = math.ceil(SCREEN.h / userSettings.textScale)
	width = math.ceil(w / userSettings.textScale)
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
			text:setf(
				printedCharacters,
				width, 
				'left'
			)
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