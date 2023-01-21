return function(tbl)
	local ntbl = {}
	for key, value in pairs(tbl) do
		ntbl[key] = value
	end
	
	return ntbl
end