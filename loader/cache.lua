local interface = {}

local cache = {}
local cacheAccessOrder = {}

local ignoreCache = {}
function interface.setIgnore(ignore)
	ignoreCache = {}
	for _, value in pairs(ignore) do 
		ignoreCache[value] = true
	end
end

local function checkObjectCacheAble(data)
	local datat = type(data)
	return (
		datat ~= 'boolean' and
		datat ~= 'nil'
	)
end

function interface.reset()
	for _, space in pairs(cache) do 
		for key, object in pairs(space) do 
			space[key] = nil
			if(type(object) ~= 'boolean') then 
				if(object.release) then
					object:release()
				end
			end
		end
	end
end

function interface.get(which, path) 
	local entry = cache[which] and cache[which][path]
	if(entry) then
		if(checkObjectCacheAble(entry)) then 
			for index, accessMdata in pairs(cacheAccessOrder) do 
				if(
					accessMdata.which == which and
					accessMdata.path == path
				) then 
				table.insert(cacheAccessOrder,
					table.remove(cacheAccessOrder, index)
				)
				end
			end
		end
	
		return entry
	end
end

function interface.set(which, path, data)
	if(not ignoreCache[which]) then 
		local whichTable = cache[which] or {}
		whichTable[path] = data
		
		
		if(checkObjectCacheAble(data)) then
			table.insert(
				cacheAccessOrder,
				{
					which = which,
					path = path
				}
			)
			
			print('[loader/cache] add "' .. path .. '" to "' .. which .. '"')
		end

		while(#cacheAccessOrder > userSettings.maxCacheEntries) do
			local oldest = table.remove(cacheAccessOrder, 1)
			print('[loader/cache] removed "' .. oldest.path .. '" from "' .. oldest.which .. '"')
			local entry = cache[oldest.which][oldest.path]
			cache[oldest.which][oldest.path] = nil
			-- if(entry and entry.release) then
				-- entry:release()
			-- end
		end
		
		cache[which] = whichTable
	end
end

return interface