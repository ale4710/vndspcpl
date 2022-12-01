local mn = ...

local interface = {}
local commandsInterface = {}

--misc tools
local function splitSpace(str, lim)
	return string.split(
		str,
		' ',
		true,
		lim
	)
end
commandsInterface.splitSpace = splitSpace

local function upkSplitSpace(...)
	return unpack(commandsInterface.splitSpace(...))
end
commandsInterface.upkSplitSpace = upkSplitSpace

--reset
function interface.reset() 
	gameInfo = {
		title = 'Untitled',
		images = {}
	}
	
	currentScript = nil
	currentScriptFileName = nil
	currentLine = 1

	font = globalFont
end
interface.reset()

local scriptLabels

--load script and other related fns
local function jumpToLine(line)
	currentLine = line
end
interface.jumpToLine = jumpToLine
commandsInterface.jumpToLine = jumpToLine

local function jumpToLabel(label)
	local line = scriptLabels[label]
	if(line) then
		jumpToLine(line)
		return true
	end
	
	return false
end
interface.jumpToLabel = jumpToLabel
commandsInterface.jumpToLabel = jumpToLabel

local function loadScript(script) 
	currentScript = script
	scriptLabels = {}
	for index, line in ipairs(script) do 
		--mark labels
		local command, label = upkSplitSpace(line)
		if(command == 'label') then
			scriptLabels[label] = index - 1
		end
	end
	jumpToLine(0)
end
interface.loadScript = loadScript

--script...
local scriptCommands = {}
for _, commandGroupName in pairs({
	'img',
	'text',
	'audio',
	'video',
	'if',
	'var',
	'choices',
	'etc'
}) do
	local commandGroup = requirepp(
		requireppName(mn, 'command'), 
		commandGroupName
	)(commandsInterface)
	for command, fn in pairs(commandGroup) do
		scriptCommands[command] = fn
	end
	package.loaded[commandGroupName] = nil
end

-------
local function progress()
	local pendingActions = {}
	local pendingDelay
	local stopHere = false
	local pendingScreenUpdate = false
	local pendingFGV = false
	while(true) do 
		currentLine = currentLine + 1
		local line = currentScript[currentLine]
		if(not line) then
			--force a jump back to the beginning
			local jat = scriptCommands.jump('main.scr')
			table.insert(
				pendingActions, 
				jat
			)
			stopHere = true
			print('[scriptHandler] reached the end of the file, so jumping to the beginning')
			break
		elseif(
			(#line == 0) or
			(not string.find(line, '[^%s]'))
		) then
			--empty line
			break
		else
			local command, arguments = upkSplitSpace(line, 1)
			command = command:lower()
			local commandFn = scriptCommands[command]
			if(commandFn) then
				local action, delay, screenUpdate, stop, flushGlobalVariables = commandFn(arguments)
				
				--print('[scriptHandler] looking at the following action:', command)
				--print(arguments)
				
				if(flushGlobalVariables) then
					pendingFGV = true
				end
				
				if(delay) then
					if(pendingDelay) then
						currentLine = currentLine - 1
						break
					else
						pendingDelay = delay
					end
				end
				
				if(screenUpdate) then 
					pendingScreenUpdate = true
				end
				
				if(action) then
					table.insert(pendingActions, action)
				end
				
				if(stop) then 
					stopHere = true
					print(
						'[scriptHandler] stopped at following: "' ..
						(command or '(nil)') .. '"'
					)
					break
				end
			else
				--invalid command
				print('[scriptHandler] unrecognized command "' .. (command or ('nil')) .. '"')
			end
		end
	end
	
	print('[scriptHandler] now on line ' .. (currentLine))
	
	return {
		delay = pendingDelay,
		stop = stopHere,
		screenUpdate = pendingScreenUpdate,
		flushGlobalVariables = pendingFGV,
		actions = pendingActions
	}
end
interface.progress = progress

return interface