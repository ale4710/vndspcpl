vnds pc player
(working title)

created by ale4710
https://gitlab.com/ale4710/vndspcpl

see the credits file for credits.

--[[ how to start (if you dont know already) ]]--

on windows...
there is a convinient script i made for you.
first place a copy of love into a new folder called "love".
after that, execute start.bat. 
after that, drop a directory containing the novel you wish to read.
alternatively, drop the directory onto start.bat.

on linux...
install love if not already installed.
then run love in the game directory.
make a script with your favorite shell interpreter (#!/bin/sh or whatever) if you wish.
for other ways of starting the game please go to the love2d website.

on mac...
i dont know i dont have a mac
please visit the love2d website for details.

on android or ios...
basically, it is untested.
they are most likely not supported, due to how these operating systems deal with accessing the filesystem.

--[[ options ]]--

there are options you can pass on to the program.
if you're using windows, the options can be added into start.bat. see the contents of start.bat file for an example.

!! important !!
the last options given will ALWAYS be interpreted as the novel path.

the options are...

	--window-title-additional "[text]"
it will change the additional text in the window title.
for example, the window title is normally "Snow Sakura [VNDS PC Player]"
but if you pass the option 
	--window-title-additional "(vnds)"
then the window title will become "Snow Sakura (vnds)"

	--allow-multiple-sound-effects
if you pass this option, it will allow multiple sound effects to played at a time.
looping sound effects will stop on the next sound effect.

	--disable-sounds
disables sounds, execpt message box sound.

	--base-font-size [fontsize]
it will set the base font size, before scaling.

	--text scale [scale factor]
it will set the text scaling, after base font size.

	--text-box-mode [mode]
it will set the default mode of the textbox, where [mode] is a number from 0 to 2.
0 = full screen
1 = bottom
2 = top

	--text-progression-speed [seconds]
it will set how fast text will be displayed.
the number will be like "1 character every n seconds"
so if you set [seconds] to 1, then it will display 1 character every 1 second.
conversely, if you set [seconds] to 0.02, it will display 1 character every 0.02 seconds, which works out to 50 character every second.

	--show-textbox-when-empty
it will allow showing the textbox, even when there is no text in the textbox.

	--ignore-novel-font
it will not use the font given by the novel.

	--disallow-skipping-transitions
	--disallow-skipping-delays
it will not allow you to skip transitions or delays.

	--maximum-cache-entries
it sets how many entries in the cache are allowed.
if you set this to 0 or lower, the cache is disabled, and resources are fetched from disk every time.

	--keep-mouse-visible
normally the mouse will disappear if you do not move it in the game window for some time, but passing this option will keep the mouse visible at all times.

	--hide-delay-timer
it will hide the timer on delays.
it may be helpful for immersion during cutscenes.

	--hide-loading-indicator
it will hide the loading indicator when resources are being loaded.
it is probably not helpful if your storage device is fast, so use this option to disable it.

	--hide-awaiting-user-indicator
it will hide the arrow that lets you know that you can proceed.
if you dont like the arrow, use this option to disable it.
be warned, that disabling this will make it unclear whether or not you can continue in some cases.

	--debug-overlay
it shows debug info over the screen. this is to show other info which is hard to show in the console.
currently it only shows set variables.

--[[ support ]]--

normal vnds files are (should be) fully supported.
however, some file formats for resources aren't supported. most notably, .aac files aren't supported.

the img.ini file is supported.

the info.txt file is supported.

icon.png and thumbnail.png are supported, but icon-high.png and thumbnail-high.png are NOT supported. *.jpg (for these) is not supported.

individual zip files containing the resources (background.zip, script.zip, etc.) are supported. however, like vnds on ds, it must be using STORE mode.

there is partial support for the vnds2 spec. see the vnds2-support.txt file for details.
