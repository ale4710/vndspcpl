local comps = {
	[true] = (function(n1, n2, n)
		return (
			(n1 >= n) and
			(n2 <= n)
		) or (
			(n1 <= n) and
			(n2 >= n)
		)
	end),
	
	[false] = (function(n1, n2, n)
		return (
			(n1 > n) and
			(n2 < n)
		) or (
			(n1 < n) and
			(n2 > n)
		)
	end)
}

return function(n1, n2, number, allowEqual)
	return comps[allowEqual == false](n1, n2, number)
end