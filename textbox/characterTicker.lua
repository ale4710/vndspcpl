local interface = {}

local workingLines
local currentLine
local currentFragment
local currentCharacter
local pfTable
local pfTableFragment

local done = true
local passedTime

local canvas

function interface.start(wl)
	if(wl and #wl ~= 0) then 
		print('[characterTicker] start animating')
		workingLines = wl
		currentLine = 1
		currentFragment = 1
		currentCharacter = 1
		done = false
		passedTime = 0
		pfTable = {}
		pfTableFragment = 1
	end
end

local draw --this is a function defined later.

function interface.checkDone()
	return done
end

function interface.forceDone()
	if(not done) then 
		print('[characterTicker] forced finish')
		done = true
		pfTable = {}
		for _, line in ipairs(workingLines) do 
			for _, part in ipairs(line.text) do 
				table.insert(pfTable, part)
			end
			local pftl = pfTable[#pfTable] --pfTable last
			if(pftl) then
				pfTable[#pfTable] = pftl .. '\n'
			end
		end
		draw()
		pfTable = nil
		workingLines = nil
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

--[[local]] function draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setColor(colora(colors.white, 1))
	--love.graphics.rectangle('fill',0,0,canvas:getWidth(),canvas:getHeight())
	love.graphics.setFont(font)
	--print(unpack(pfTable))
	love.graphics.printf(
		pfTable, 
		0, 0, 
		canvas:getWidth(), 
		'left'
	)
	love.graphics.setCanvas()
end
interface.draw = draw

function interface.update(dt) --this will return true when it is done with what it's doing
	--print('[characterTicker] updating...')
	if(not done or workingLines) then
		passedTime = passedTime + dt
		if(passedTime >= userSettings.textProgressionSpeed) then
			while(passedTime >= userSettings.textProgressionSpeed) do 
				if(currentLine <= #workingLines) then
					local cl = workingLines[currentLine].text
					local cfti = currentFragment * 2 --current fragment table index
					local pfti = pfTableFragment * 2
					if(cfti <= #cl) then
						if(pfTable[pfti - 1] == nil) then 
							pfTable[pfti - 1] = cl[cfti - 1]
						end
						local cft = cl[cfti]
						local textCharCount, brokenCharacter = utf8.len(cft)
						if(currentCharacter <= textCharCount) then
							local stringEnd = utf8.offset(cft, currentCharacter + 2)
							if(stringEnd) then 
								stringEnd = stringEnd - 1 
							end
							pfTable[pfti] = cft:sub(
								1, 
								stringEnd
							)
							currentCharacter = currentCharacter + 1
							passedTime = passedTime - userSettings.textProgressionSpeed
							--print(pfTable[cfti])
						else
							table.insert(pfTable, cl[cfti + 1])
							table.insert(pfTable, '')
							currentFragment = currentFragment + 1
							pfTableFragment = pfTableFragment + 1
							currentCharacter = 1
						end
					else
						currentLine = currentLine + 1
						currentFragment = 1
						if(#pfTable ~= 0) then
							pfTable[#pfTable] = pfTable[#pfTable] .. '\n'
						end
					end
				else
					done = true
					draw()
					pfTable = nil
					workingLines = nil
					print('[characterTicker] all done')
					return true
				end
			end
		end
		return false
	else
		return true
	end
end

return interface