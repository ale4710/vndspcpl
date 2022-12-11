return function(cmdArguments)
	--initialize some settings
	userSettings = {
		oneSoundEffectOnly = false,
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
		
		disableSounds = false
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
			
			['one-sound-effect-only'] = {
				during = (function()
					userSettings.oneSoundEffectOnly = true
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
				if(argOrder == #cmdArguments) then
					gamepath = arg
				else
					local fa = flagActions[arg:sub(3)]
					if(fa) then
						if(fa.during) then
							fa.during()
						end

						lastFlagAction = fa.after
					end
				end
			end
		end
	end
end
