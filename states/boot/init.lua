local bootstate = gameclass:addState('boot')

local display = ''
local thumbnailPlaceholderColor = {0.5,0.5,0.5}

local imagesToLoad = {
	'icon',
	'thumbnail'
}

local imagesLoadedAction = {
	icon = (function(imgData) 
		pcall(love.window.setIcon,
			love.image.newImageData(imgData.imageData)
		)
	end)
}


function bootstate:enteredState()
	updateWindowTitle('Now loading...')
	
	--create main screen
	renderer = rendererClass:new()
	
	--load metadata
	local metadataPromises = {}
	--info
	do 
		local infoPromise = io.asqread(gamepath .. '/info.txt'):and_then(
			(function(info)
				info = string.fixEncoding(info)
				for _, line in ipairs(string.split(info, NEWLINEPTRN)) do 
					local ls = string.split(line, '=', 2)
					if(ls[1] == 'title') then 
						gameInfo.title = ls[2]
					end
				end
			end)
		)
		
		table.insert(metadataPromises, infoPromise)
	end
	
	--images
	for _, imgName in pairs(imagesToLoad) do
		local imgPromise = io.asqread(gamepath .. '/' .. imgName .. '.png'):and_then(function(data)
			local imgData = love.filesystem.newFileData(
				data, '.png'
			)
			gameInfo.images[imgName] = {
				image = love.graphics.newImage(imgData),
				imageData = imgData
			}
		end)
		
		table.insert(metadataPromises, imgPromise)
	end
	
	local allMetadataPromise = Promise(metadataPromises):all_settled():and_then(function()
		allMetadataPromise = nil
	end)
	metadataPromises = nil
	
	--check for archives
	display = 'Loading archives...'
	vnResource.initialize():and_then(function()
		--load main script, see if it exists
		display = 'Confirming Validity...'
		vnResource.get('script', MAIN_SCR_FILE_NAME):and_then(function(script)
			--oh shoot! we have a script! OH MY GOD!!
			scriptHandler.loadScript(script)
			script = nil
			
			--confirmed a valid novel
			display = 'Now loading...'
			
			local promises = {}
			
			--img.ini
			do
				local imginiPromise = io.asqread(gamepath .. '/img.ini'):and_then(function(imgini)
					local dims = {
						width = VN_SCREEN.w,
						height = VN_SCREEN.h
					}

					for _, line in ipairs(string.split(imgini, NEWLINEPTRN)) do 
						local ls = string.split(line, '=', 2)
						local side = ls[1]
						if(dims[side]) then 
							dims[side] = math.floor(
								tonumber(ls[2]) or dims[side]
							)
						end
					end
					
					renderer:resize(
						dims.width,
						dims.height
					)
				end):finally(function()
					return Promise(function(responder)
						saveFileManager.initialize(function()
							responder:resolve()
						end)
					end)
				end)
				
				table.insert(promises, imginiPromise)
			end
			
			--font
			if(not userSettings.ignoreNovelFont) then 
				local fontPromise = io.asqread(gamepath .. '/default.ttf'):and_then(function(fontData)
					font = love.graphics.newFont(
						love.filesystem.newFileData(
							fontData, '.ttf'
						),
						fontSize
					)
					textbox.calculateSizes()
				end)
				
				table.insert(promises, fontPromise)
			end
			
			local finalPromise
			if(allMetadataPromise) then
				finalPromise = allMetadataPromise
			else
				finalPromise = Promise()
			end
			finalPromise:and_then(function()
				Promise(promises):all_settled():and_then(function()
					for imgName, imgData in pairs(gameInfo.images) do 
						local ilaFn = imagesLoadedAction[imgName]
						if(ilaFn) then 
							ilaFn(imgData)
						end
					end
					imagesLoadedAction = nil
					
					updateWindowTitle(gameInfo.title)
					
					--delete stuff we will never use anymore
					imagesToLoad = nil
					thumbnailPlaceholderColor = nil
					display = nil
					bootstate.draw = nil
					
					--overwrite something
					bootstate.enteredState = nil
					
					mainInit()
					self:gotoState('main')
				end)
			end)
		end):catch(function()
			--display = 'Could not find "script/main.scr"\nPlease check the directory, close the program, and try again.'
			--updateWindowTitle('Error occured...')
			vnResource.reset()
			messageBoxWS(
				'File Not Found',
				'File "/script/main.scr" in the directory "' .. (gamepath or '?') .. '"could not be found!\nPlease check the directory and try again.',
				'error'
			)
			self:gotoState('waiting')
		end)
	end)
end

function bootstate:draw()
	local thumbnailBottomPadding = 10
	local thumbnailHeight = SCREEN.h * 0.2
	local thumbnailWidth = thumbnailHeight * (4 / 3)
	
	local titleTextScale = userSettings.textScale * 1.25
	local titleHeight = globalFont:getHeight() * titleTextScale
	local titleWidthPF = SCREEN.w / titleTextScale
	local titleBottomPadding = 8
	
	local subtitleTextScale = userSettings.textScale * 0.8
	local subtitleHeight = globalFont:getHeight() * subtitleTextScale
	local subtitleWidthPF = SCREEN.w / subtitleTextScale
	
	local startY = (SCREEN.h / 2) - ((thumbnailBottomPadding + thumbnailHeight + titleHeight + titleBottomPadding + subtitleHeight) / 2)
	
	do
		local thumbnail = gameInfo.images.thumbnail
		if(thumbnail) then
			thumbnail = thumbnail.image
			love.graphics.setColor(colors.white)
			local tsw, tsh = thumbnail:getDimensions()
			local scale = aspectRatioScaler(
				tsw, tsh,
				thumbnailWidth, thumbnailHeight
			)
			
			love.graphics.draw(
				thumbnail,
				SCREEN.w / 2,
				startY + (thumbnailHeight / 2),
				0,
				scale, scale,
				tsw / 2,
				tsh / 2
			)
		else
			love.graphics.setColor(thumbnailPlaceholderColor)
			love.graphics.rectangle(
				'fill', 
				(SCREEN.w / 2) - (thumbnailWidth / 2),
				startY,
				thumbnailWidth,
				thumbnailHeight
			)
		end
	end
	
	love.graphics.setColor(colors.white)
	love.graphics.setFont(globalFont)
	
	--title
	love.graphics.printf(
		gameInfo.title,
		0, startY + thumbnailHeight + thumbnailBottomPadding,
		titleWidthPF,
		'center',
		0, titleTextScale
	)
	
	--subtitle
	love.graphics.printf(
		display,
		0, startY + thumbnailHeight + thumbnailBottomPadding + titleHeight + titleBottomPadding,
		subtitleWidthPF,
		'center',
		0, subtitleTextScale
	)
end

return bootstate
