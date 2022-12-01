return function(r, g, b, alpha)
	if(
		type(r) == 'table'
	) then
		alpha = g
		local ea
		r, g, b, ea = unpack(r)
		if(ea) then
			alpha = ea * alpha
		end
	end
	
	return r, g, b, alpha
end