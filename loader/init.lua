local mn = ...
local interface = {}

local cache = requirepp(mn, 'cache')
cache.setIgnore({'video'})

local processFile = requirepp(mn, 'fileProcessor')(cache, mn)

local function formPath(which, path)
	return which .. '/' .. path
end
local function formPathWG(...)
	return gamepath .. '/' .. formPath(...)
end

--archives
local archives = {}
local function resetArchives()
	for key in pairs(archives) do 
		archives[key]:kill()
		archives[key] = nil
	end
end
local function loadArchives()
	local pending = {}
	for _, filename in pairs(FOLDER_FILE_NAMES) do 
		table.insert(pending,
			getZipFileHandler(
				gamepath .. '/' .. filename .. '.zip'
			):and_then(function(zipInstance)
				archives[filename] = zipInstance
			end)
		)
	end
	return Promise(pending):all_settled()
end

function interface.reset()
	resetArchives()
	cache.reset()
end

function interface.initialize()
	interface.reset()

	local pending = {}

	table.insert(pending, loadArchives())
	
	return Promise(pending):all_settled()
end

local function autoResponder(inputPromise, responder, which, path)
	inputPromise:and_then(function(data)
		processFile(
			data,
			which,
			path
		):and_then(function(file)
			responder:resolve(file)
		end):catch(function()
			responder:resolve(false)
		end)
	end):catch(function()
		responder:resolve(false)
	end)
end

function interface.get(which, path)
	local cached = cache.get(which, path)
	if(cached) then
		return Promise(
			((cached ~= true) and cached) or
			false
		)
	else
		print('[loader] loading "' .. path .. '" (' .. which .. ') from disk')
		return io.asqread(formPathWG(which, path)):catch(function(err)
			if(archives[which]) then
				print('[loader] "' .. path .. '" (' .. which .. ') not found on disk, trying from archive')
				return archives[which]:getFile(formPath(which, path))
			else
				return Promise():then_reject()
			end
		end):and_then(function(data)
			return processFile(
				data,
				which,
				path
			)
		end):catch(function()
			return Promise(false)
		end)
	end
end

return interface
