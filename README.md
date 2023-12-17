# vndspcpl

a vnds interpreter for desktop.

created by ale4710

[project website](https://alego.web.fc2.com/vnds/vndspcpl/) / [gitlab](https://gitlab.com/ale4710/vndspcpl) / [github](https://github.com/ale4710/vndspcpl)

## how to start

### packaged version

download the program at the project website above.

it is available under the *files* section.

read the readme in the zip file.

### unpackaged version

simply clone/download this repository.

then, take a copy of love2d and put it into a new folder called `love`.

finally, execute `start.bat` if you're on windows, or `start.sh` if you're on linux.

on windows, you can also drop a directory onto `start.bat`.

**important: the scripts only work in the unpackaged version!**

## misc

### controls

* `Escape` - open menu
* `Arrow Keys` - navigate menus
* `Enter` - confirm choice or progress story
* `Space` - progress story
* `Ctrl` - skip

### advanced options

there are options that you can pass onto the program.

see `options.txt` to see what options are available.

## vnds support

### vnds (generally)

normal vnds novels are fully supported (i hope)

however, some file format are not supported, really because love doesn't support them. most notably, `aac` files are not supported.

zip files containing the resources, such as `background.zip`, `script.zip`, and so on, are supported. however, like vnds on nds, the files must not actually be compressed (using `STORE` mode).

### extentions

the `img.ini` file is supported. any resolution can be used, but know that the coordinate system will be stretched/squashed depending on the aspect ratio.

`icon.png` is supported, and will be used as the window's icon.

`thumbnail.png` is supported, and is only used on the first loading screen, and then never again.

`icon-high.png` and `thumbnail-high.png` are **not** supported.

`*.jpg` is **not** supported.

### vnds2

there is partial support for the vnds2 spec. honestly it's practically useless, and i have given up on fully implementing it. see the `vnds2-support.txt` file for details.