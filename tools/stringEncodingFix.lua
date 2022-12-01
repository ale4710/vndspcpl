local UTF8BOM = string.char(0xef, 0xbb, 0xbf)

return function(str)
	if(str:sub(1,3) == UTF8BOM) then
		str = str:sub(4)
	end
	
	while(true) do 
		local _, brokenChar = utf8.len(str)
		if(brokenChar) then
			local before = ((brokenChar > 1) and str:sub(1, brokenChar - 1)) or ''
			local after = ((brokenChar < #str) and str:sub(brokenChar + 1)) or ''
			str = before .. after
		else
			break
		end
	end
	
	return str
end