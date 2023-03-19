local mn = ...
local ws = {}
for _, w in pairs({
	'saveLoad',
	'settings'
}) do
	ws[w] = requirepp(mn, w)
end
mn = nil
return ws