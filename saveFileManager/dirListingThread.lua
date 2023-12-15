local sendChannelName, directory = ...
local sendChannel = love.thread.getChannel(sendChannelName)
sendChannelName = nil

require('lib.lovefs') --it takes the variable "lovefs" ... uh oh, stinky...
isThread = true

local SAVEFILE_PATTERN = '^save(%d%d)%.sav$'

local savedirStr = directory .. '/save/'
require('love.system')
if(love.system.getOS() == 'Windows') then 
	savedirStr = savedirStr:gsub('/', '\\')
end

local savedir = lovefs()

local savefiles = {}

if(savedir:exists(savedirStr)) then 
	savedir:cd(savedirStr)
	if(#savedir.files ~= 0) then 
		for _, filename in ipairs(savedir.files) do
			filename = filename:lower()
			--first: find number.
			local _, _, index = filename:find(SAVEFILE_PATTERN)
			if(index) then 
				savefiles[tonumber(index)] = true
			else
				--failed? find global.
				if(filename == 'global.sav') then
					savefiles['global'] = true
				end
			end
		end
	end
else
	os.execute('mkdir "' .. savedirStr .. '"')
end

sendChannel:push(savefiles)