return function(cmdArguments)
	--initialize some settings
	userSettings = {
		oneSoundEffectOnly = true,
		--whether or not multiple sound effects are allowed to be played
		
		textBoxMode = 1,
		--  how will the textbox be display **on startup**?
		--  (it can be changed during gameplay.)
		--0 = fullscreen
		--1 = bottom
		--2 = top
		
		textProgressionSpeed = 0.005,
		--  how fast will the text progress?
		--it is how many seconds each character will get.
		
		textScale = 0.4,
		--  scale factor of text.
		
		textboxBackgroundOpacity = 0.75,
		
		hideTextBoxWhenEmpty = true,
		
		ignoreNovelFont = false,
		
		allowSkippingTransitions = true,
		
		allowSkippingDelays = true,
		
		maxCacheEntries = 50,
		--  it is how many resources can be cached at one time
		
		hideMouseOnInactivity = true,
		
		hideDelayTimer = false,
		
		hideLoadingIndicator = false,
		
		hideAwaitingUserIndicator = false,
		
		disableSounds = false,
		
		indicateInfiniteSfx = false,
		
		textboxMinimumLines = 1,
		
		centerBackgrounds = true,
		
		holdToConfirmSaveFileAction = true
	}
	fontSize = 64

	--parsing arguments
	do
		local flagActions = {
			['window-title-additional'] = {
				after = (function(title)
					if(#title ~= 0) then 
						title = ' ' .. title
					end
					windowTitleAdditional = title
				end)
			},
			
			['allow-multiple-sound-effects'] = {
				during = (function()
					userSettings.oneSoundEffectOnly = false
				end)
			},
			
			['base-font-size'] = {
				after = (function(size)
					fontSize = tonumber(size) or fontSize
				end)
			},
			
			['text-box-mode'] = {
				after = (function(mode)
					userSettings.textBoxMode = math.clamp(
						0, 2, 
						math.floor(
							tonumber(mode) or userSettings.textBoxMode
						)
					)
				end)
			},
			
			['text-progression-speed'] = {
				after = (function(sec)
					userSettings.textProgressionSpeed = tonumber(sec) or userSettings.textProgressionSpeed
				end)
			},
			
			['text-scale'] = {
				after = (function(scale)
					userSettings.textScale = tonumber(scale) or userSettings.textScale
				end)
			},
			
			['textbox-background-opacity'] = {
				after = (function(op)
					op = tonumber(op) or (userSettings.textboxBackgroundOpacity * 100)
					
					userSettings.textboxBackgroundOpacity = math.clamp(
						0, 100,
						op
					) / 100
				end)
			},
			
			['show-textbox-when-empty'] = {
				during = (function()
					userSettings.hideTextBoxWhenEmpty = false
				end)
			},
			
			['ignore-novel-font'] = {
				during = (function()
					userSettings.ignoreNovelFont = true
				end)
			},
			
			['disallow-skipping-transitions'] = {
				during = (function()
					userSettings.allowSkippingTransitions = false
				end)
			},
			
			['disallow-skipping-delays'] = {
				during = (function()
					userSettings.allowSkippingDelays = false
				end)
			},
			
			['maximum-cache-entries'] = {
				after = (function(e)
					userSettings.maxCacheEntries = tonumber(e) or userSettings.maxCacheEntries
				end)
			},
			
			['keep-mouse-visible'] = {
				during = (function()
					userSettings.hideMouseOnInactivity = false
				end)
			},
			
			['hide-delay-timer'] = {
				during = (function()
					userSettings.hideDelayTimer = true
				end)
			},
			
			['hide-loading-indicator'] = {
				during = (function()
					userSettings.hideLoadingIndicator = true
				end)
			},
			
			['hide-awaiting-user-indicator'] = {
				during = (function()
					userSettings.hideAwaitingUserIndicator = true
				end)
			},
			
			['disable-sounds'] = {
				during = (function()
					userSettings.disableSounds = true
				end)
			},
			
			['indicate-infinite-sound-effects'] = {
				during = (function()
					userSettings.indicateInfiniteSfx = true
				end)
			},
			
			['text-box-minimum-lines'] = {
				after = (function(lines)
					lines = tonumber(lines)
					if(
						lines and
						((lines % 1) == 0)
					) then 
						userSettings.textboxMinimumLines = math.clamp(
							1, math.huge, 
							lines
						)
					end
				end)
			},
			
			['dont-center-backgrounds'] = {
				during = (function()
					userSettings.centerBackgrounds = false
				end)
			},
			
			['disable-hold-to-confirm-save-file-action'] = {
				during = (function()
					userSettings.holdToConfirmSaveFileAction = false
				end)
			},
			
			['bgm-volume'] = {
				after = (function(vol)
					vol = tonumber(vol)
					if(vol) then
						soundHandler.setBgmVolume(
							math.floor(math.clamp(0, 100, vol)) / 100
						)
					end
				end)
			},
			
			['sfx-volume'] = {
				after = (function(vol)
					vol = tonumber(vol)
					if(vol) then
						soundHandler.setSfxVolume(
							math.floor(math.clamp(0, 100, vol)) / 100
						)
					end
				end)
			},

			['debug-overlay'] = {
				during = (function()
					debugOverlay = require('debugOverlay')
				end)
			}
		}
		local lastFlagAction
		
		for argOrder, arg in ipairs(cmdArguments) do
			if(lastFlagAction) then
				if(type(lastFlagAction) == 'function') then 
					lastFlagAction(arg)
				end
				lastFlagAction = nil
			else
				local fa = flagActions[arg:sub(3)]
				if(fa) then
					if(fa.during) then
						fa.during()
					end

					lastFlagAction = fa.after
				elseif(argOrder == #cmdArguments) then
					gamepath = arg
				end
			end
		end
	end
end
