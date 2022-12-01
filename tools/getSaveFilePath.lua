return function(slot)
	if(type(slot) == 'number') then 
		slot = 'save' .. string.format('%02d', slot)
	end
	return gamepath .. '/save/' .. slot .. '.sav'
end