local mn = ...
local interface = {}

local CHANNEL_SEND_NAME = getUniqueId()
local CHANNEL_RECEIVE_NAME = getUniqueId()

local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)

local listing

local saveFileConverter = requirepp(mn, 'saveFileConverter')
interface.loadGame = requirepp(mn, 'loadGame')

local currentSaveFile = {
	script = 'main.scr',
	position = 0,
	variables = emptytable,
	music = '',
	background = '',
	sprites = emptytable
}
function interface.updateSaveFile(
	scriptFileName,
	position,
	music,
	backgroundImage,
	sprites
)
	currentSaveFile.script = scriptFileName or currentSaveFile.script

	--position is -1 because of lua
	currentSaveFile.position = (position and position - 1) or currentSaveFile.position
	
	currentSaveFile.music = music or currentSaveFile.music
	currentSaveFile.background = backgroundImage or currentSaveFile.background
	currentSaveFile.sprites = sprites or currentSaveFile.sprites
	
	--print(sprites)
	
	currentSaveFile.variables = variableHandler.variables
	
	-- print(
		-- saveFileConverter.serialize(currentSaveFile)
	-- )
end

interface.update = emptyfn

local SLOT_PREVIEW_TEXT_SPLITTER = ' / '
local SLOT_PREVIEW_STOP_COMMANDS = {}
--note: 'text' and 'choice' are handled seperately
for _, command in pairs({
	'fi',
	'jump',
	'jump',
	'goto'
}) do 
	SLOT_PREVIEW_STOP_COMMANDS[command] = true
end

local function updateSlot(file, slot)
	return Promise(function(responder)
		local valid = false

		local copiedFile = {}
		copiedFile.script = file.script
		copiedFile.position = file.position
		copiedFile.music = file.music
		copiedFile.background = file.background
		
		local updsVariables = {} --just in case the file is a choice
		copiedFile.variables = updsVariables
		table.shallowCopy(
			file.variables,
			updsVariables
		)
		
		copiedFile.sprites = {}
		table.shallowCopy(
			file.sprites,
			copiedFile.sprites
		)
		
		local item = {file = copiedFile}
		copiedFile = nil
		
		renderer:clear()
		
		local drawingOrder = {}
		
		--script
		vnResource.get('script', file.script):and_then(function(script)
			if(script == false) then 
				return Promise()
			else
				valid = true

				local text = ''
				for 
					position = file.position + 1, 
					1,
					-1
				do 
					local line = script[position]
					if(line) then
						local command, param = unpack(string.split(line, ' ', true, 1))
						if(command) then
							--print(command)
							command = command:lower()
							if(command == 'text') then
								local textCommand = ''
								if(param:find('^[!@~]')) then
									textCommand = param:sub(1,1)
									param = param:sub(2)
								end
								if(
									(
										#textCommand == 0 or
										textCommand:find('!')
									) and #text ~= 0
								) then 
									break
								end
								
								if(#param ~= 0) then
									text = param .. SLOT_PREVIEW_TEXT_SPLITTER .. text
								end
							elseif(command == 'choice') then
								if(#text == 0) then 
									item.choice = true
									text = '[Choice] '
									for _, choice in ipairs(
										string.split(param, '|', true)
									) do 
										choice = variableHandler.convertVariables(choice, updsVariables)
										text = text .. choice .. SLOT_PREVIEW_TEXT_SPLITTER
									end
								end
								break
							elseif(SLOT_PREVIEW_STOP_COMMANDS[command]) then
								break
							end
						end
					else
						break
					end
				end
				if(#text ~= 0) then
					item.text = text:sub(1, #text - #SLOT_PREVIEW_TEXT_SPLITTER)
				end
				
				local promises = {}
				
				--sprites
				for index, sprite in ipairs(file.sprites) do
					local spriteInfo = {
						x = sprite.x,
						y = sprite.y
					}
					drawingOrder[index] = spriteInfo

					local spritePromise = vnResource.get('foreground', sprite.path):and_then(function(image)
						if(image) then
							spriteInfo.image = image
						end
					end)
					
					table.insert(promises, spritePromise)
				end
				
				--background
				do
					local bgPromise = vnResource.get('background', file.background):and_then(function(image)
						if(image) then
							local p
							if(userSettings.centerBackgrounds) then
								p = {'center'}
							else
								p = {0, 0}
							end
							renderer:draw(image, unpack(p))
						end
					end)
					table.insert(promises, bgPromise)
				end
				
				return Promise(promises):all_settled()
			end
		end):finally(function()
			if(valid) then 
				listing[slot] = item

				--drawing
				for _, spriteInfo in ipairs(drawingOrder) do
					renderer:draw(
						spriteInfo.image,
						spriteInfo.x,
						spriteInfo.y
					)
				end
				drawingOrder = nil
				item.thumbnail = renderer:getThumbnail(100, 75)
				renderer:clear()
				
				--misc
				item.date = file.date
			else
				listing[slot] = {
					broken = true
				}
			end
			responder:resolve()
		end)
	end)
end

function interface.initialize(callback)
	interface.initialize = nil
	local dirListingThread = love.thread.newThread(mn .. '/dirListingThread.lua')
	interface.update = (function()
		local l = receiveChannel:pop()
		if(l) then 
			dirListingThread = nil
			listing = l
			interface.listing = l
			l = nil
			
			local pendingSaveFiles = taskCounter:new()
			local function psfr()
				pendingSaveFiles:remove()
			end
			pendingSaveFiles:add()
			pendingSaveFiles.eventTarget:add(function()
				interface.ready = true

				pendingSaveFiles = nil
				psfr = nil

				callback()
				callback = nil
			end)
			
			for saven in pairs(listing) do
				pendingSaveFiles:add()
				io.asqread(getSaveFilePath(saven)):and_then(function(file)
					if(saven == 'global') then
						local success, parsed = pcall(saveFileConverter.parseGlobal, file)
						if(success) then 
							variableHandler.global.load(parsed)
							-- print('------------')
							-- for k,v in pairs(parsed) do
								-- print(k,v)
							-- end
							-- print('------------')
						else
							print('[saveFileManager] global.sav failed to load!!!')
						end
						psfr()
					else
						local success, parsed = pcall(saveFileConverter.parse, file)
						if(success) then 
							updateSlot(
								parsed,
								saven
							):and_then(psfr)
						else
							listing[saven] = {
								broken = true
							}
							psfr()
						end
					end
				end)
			end
			psfr()
			
			--[[actual code started]]
			
			local writeThread = love.thread.newThread(mn .. '/write.lua')
			local pendingCallback
			local pendingSlot
			local pendingFile
			local function writeout(slot, file, callback)
				assert(
					type(callback) == 'function',
					'please assign a callback.'
				)
				
				pendingCallback = callback
				pendingSlot = slot
			
				sendChannel:push({
					slot = slot,
					file = pendingFile
				})
			
				if(not writeThread:isRunning()) then 
					writeThread:start(
						CHANNEL_RECEIVE_NAME,
						CHANNEL_SEND_NAME,
						gamepath
					)
				end
				
				-- print(
					-- saveFileConverter.serialize(
						-- saveFileConverter.parse(pendingFile)
					-- )
				-- )
			end
			interface.writeOut = writeout
			
			local function finishCallback(result)
				pendingCallback(result)
				pendingCallback = nil
				pendingSlot = nil
				pendingFile = nil
			end
			
			function interface.update()
				local result = receiveChannel:pop()
				if(result ~= nil) then
					--print(result)
					if(result) then
						if(type(pendingSlot) == 'number') then 
							if(pendingFile) then
								updateSlot(
									saveFileConverter.parse(pendingFile),
									pendingSlot
								):and_then((function()
									finishCallback(true)
								end))
							else
								listing[pendingSlot] = nil
								finishCallback(true)
							end
						else
							finishCallback(true)
						end
					else
						finishCallback(false)
					end
				end
			end
			
			function interface.save(slot, callback)
				pendingFile = saveFileConverter.serialize(currentSaveFile)
				writeout(slot, pendingFile, callback)
			end
			
			function interface.saveGlobal(variables, callback) 
				pendingFile = saveFileConverter.serializeGlobal(variables)
				writeout('global', pendingFile, callback)
			end
			
			function interface.delete(slot, callback) 
				writeout(slot, nil, callback)
			end
			
			--[[actual code ended]]
		end
	end)
	dirListingThread:start(
		CHANNEL_RECEIVE_NAME,
		gamepath
	)
end

return interface
