local takenNames = {}

return function()
	local ntr
	while(
		takenNames[ntr] or
		(not ntr)
	) do
		ntr = math.random(999999999)
	end
	
	takenNames[ntr] = true
	return ntr
end