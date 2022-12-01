if(not isThread) then
	local tempFileDirectory = 'temporary-files-for-working-around-love/'
	local tempFileFullDirectory = love.filesystem.getSaveDirectory() .. '/' .. tempFileDirectory

	if(love.filesystem.getInfo(tempFileDirectory, 'directory')) then
		print('[tempFileHandler] cleaning directory...')
		for _, item in pairs(love.filesystem.getDirectoryItems(tempFileDirectory)) do 
			if(love.filesystem.getInfo(item, 'file')) then 
				--love.filesystem.remove(item)
				os.remove(love.filesystem.getSaveDirectory() .. '/' .. item)
			end
		end
		
		--debug.debug()
	end

	local occupied = {}

	local pendingDelete = {}
	do 
		local lastCheck = -math.huge
		local CHECK_INTERVAL = 5
		function _tempFilePeriodicDelete(force)
			local lnow = now()
			if(
				force or
				(lastCheck + CHECK_INTERVAL <= lnow)
			) then 
				lastCheck = lnow
				
				for index, path in pairs(pendingDelete) do 
					local success, err = os.remove(love.filesystem.getSaveDirectory() .. '/' .. path)
					print('delete', path, success, err)
					if(success) then
						occupied[path] = nil
						pendingDelete[index] = nil
					end
				end
			end
		end
	end

	local function remove(self)
		table.insert(
			pendingDelete, 
			self.filePath
		)
		self.removed = true
	end

	return function(filepath)
		return io.asqread(filepath):and_then(function(data)
			return Promise(function(responder)
				local fileExt
				do 
					local filepathSplit = string.split(filepath, '.', true)
					fileExt = '.' .. filepathSplit[#filepathSplit]
				end
			
				local tempFileName = 1
				while(occupied[tempFileDirectory .. tempFileName .. fileExt]) do 
					tempFileName = math.random(99999)
				end
				tempFileName = tempFileName .. fileExt
				
				local filePath = (tempFileDirectory .. tempFileName)
				
				love.filesystem.createDirectory(tempFileDirectory)
				
				local outFile = io.open(tempFileFullDirectory .. tempFileName, 'w+b')
				if(outFile) then
					outFile:write(data)
					outFile:close()
				else
					responder:reject('failed to open outfile')
					return
				end
				
				occupied[filePath] = true
				
				responder:resolve({
					filePath = filePath,
					remove = remove
				})
			end)
		end)
	end
end