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

--[[ support ]]--

normal vnds files are (should be) fully supported.
however, some file formats for resources aren't supported. most notably, .aac files aren't supported.

the img.ini file is supported.

the info.txt file is supported.

icon.png and thumbnail.png are supported, but icon-high.png and thumbnail-high.png are NOT supported. *.jpg (for these) is not supported.

individual zip files containing the resources (background.zip, script.zip, etc.) are supported. however, like vnds on ds, it must be using STORE mode.

there is partial support for the vnds2 spec. honestly it's practically useless. see the vnds2-support.txt file for details.
