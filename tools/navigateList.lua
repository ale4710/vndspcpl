return function(current, move, total, snapToEdge)
	current = current + move
	
	if(
		(current > total) or
		(current < 1)
	) then 
		if(move > 0) then
			if(snapToEdge) then
				return 1
			else
				return current - total
			end
		else
			if(snapToEdge) then
				return total
			else
				return current + total
			end
		end
	end
	
	return current
end