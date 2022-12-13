NEWLINEPTRN = '%\r?%\n'
STRING_PATTERN = '"([^"]*)"'

VN_SCREEN = {
	w = 256,
	h = 192
}

FRAME_LENGTH = 1 / 60
DEFAULT_FADE_LENGTH = 16

MAIN_SCR_FILE_NAME = 'main.scr'

FOLDER_FILE_NAMES = {
	'background',
	'foreground',
	'script',
	'sound',
	'video'
}

if(colors) then 
	VNDS_COLOR_CODES = {
		[30] = colors.gray25,
		[31] = colors.red,
		[32] = colors.green,
		[33] = colors.yellow,
		[34] = colors.blue,
		[35] = colors.magenta,
		[36] = colors.cyan,
		[37] = colors.white,
		[39] = nil --default
		--also any other number will default to default...
	}
end

if(not isThread) then 
	SCREEN = {}
	SCREEN.w, SCREEN.h = love.graphics.getDimensions()
end
