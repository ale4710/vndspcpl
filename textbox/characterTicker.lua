local interface = {}

local text

local remainingCharacters = {}
local printedCharacters = {}
local function clearCharacterTables()
	for id in pairs(remainingCharacters) do remainingCharacters[id] = nil end
	for id in pairs(printedCharacters) do printedCharacters[id] = nil end
end
local passedTime = 0

local canvas

function interface.start(wl)
	if(wl and #wl ~= 0) then 
		print('[characterTicker] start animating')
		--reset text
		text:set('')
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

local draw --this is a function defined later.

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
	canvas = love.graphics.newCanvas(
		math.ceil(w / userSettings.textScale),
		math.ceil(SCREEN.h / userSettings.textScale)
	)
	--print(canvas:getDimensions())
	interface.canvas = canvas
end


--local is defined earlier
function draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setColor(colora(colors.white, 1))
	love.graphics.draw(text)
	love.graphics.setCanvas()
end
interface.draw = draw

function interface.update(dt) --this will return true when it is done with what it's doing
	if(not text) then 
		text = love.graphics.newText(font)
	end
	
	if(checkDone()) then 
		--already done
		return true
	else
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
				canvas:getWidth(), 
				'left'
			)
		end
		
		if(#remainingCharacters == 0) then 
			print('[characterTicker] all done')
			clearCharacterTables()
			draw()
			return true
		end
		return false
	end
end

return interface