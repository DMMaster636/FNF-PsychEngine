package backend;

import flixel.util.FlxGradient;

#if HSCRIPT_ALLOWED
import scripting.HScript;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;
	var camTrans:PsychCamera; // so proud of her

	var finished:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	#if HSCRIPT_ALLOWED
	var hscript:HScript;
	#end

	var duration:Float = 0.5;
	var isTransIn:Bool = false;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		camTrans = new PsychCamera();
		camTrans.bgColor.alpha = 0;
		FlxG.cameras.add(camTrans, false);

		cameras = [camTrans];

		#if HSCRIPT_ALLOWED
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.trim().length > 0)
		{
			var scriptPath:String = 'mods/${Mods.currentModDirectory}/data/Transition.hx'; //mods/My-Mod/data/Transition.hx
			if(!FileSystem.exists(scriptPath)) scriptPath = 'mods/data/Transition.hx';
			if(FileSystem.exists(scriptPath))
			{
				try
				{
					hscript = new HScript(null, scriptPath);
					hscript.set('finished', finished);
					hscript.set('duration', duration);
					hscript.set('isTransIn', isTransIn);
	
					if(hscript.exists('onCreate'))
					{
						hscript.call('onCreate');
						trace('initialized hscript interp successfully: $scriptPath');
						return super.create();
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
		#end

		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		if(!isTransIn) transGradient.y = -transGradient.height;
		else transGradient.y = transBlack.y - transBlack.height;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(finished) close();

		#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onUpdate')) hscript.call('onUpdate', [elapsed]);
			return;
		}
		#end

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);

		if(duration > 0) transGradient.y += (height + targetPos) * elapsed / duration;
		else transGradient.y = (targetPos) * elapsed;

		if(isTransIn) transBlack.y = transGradient.y + transGradient.height;
		else transBlack.y = transGradient.y - transBlack.height;

		if(transGradient.y >= targetPos) finished = true;
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}