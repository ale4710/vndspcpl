local interface = {}

local saveLoadFrame
local saveLoadList

local function getSaveFile(slot)
	return saveFileManager.listing[slot]
end

local function saveLoadFrameClosed()
	saveLoadFrame = nil
	saveLoadList = nil
end

local function updateSaveFileSlot(panel)
	
end

function interface.createSaveLoadWindow()
	if(not saveLoadFrame) then
		saveLoadFrame = loveframes.Create('frame')
		saveLoadFrame:SetName('Save & Load')
		--saveLoadFrame:ShowCloseButton(false)
		saveLoadFrame:SetSize(
			640, 480
		)
		saveLoadFrame:Center()
		saveLoadFrame.OnClose = saveLoadFrameClosed
		
		saveLoadList = loveframes.Create('list', saveLoadFrame)
		saveLoadList:SetSize(
			saveLoadFrame:GetWidth() - 3,
			saveLoadFrame:GetHeight() - 26
		)
		saveLoadList:SetPos(1,1)
		saveLoadList:SetY(25)
		saveLoadList:SetSpacing(2)
		
		interface.updateSaveLoadList()
	end
end

local saveFileActions = {
	['save'] = {
		clickFn = (function(obj)
			
		end),
		checkClickable = (function() return true end),
		text = 'Save'
	},
	['load'] = {
		clickFn = (function(obj)
			saveLoadFrame:Remove()
			saveLoadFrameClosed()
			
			local loadingMessage = loveframes.Create('frame')
			loadingMessage:SetName('Loading...')
			loadingMessage:ShowCloseButton(false)
			loadingMessage:Center()
			local loadingText = loveframes.Create('text', loadingMessage)
			loadingText:SetText('Loading...')
			loadingText:Center()
			
			saveFileManager.loadGame(
				getSaveFile(
					obj:GetProperty('saveFileSlot')
				).file
			):and_then(function()
				--remove message box
				loadingMessage:Remove()
			end):catch(function(err)
				print(err)
				
				loadingMessage:SetName('Error Occured')
				loadingMessage:ShowCloseButton(true)
				loadingText:SetText('An error has occured.\n' .. err)
				loadingText:Center()
			end)
		end),
		checkClickable = (function(saveFile)
			return saveFile and (not saveFile.broken)
		end),
		text = 'Load'
	},
	['delete'] = {
		clickFn = (function(obj)
			
		end),
		checkClickable = (function(saveFile)
			return saveFile
		end),
		text = 'Delete'
	},
}
local function saveFileSlotUpdate(obj)
	local buttonsPanel = obj:GetProperty('buttons')
	local buttonsVisible = false
	
	do
		if(obj:GetHover()) then 
			buttonsVisible = true
			goto setVisible
		end
		
		for _, childObj in pairs(buttonsPanel:GetChildren()) do 
			if(childObj:GetHover()) then 
				buttonsVisible = true
				goto setVisible
			end
		end
		
		for _, childObj in pairs(obj:GetChildren()) do 
			if(childObj:GetHover()) then 
				buttonsVisible = true
				goto setVisible
			end
		end
	end
	
	::setVisible::
	obj:GetProperty('buttons'):SetVisible(
		buttonsVisible
	)
end
function interface.updateSaveLoadList()
	saveLoadList:Clear()
	local height = 80
	local width = saveLoadList:GetWidth() - 16
	local imageWidth = (height * (4/3)) / width
	local buttonsWidth = 0.1
	--and the rest will be description and such
	local descriptionHeight = 0.8
	local descriptionPadding = 0.02
	for slot = 1, 99, 1 do 
		local saveFile = getSaveFile(slot)
		--main panel...
		local panel = loveframes.Create('panel', saveLoadList)
		panel:SetSize(
			width,
			height
		)
		--panel.Update = saveFileSlotUpdate
		
		--thumbnail
		if(saveFile and saveFile.thumbnail) then
			local thumbnail = loveframes.Create('image', panel)
			thumbnail:SetImage(saveFile.thumbnail)
			thumbnail:SetSize(saveFile.thumbnail:getDimensions())
			thumbnail:SetScale(
				aspectRatioScaler(
					saveFile.thumbnail:getWidth(),
					saveFile.thumbnail:getHeight(),
					width * imageWidth,
					height
				),
				nil
			)
			thumbnail:CenterWithinArea(
				0, 0,
				width * imageWidth,
				height
			)
		else
			local noImageText = loveframes.Create('text', panel)
			noImageText:SetText('No Thumbnail')
			noImageText:SetPos(
				width * imageWidth * 0.5,
				height * 0.5,
				true
			)
		end
		
		--basic info
		local basicInfo = loveframes.Create('text', panel)
		basicInfo:SetSize(
			width * (1 - imageWidth - buttonsWidth - (descriptionPadding * 2)),
			height * (1 - descriptionHeight)
		)
		basicInfo:SetPos(
			width * (imageWidth + descriptionPadding),
			0
		)
		local text = 'Slot #' .. slot
		if(saveFile) then
			if(saveFile.broken) then
				text = text .. ' (broken file)'
			else
				text = text .. ' / ' .. os.date('%H:%M %Y-%m-%d', saveFile.date)
			end
		else
			text = text .. ' (empty file)'
		end
		basicInfo:SetText(text)
		
		--preview text
		if(saveFile and saveFile.text) then
			local previewText = loveframes.Create('text', panel)
			previewText:SetSize(
				width * (1 - imageWidth - buttonsWidth - (descriptionPadding * 2)),
				height * descriptionHeight
			)
			previewText:SetPos(
				width * (imageWidth + descriptionPadding),
				height * (1 - descriptionHeight)
			)
			previewText:SetMaxWidth(previewText:GetWidth())
			previewText:SetText(saveFile.text)
		end
		
		--buttons
		local buttonsPanel = loveframes.Create('panel', panel)
		buttonsPanel:SetPos(
			width * (1 - buttonsWidth),
			0
		)
		buttonsPanel:SetSize(
			width * buttonsWidth,
			height
		)
		panel:SetProperty('buttons', buttonsPanel)
		for i, action in ipairs({
			'save',
			'load',
			'delete'
		}) do 
			local button = loveframes.Create('button', buttonsPanel)
			local actInfo = saveFileActions[action]
			button:SetText(actInfo.text)
			button:SetPos(
				0,
				(i - 1) * (height / 3)
			)
			button:SetSize(
				width * buttonsWidth,
				height / 3
			)
			if(actInfo.checkClickable(saveFile)) then
				button.OnClick = actInfo.clickFn
				button:SetProperty('saveFileSlot', slot)
			else
				button:SetClickable(false)
			end
		end
	end
end

return interface