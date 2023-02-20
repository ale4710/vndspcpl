return function(saveFile)
	return vnResource.get('script', saveFile.script):and_then(function(script)
		assert(script, 'Script not found.')
		
		--script stuff
		scriptHandler.loadScript(script)
		scriptHandler.jumpToLine(saveFile.position) -- dont +1 because progressing on main state will handle it
		
		--savefile
		saveFileManager.updateSaveFile(
			saveFile.script,
			saveFile.position + 1,
			saveFile.music,
			saveFile.background,
			saveFile.sprites
		)
		
		local promises = {}
		
		--graphics
		local pendingDraw = {}
		--collect background
		if(saveFile.background) then 
			local backgroundPromise = vnResource.get('background', saveFile.background):and_then(function(bg)
				--renderer:draw(bg, 0, 0)
				return {
					isBackground = true,
					--x and y is defined for fallback
					x = 0,
					y = 0,
					image = bg
				}
			end)
			
			table.insert(pendingDraw, 1, backgroundPromise)
		end
		
		--collect sprites
		if(
			saveFile.sprites and
			#saveFile.sprites ~= 0
		) then
			for _, sprite in ipairs(saveFile.sprites) do 
				local thisSpritePromise = vnResource.get('foreground', sprite.path):and_then(function(image)
					return {
						x = sprite.x,
						y = sprite.y,
						image = image
					}
				end)
				table.insert(
					pendingDraw,
					thisSpritePromise
				)
			end
		end
		
		--all collected, once all settled, draw
		--(clear screen in any case)
		renderer:clear()
		if(#pendingDraw ~= 0) then 
			--also insert promise into "promises" table for main all settled
			table.insert(
				promises,
				Promise(pendingDraw):all_settled():and_then(function(drawResults)
					for _, toDraw in ipairs(drawResults) do 
						toDraw = toDraw.value
						
						local params
						if(
							toDraw.isBackground and
							userSettings.centerBackgrounds
						) then
							params = {'center'}
						else
							params = {
								toDraw.x,
								toDraw.y
							}
						end
						
						if(toDraw) then 
							renderer:draw(
								toDraw.image,
								unpack(params)
							)
						end
					end
				end)
			)
		end
		--graphics end
		
		--bgm
		local bgm
		if(saveFile.music) then 
			local bgmpromise = vnResource.get('sound', saveFile.music):and_then(function(src)
				bgm = src
			end)
			table.insert(promises, bgmpromise)
		end
		
		--variables
		--   (this isnt a promise)
		variableHandler.reset()
		if(saveFile.variables) then
			for key, value in pairs(saveFile.variables) do
				--print('[saveFile/loading] var assign', key, value)
				variableHandler.variables[key] = value
			end
			variableHandler.copyGlobals()
		end
		
		--wait for all the promises to settle
		return Promise(promises):all_settled():and_then(function()
			--we dont need to do anything else
			
			--return needed stuff
			return {
				bgm = bgm
			}
		end)
	end)
end