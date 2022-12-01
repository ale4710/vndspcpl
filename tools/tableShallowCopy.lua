return function(tbl, existingTable)
	local newTable = (
		((type(existingTable) == 'table') and existingTable) or 
		{}
	)
	for key, entry in pairs(tbl) do
		newTable[key] = entry
	end
	return newTable
end