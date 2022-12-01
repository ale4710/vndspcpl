return function(min, max, number)
	return math.min(
		max,
		math.max(
			min,
			number
		)
	)
end