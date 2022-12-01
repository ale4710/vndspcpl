local mn = ...

function requireppName(base, addrq)
	return base .. '.' .. addrq
end
function requirepp(base, addrq) 
	return require(requireppName(base ,addrq)) 
end

string.split = requirepp(mn, 'stringSplit')
string.fixEncoding = requirepp(mn, 'stringEncodingFix')
io.qread = requirepp(mn, 'fileGet')
math.clamp = requirepp(mn, 'numberClamp')
math.between = requirepp(mn, 'numberInBetween')
getUniqueId = requirepp(mn, 'uniqueId')
colora = requirepp(mn, 'colorWithAlpha')
table.shallowCopy = requirepp(mn, 'tableShallowCopy')
table.invert = requirepp(mn, 'tableInvert')
aspectRatioScaler = requirepp(mn, 'boxFitter')
xml = requirepp(mn, 'xml')
navigateList = requirepp(mn, 'navigateList')
getSaveFilePath = requirepp(mn, 'getSaveFilePath')
drawScreenCenteredText = requirepp(mn, 'drawScreenCenteredText')
durationConverter = requirepp(mn, 'durationConverter')
newTempFile = requirepp(mn, 'tempFileHandler')

if(not isThread) then 
	eventTarget = requirepp(mn, 'eventTarget')
	taskCounter = requirepp(mn, 'taskCounter')
	scrollingListDisplayManagerClass = requirepp(mn, 'scrollingListDisplayManagerClass')
	callbackHelper = requirepp(mn, 'callbackHelper')
	navigatorClass = requirepp(mn, 'navigatorClass')
	messageBoxWS = requirepp(mn, 'messageBoxWithSound')
end

mn = nil