package backend;

import openfl.display.Bitmap;
import flixel.system.ui.FlxSoundTray;

/*#if HSCRIPT_ALLOWED
import scripting.HScript;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end*/

class CustomSoundTray extends FlxSoundTray
{
	public var volumeMaxSound:String = 'flixel/sounds/beep';

	var graphicScale:Float = 0.3;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	/*#if HSCRIPT_ALLOWED
	var hscript:HScript;
	#end*/

	public function new()
	{
		super();

		removeChildren();
		_bars = [];

		/*#if HSCRIPT_ALLOWED
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.trim().length > 0)
		{
			var scriptPath:String = 'mods/${Mods.currentModDirectory}/data/SoundTray.hx'; //mods/My-Mod/data/SoundTray.hx
			if(!FileSystem.exists(scriptPath)) scriptPath = 'mods/data/SoundTray.hx';
			if(FileSystem.exists(scriptPath))
			{
				try
				{
					hscript = new HScript(null, scriptPath);
					hscript.set('volumeUpSound', volumeUpSound);
					hscript.set('volumeDownSound', volumeDownSound);
					hscript.set('volumeMaxSound', volumeMaxSound);

					hscript.set('x', x);
					hscript.set('y', y);
					hscript.set('bars', _bars);
					hscript.set('timer', _timer);
					hscript.set('silent', silent);
					hscript.set('active', active);
					hscript.set('visible', visible);

					hscript.set('coolLerp', function(base:Float, target:Float, ratio:Float) {
						return coolLerp(base, target, ratio);
					});
					hscript.set('screenCenter', function() screenCenter(););
	
					if(hscript.exists('onCreate'))
					{
						hscript.call('onCreate');
						trace('initialized hscript interp successfully: $scriptPath');
						return;
					}
					else
					{
						trace('"$scriptPath" contains no \"onCreate" function, stopping script.');
					}
				}
				catch(e:IrisError)
				{
					var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
					Iris.error(Printer.errorToString(e, false), pos);
					var hscript:HScript = cast (Iris.instances.get(scriptPath), HScript);
				}
				if(hscript != null) hscript.destroy();
				hscript = null;
			}
		}
		#end*/

		var bg:Bitmap = new Bitmap(Paths.bitmap('soundtray/volumebox'));
		bg.scaleX = bg.scaleY = graphicScale;
		bg.smoothing = ClientPrefs.data.antialiasing;
		addChild(bg);

		var backingBar:Bitmap = new Bitmap(Paths.bitmap("soundtray/bars_10"));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = backingBar.scaleY = graphicScale;
		backingBar.smoothing = ClientPrefs.data.antialiasing;
		addChild(backingBar);
		backingBar.alpha = 0.4;

		for (i in 1...11)
		{
			var bar:Bitmap = new Bitmap(Paths.bitmap("soundtray/bars_" + i));
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = bar.scaleY = graphicScale;
			bar.smoothing = ClientPrefs.data.antialiasing;
			addChild(bar);
			_bars.push(bar);
		}

		y = -height;
		screenCenter();
		visible = false;

		volumeUpSound = 'soundtray/up';
		volumeDownSound = 'soundtray/down';
		volumeMaxSound = 'soundtray/max';

		for(snd in [volumeUpSound, volumeDownSound, volumeMaxSound])
		{
			Paths.excludeAsset(snd);
			Paths.sound(snd);
		}
	}

	override public function update(MS:Float):Void
	{
		/*#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onUpdate')) hscript.call('onUpdate', [MS]);
			return;
		}
		#end*/

		y = coolLerp(y, lerpYPos, 0.1);
		alpha = coolLerp(alpha, alphaTarget, 0.25);

		if (_timer > 0)
		{
			if (FlxG.sound.muted == false && FlxG.sound.volume > 0) _timer -= (MS / 1000);
			alphaTarget = 1;
		}
		else if (y >= -height)
		{
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}

		if (y <= -height) visible = active = false;
	}

	override public function show(up:Bool = false):Void
	{
		/*#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onShow')) hscript.call('onShow', [up]);
			return;
		}
		#end*/

		_timer = 2;
		lerpYPos = 10;
		visible = active = true;

		var globalVolume = Math.round(FlxG.sound.volume * 10);
		if (FlxG.sound.muted || FlxG.sound.volume == 0) globalVolume = 0;

		if (!silent)
		{
			var sound:String = up ? volumeUpSound : volumeDownSound;
			if (globalVolume == 10) sound = volumeMaxSound;

			FlxG.sound.play(Paths.sound('$sound'));
		}


		for (i => bar in _bars)
		{
			bar.visible = (i < globalVolume);
		}
	}

	public function coolLerp(base:Float, target:Float, ratio:Float):Float
	{
		return base + (ratio  * (FlxG.elapsed / (1 / 60))) * (target - base);
	}
}