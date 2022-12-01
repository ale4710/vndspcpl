return function(str, delimiter, plainDelimiter, limit)
	--limit is... how many times should we "cut" the string?
	--e.g. limit = 1
	--     delimiter = ','
	--  '1,2,3,4,5'
	--  becomes
	--  '1'
	--  '2,3,4,5'
    local result = {}
	if(type(limit) ~= 'number') then 
		limit = nil
	end
	
	local last = 1
	while true do 
		local ss, se, fstr = string.find(str, delimiter, last, plainDelimiter)
		
		if(ss) then
		
			if(last ~= ss) then
				table.insert(
					result,
					str:sub(last, ss - 1)
				)
			end
			last = se + 1
			
			if(#result == limit) then 
				table.insert(
					result,
					str:sub(se + 1)
				)
				break 
			end
		else
			local fstr = str:sub(last)
			if(#fstr ~= 0) then 
				table.insert(
					result,
					fstr
				)
			end 
			break
		end
	end
	
    return result
end