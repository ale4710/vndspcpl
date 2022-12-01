local interface = {}

local ZIP_MAGIC_NUMBER = 'PK\x03\x04'
local EOCD_MAGIC_NUMBER = 'PK\x05\x06'
local CD_ENTRY_MAGIC_NUMBER = 'PK\x01\x02'

interface.readFlags = 'r'
if(
	love and
	love.system and
	love.system.getOS() == 'Windows'
) then 
	interface.readFlags = interface.readFlags .. 'b' 
end

local function bytesToNumber(str, len, offset, reverse)
	if(len == nil) then 
		len = math.min(#str, 4)
	end

	assert(type(len) == 'number', 'len must be number.')
	assert(len > 0, 'len must be bigger than 0.')
	assert(len <= 4, 'len cannot be more than 4, due to 32 bit limitations.')


	--print(offset, #str - len)
	offset = (
		(type(offset) == 'number') and
		((offset) <= (#str - len)) and
		offset
	) or 0
	
	if(reverse) then 
		str = str:sub(1 + offset, offset + len):reverse()
		offset = 0
	end
	
	local n = 0
	for i = 1, len, 1 do 
		local byte = string.byte(str:sub(
			i + offset,
			i + offset
		))
		--n = (n + (byte << (8 * (i - 1))))
		--https://ebens.me/post/simulate-bitwise-shift-operators-in-lua/
		n = (n + (byte * (2 ^ (8 * (i - 1)))))
	end
	
	return n
end

--local function getMissingHeaderInfo()end

local function parseHeader(str, offset) --return {}, n
	offset = offset or 0
	
	local isLocalHeader = false
	if(
		str:sub(
			offset + 1,
			offset + 2
		) == 'PK'
	) then 
		local sigPart2 = str:sub(
			offset + 3,
			offset + 4
		)
		if(sigPart2 == '\3\4') then
			isLocalHeader = true
		elseif(sigPart2 ~= '\1\2') then
			error('unknown header type')
		end
	else
		error('not a header')
	end
	
	local currentOffset = offset + 4
	
	local versionMade
	if(not isLocalHeader) then 
		versionMade = bytesToNumber(
			str,
			2, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 2
	end
	
	local minVersionToExtract = bytesToNumber(
		str,
		2, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 2
	
	local generalBitFlag = bytesToNumber(
		str,
		2, 
		currentOffset,
		false
	)
	currentOffset = currentOffset + 2
	
	local compressionMethod = bytesToNumber(
		str,
		2, 
		currentOffset,
		false
	)
	currentOffset = currentOffset + 2
	
	local lastModifiedTime = bytesToNumber(
		str,
		2, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 2
	
	local lastModifiedDate = bytesToNumber(
		str,
		2, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 2
	
	local fileCRC32 = bytesToNumber(
		str,
		4, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 4
	
	local compressedSize = bytesToNumber(
		str,
		4, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 4
	
	local uncompressedSize = bytesToNumber(
		str,
		4, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 4
	
	local fileNameLength = bytesToNumber(
		str,
		2, 
		currentOffset, 
		false
	)
	--print(fileNameLength)
	currentOffset = currentOffset + 2
	
	local extraFieldLength = bytesToNumber(
		str,
		2, 
		currentOffset, 
		false
	)
	currentOffset = currentOffset + 2
	
	local fileCommentLength, fileDiskNumber, fileAttributesInt, fileAttributesExt, localFileHeaderOffset
	if(not isLocalHeader) then 
		fileCommentLength = bytesToNumber(
			str,
			2, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 2
		
		fileDiskNumber = bytesToNumber(
			str,
			2, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 2
		
		fileAttributesInt = bytesToNumber(
			str,
			2, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 2
		
		fileAttributesExt = bytesToNumber(
			str,
			4, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 4
		
		localFileHeaderOffset = bytesToNumber(
			str,
			4, 
			currentOffset, 
			false
		)
		currentOffset = currentOffset + 4
	end
	
	local missingInfo = false
	local fileName, extraField, fileComment
	if(currentOffset >= #str) then 
		missingInfo = true
		fileName = {
			s = currentOffset, 
			l = fileNameLength
		}
		extraField = extraFieldLength
		fileComment = fileCommentLength
		
		currentOffset = currentOffset + fileNameLength + extraFieldLength + (fileCommentLength or 0)
	else
		fileName = str:sub(currentOffset + 1, currentOffset + fileNameLength)
		currentOffset = currentOffset + fileNameLength
		
		extraField = str:sub(currentOffset + 1, currentOffset + extraFieldLength)
		currentOffset = currentOffset + extraFieldLength
		
		if(fileCommentLength) then 
			fileComment = str:sub(currentOffset + 1, currentOffset + fileCommentLength)
			currentOffset = currentOffset + fileCommentLength
		end
	end
	
	return {
		isLocalHeader = isLocalHeader,
		missingInfo = missingInfo,
		
		fileName = fileName,
		fileComment = fileComment,
		extraField = extraField,
		versionMade = versionMade,
		minVersionToExtract = minVersionToExtract,
		generalBitFlag = generalBitFlag,
		compressionMethod = compressionMethod,
		lastModifiedDate = lastModifiedDate,
		lastModifiedTime = lastModifiedTime,
		fileCRC32 = fileCRC32,
		compressedSize = compressedSize,
		uncompressedSize = uncompressedSize,
		fileDiskNumber = fileDiskNumber,
		internalFileAttributes = fileAttributesInt,
		externalFileAttributes = fileAttributesExt,
		localFileHeaderOffset = localFileHeaderOffset
	}, currentOffset - offset
end

local function getFile(self, path) 
	local fileEntry = self.files[path]
	if(fileEntry) then 
		local fh = self._fileHandle
		fh:seek('set', fileEntry.localFileHeaderOffset)
		local success, errIfNotSuccess, headerSize = pcall(parseHeader, fh:read(30))
		if(success) then
			errIfNotSuccess = nil
			fh:seek(
				'set', 
				fileEntry.localFileHeaderOffset + headerSize
			)
			return fh:read(fileEntry.compressedSize)
		else
			return nil, errIfNotSuccess
		end
	else
		return nil, 'file not found'
	end
end

local function kill(self)
	if(not self.killed) then 
		self._fileHandle:close()
		self._fileHandle = nil
		self.files = nil
		self.getFile = nil
		self.killed = true
	end
end

function interface.open(path)
	local archive, err = io.open(path, interface.readFlags)
	if(archive) then
		--is zip archive??
		if(
			archive:read(#ZIP_MAGIC_NUMBER) ==
			ZIP_MAGIC_NUMBER
		) then
			local archiveSize = archive:seek('end')
			--print(archiveSize)
			
			local instanceTable = {
				getFile = getFile,
				kill = kill,
				_fileHandle = archive
			}
			
			--find end of eocd, for directory listing
			local files = {}
			instanceTable.files = files
			do 
				local eocd = ''
				local eocdFound = false
				local currentPosition = archiveSize
				while(currentPosition > 0) do
					local seeked = math.min(
						currentPosition,
						22
					)
					currentPosition = currentPosition - seeked
					archive:seek('set', currentPosition)
					
					local chunk = archive:read(seeked)
					eocd = chunk .. eocd
					
					chunk = nil
					
					local eocdMagicNumberPos = string.find(eocd, EOCD_MAGIC_NUMBER)
					
					if(eocdMagicNumberPos) then 
						eocdFound = true
						eocd = eocd:sub(eocdMagicNumberPos)
						break
					end
				end
				
				currentPosition = nil
				if(eocdFound) then
					eocdFound = nil

					local diskNumber = bytesToNumber(eocd, 2, 4, false)
					instanceTable.diskNumber = diskNumber
					do
						local commentLength = bytesToNumber(eocd, 2, 20, false)
						if(commentLength ~= 0) then 
							instanceTable.comment = eocd:sub(21)
						end
					end
					--local cdStartDisk = bytesToNumber(eocd, 2, 6, false)
					--local cdRecordsOnDisk = bytesToNumber(eocd, 2, 8, false)
					--local totalCdRecords = bytesToNumber(eocd, 2, 10, false)
					local cdSize = bytesToNumber(eocd, 4, 12, false)
					local cdStart = bytesToNumber(eocd, 4, 16, false)
					
					--done with the eocd
					eocd = nil
					
					--files...
					archive:seek('set', cdStart)
					cdStart = nil
					local centralDirectory = archive:read(cdSize)
					cdSize = nil
					do 
						local lastPosition = 0
						while(lastPosition < #centralDirectory) do 
							local success, header, size = pcall(parseHeader, centralDirectory, lastPosition)
							if(success) then
								if(
									(header.fileDiskNumber == diskNumber) and
									(header.compressionMethod == 0)
								) then 
									files[header.fileName] = header
									
									header.isLocalHeader = nil
									header.fileDiskNumber = nil
								end
							else
								archive:close()
								return nil, 'Broken archive - invalid entry in EOCD'
							end
							--otherwise ignore the file	
							lastPosition = lastPosition + size
						end
					end
					
					centralDirectory = nil
					
					--ok all done, return an instance
					return instanceTable
				else
					archive:close()
					return nil, 'Broken archive - no EOCD'
				end
			end
		else
			archive:close()
			return nil, 'Not valid archive.'
		end
	else
		--archive:close() --it was already broken to begin with
		return nil, err
	end
end

return interface