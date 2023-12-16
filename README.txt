vnds pc player
(working title)

created by ale4710
project website: https://alego.web.fc2.com/vnds/vndspcpl/
gitlab: https://gitlab.com/ale4710/vndspcpl
github: https://github.com/ale4710/vndspcpl

see the credits file for credits.

demo video: https://youtu.be/Vr1maacJiJE

--[[ how to start (if you dont know already) ]]--

on windows and linux...
there is a convinient script i made for you.
install love2d if not already.
	on windows... first place a copy of love2d into a new folder called "love".
	on linux... install love2d from your favorite package manager.
after that, start the appropriate script.
	on windows... execute start.bat
	on linux... execute start.sh
after that, drop a directory containing the novel you wish to read.
on windows, you can also drop the directory onto start.bat.

on mac...
it might be a bit complicated. you need to get love2d from the website, and launch the game.
please visit the love2d website for details.

on android or ios...
basically, it is untested.
they are most likely not supported, due to how these operating systems deal with accessing the filesystem.
at the moment i am blocking mobile from running this program.

--[[ controls ]]--

(Escape): Open Menu
(Arrow Keys): Navigate Menus
(Enter): Confirm Choice, or Progress Story
(Space): Progress Story
(Ctrl): Skip

--[[ options ]]--

usage is generally:
start.sh [options] [path to novel]

there are options you can pass on to the program.
you can save whatever options you want into the start scripts.

the options are...

	--window-title-additional "[text]"
it will change the additional text in the window title.
for example, the window title is normally "Snow Sakura [VNDS PC Player]"
but if you pass the option 
	--window-title-additional " (vnds)"
then the window title will become "Snow Sakura (vnds)"
note that a space will NOT be added automatically.

	--allow-multiple-sound-effects
if you pass this option, it will allow multiple sound effects to played at a time.
looping sound effects will stop on the next sound effect.

	--indicate-infinite-sound-effects
there is a progress bar for sound effects, however nothing is shown for infinite sound effects.
if you pass this option, it will show an indicator for infinite sound effects.

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

	--textbox-background-opacity [opacity]
it will set the opacity of the textbox, where [opacity] is a number from 0 to 100.
100 means fully black, and 0 means there is no background.
[opacity] should be an integer.

	--text-box-minimum-lines [lines]
it will set the minimum number of lines to show in the textbox. essentially, empty space.
the textbox will expand to how many lines are required.
lines must be an integer >= 1.

	--text-progression-speed [seconds]
it will set how fast text will be displayed.
the number will be interpreted as "1 character every n seconds"
so if you set [seconds] to 1, then it will display 1 character every 1 second.
conversely, if you set [seconds] to 0.02, it will display 1 character every 0.02 seconds, which works out to 50 character every second.

	--show-textbox-when-empty
it will allow showing the textbox, even when there is no text in the textbox.

	--ignore-novel-font
it will not use the font given by the novel.

	--disallow-skipping-transitions
	--disallow-skipping-delays
it will not allow you to skip transitions or delays.

	--dont-center-backgrounds
backgrounds are centered by default, but if you prefer them to be aligned at the top left corner, pass this option.

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

	--disable-hold-to-confirm-save-file-action
by default, actions that will modify a save file in the save file manager will require you to hold the button to confirm your choice.
if you do not want this, pass this option.

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

there is partial support for the vnds2 spec. honestly it's practically useless. see the vnds2-support.txt file for details.
