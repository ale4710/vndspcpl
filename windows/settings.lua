local interface = {}

local mainSettingsFrame

function interface.createSettingsWindow()
	mainSettingsFrame = loveframes.Create('frame')
	mainSettingsFrame:SetSize(400,300)
	mainSettingsFrame:Center()
	mainSettingsFrame:SetName('Settings')
	
	--tabs
	local tabs = loveframes.Create('tabs', mainSettingsFrame)
	tabs:SetSize(
		mainSettingsFrame:GetWidth() - 2,
		mainSettingsFrame:GetHeight() - 25 - 1
	)
	tabs:SetPos(1, 25)
	
	local tabPageHeight = tabs:GetHeight() - 25
	--page 1 - display
	do
		local panel = loveframes.Create('panel')
		panel:SetSize(tabs:GetWidth(), tabPageHeight)
		do --text box mode
			local label = loveframes.Create('text', panel)
			label:SetText('Text Box Position')
			label:SetPos(
				5, 10
			)
			
			local textBoxModeComboBox = loveframes.Create('multichoice', panel)
			textBoxModeComboBox:SetPos(115, 5)
			textBoxModeComboBox:SetWidth(100)
			local choices = {
				'Full Screen',
				'Bottom',
				'Top'
			}
			local choicesIndex = table.invert(choices)
			for index, choice in ipairs(choices) do 
				textBoxModeComboBox:AddChoice(choice)
				if(userSettings.textBoxMode + 1 == index) then
					textBoxModeComboBox:SetChoice(choice)
				end
			end
			choices = nil
			textBoxModeComboBox.OnChoiceSelected = (function()
				userSettings.textBoxMode = choicesIndex[textBoxModeComboBox:GetChoice()] - 1
			end)
		end
		do --text box minimum lines
			local label = loveframes.Create('text', panel)
			label:SetText('Minimum Text Box Lines')
			label:SetPos(
				5, 37
			)
			
			local minLineNumberBox = loveframes.Create('numberbox', panel)
			minLineNumberBox:SetMin(1)
			minLineNumberBox:SetValue(userSettings.textboxMinimumLines)
			minLineNumberBox:SetPos(155, 35)
			minLineNumberBox.OnValueChanged = (function(_, value)
				if(value % 1 == 0) then 
					userSettings.textboxMinimumLines = math.floor(value)
					textbox.calculateSizes()
				end
			end)
		end
		do --text progression speed
			local label = loveframes.Create('text', panel)
			label:SetText('Text Progression Speed')
			label:SetPos(
				5, 62
			)
			
			local textProgressionSpeedNumberBox = loveframes.Create('numberbox', panel)
			textProgressionSpeedNumberBox:SetMin(0)
			textProgressionSpeedNumberBox:SetMax(1000)
			textProgressionSpeedNumberBox:SetValue(math.floor(1 / userSettings.textProgressionSpeed))
			textProgressionSpeedNumberBox:SetPos(150, 60)
			textProgressionSpeedNumberBox.OnValueChanged = (function(_, value)
				userSettings.textProgressionSpeed = 1 / value
			end)
			
			local unitLabel = loveframes.Create('text', panel)
			unitLabel:SetText('characters/second')
			unitLabel:SetPos(
				150 + textProgressionSpeedNumberBox:GetWidth() + 5, 
				62
			)
		end
		do --show textbox when empty
			local showEmptyTextboxCheckbox = loveframes.Create('checkbox', panel)
			showEmptyTextboxCheckbox:SetPos(
				5, 85
			)
			showEmptyTextboxCheckbox:SetText('Hide Textbox When Empty')
			showEmptyTextboxCheckbox:SetChecked(not not userSettings.hideTextBoxWhenEmpty)
			showEmptyTextboxCheckbox.OnChanged = (function(_, value)
				userSettings.hideTextBoxWhenEmpty = value
			end)
		end
		tabs:AddTab(
			'Display',
			panel
		)
	end
end

return interface