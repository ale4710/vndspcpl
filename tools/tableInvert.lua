return function(tbl)
	local ntbl = {}
	for key, value in pairs(tbl) do
		ntbl[value] = key
	end
	return ntbl
end