local DEFAULT_FLAG_OVERRIDE = 'r'
if(operatingSystem == 'Windows') then 
	DEFAULT_FLAG_OVERRIDE = DEFAULT_FLAG_OVERRIDE .. 'b'
end

return function(filePath, flagoverride)
	if(not flagoverride) then 
		flagoverride = DEFAULT_FLAG_OVERRIDE 
	end
	local file, errmsg, errcode = io.open(filePath, flagoverride)
	
	if(errmsg) then
		return nil, errmsg, errcode
	else
		local contents = ''
		
		while true do
			local additional = file:read('*a')
			if(additional ~= '') then
				contents = contents .. additional
			else
				break
			end
		end
		
		file:close()
		return contents
	end
end