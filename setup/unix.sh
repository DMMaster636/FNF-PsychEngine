#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.1.2
haxelib install openfl 9.3.3
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-tools
haxelib install hscript-iris
haxelib install tjson
haxelib install hxdiscord_rpc
haxelib install hxvlc --skip-dependencies
haxelib install hxWindowColorMode
haxelib install flxsvg
haxelib set lime 8.1.2
haxelib set openfl 9.3.3
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate.git v4.0.0
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git master
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis.git main
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git main
echo Finished!