local CHANNEL_SEND_NAME, CHANNEL_RECEIVE_NAME = ...
local sendChannel = love.thread.getChannel(CHANNEL_SEND_NAME)
local receiveChannel = love.thread.getChannel(CHANNEL_RECEIVE_NAME)
CHANNEL_SEND_NAME = nil
CHANNEL_RECEIVE_NAME = nil

require('love.sound')
require('love.audio')
require('love.image')
require('love.video')
utf8 = require('utf8')

isThread = true

colors = require('colors') --dependency, not actually used
require('constants')
require('tools')

--loaders
local loaders = {}
local WHICH_LOADER = {
	background = 'image',
	foreground = 'image',
	script = 'script',
	sound = 'sound',
	video = 'video'
}
do 
	local dataToLove = love.filesystem.newFileData
	
	function loaders.sound(data, path)
		local success, src = pcall(love.audio.newSource,
			dataToLove(data, path), 
			'static'
		)
		
		if(success) then
			return src 
		end
	end
	
	function loaders.script(data)
		local script = string.split(
			string.fixEncoding(data),
			NEWLINEPTRN
		)
		data = nil
		for index, line in pairs(script) do
			do --clear leading and trailing whitespace
				local _, _, sstr = line:find('^%s*(.*)%s*$')
				line = sstr
			end
			
			do --clear comments
				local lineFirstChar = line:sub(1,1)
				if(
					(lineFirstChar == '#') or
					(lineFirstChar == ';')
				) then
					line = ''
				end
				--vnds2 has end of line comments.
				--however it may cause problems with backwards compatibility with normal vnds scripts.
				--so i wont support end of line comments for now.
			end
			script[index] = line
		end
		return script
	end
	function loaders.image(data, path)
		return dataToLove(data, path)
	end
	
	-- function loaders.video(data, path)
		
	-- end
end

while(true) do 
	local request = receiveChannel:pop()
	if(request) then
		local loader = loaders[WHICH_LOADER[
			request.which
		]]
		local result
		if(loader) then 
			result = loader(
				request.data, 
				request.path
			)
		end
	
		sendChannel:push({
			result = result, 
			id = request.id
		})
	else
		break
	end
end