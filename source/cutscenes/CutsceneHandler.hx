package cutscenes;

import flixel.FlxBasic;
import flixel.util.FlxSort;
import flixel.addons.display.FlxPieDial;

// import substates.CutscenePauseSubstate;

typedef CutsceneEvent = {
	var time:Float;
	var func:Void->Void;
}

class CutsceneHandler extends FlxBasic
{
	public var onStart:Void->Void = null;
	public var finishCallback:Void->Void = null;
	public var skipCallback:Void->Void = null;
	public var overallFinish:Void->Void = null;

	public var endTime:Float = 0;
	public var music:String = null;

	public var objects:Array<FlxSprite> = [];
	public var timedEvents:Array<CutsceneEvent> = [];

	public var canSkip(default, set):Bool = false;
	public var canPause:Bool = false;
	public var canExit:Bool = false;

	final _timeToSkip:Float = 1;
	public var holdingTime:Float = 0;

	public var skipSprite:FlxPieDial;

	public var skippedCutscene:Bool = false;
	var alreadyDestroyed:Bool = false;

	public function new(canSkip:Bool = true)
	{
		super();

		timer(0, function()
		{
			if(music != null)
			{
				FlxG.sound.playMusic(Paths.music(music), 0, false);
				FlxG.sound.music.fadeIn();
			}
			if(onStart != null) onStart();
		});
		FlxG.state.add(this);

		this.canSkip = canSkip;
	}

	override function destroy()
	{
		if(alreadyDestroyed) return;

		if(skipSprite != null)
		{
			PlayState.instance.remove(skipSprite);
			skipSprite.destroy();
		}

		if(skippedCutscene)
		{
			if(skipCallback != null) skipCallback();
			finishCallback = null;
		}
		else
		{
			if(finishCallback != null) finishCallback();
			skipCallback = null;
		}

		if(overallFinish != null) overallFinish();

		trace('Cutscene Destroyed');

		for (spr in objects)
		{
			spr.kill();
			PlayState.instance.remove(spr);
			spr.destroy();
		}
		PlayState.instance.remove(this);

		super.destroy();

		alreadyDestroyed = true;
	}

	private var cutsceneTime:Float = 0;
	private var firstFrame:Bool = false;
	override function update(elapsed)
	{
		super.update(elapsed);

		if(FlxG.state != PlayState.instance || !firstFrame)
		{
			firstFrame = true;
			return;
		}

		cutsceneTime += elapsed;
		while(timedEvents.length > 0 && timedEvents[0].time <= cutsceneTime)
		{
			timedEvents[0].func();
			timedEvents.shift();
		}
		
		if((canSkip || canPause) && cutsceneTime > 0.1)
		{
			if(Controls.instance.pressed('accept')) holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			else if (holdingTime > 0) holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));

			if(canSkip) updateSkipAlpha();

			/*if(canPause)
			{
				if(Controls.instance.justReleased('accept') && holdingTime < _timeToSkip)
				{
					PlayState.instance.paused = true;
					PlayState.instance.openSubState(new CutscenePauseSubstate(this));
				}
			}*/
		}

		if(endTime <= cutsceneTime || holdingTime >= _timeToSkip)
		{
			if(holdingTime >= _timeToSkip)
			{
				trace('Skipped Cutscene');
				skippedCutscene = true;
			}
			destroy();
		}
	}

	function set_canSkip(newValue:Bool)
	{
		canSkip = newValue;
		if(canSkip)
		{
			if(skipSprite == null)
			{
				skipSprite = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 40, true, 24);
				skipSprite.replaceColor(FlxColor.BLACK, FlxColor.TRANSPARENT);
				skipSprite.x = FlxG.width - (skipSprite.width + 80);
				skipSprite.y = FlxG.height - (skipSprite.height + 72);
				skipSprite.amount = 0;
				skipSprite.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				PlayState.instance.add(skipSprite);
			}
		}
		else if(skipSprite != null)
		{
			PlayState.instance.remove(skipSprite);
			skipSprite.destroy();
			skipSprite = null;
		}
		return canSkip;
	}

	function updateSkipAlpha()
	{
		if(skipSprite == null) return;

		skipSprite.amount = Math.min(1, Math.max(0, (holdingTime / _timeToSkip) * 1.025));
		skipSprite.alpha = FlxMath.remapToRange(skipSprite.amount, 0.025, 1, 0, 1);
	}

	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push({time: time, func: func});
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:CutsceneEvent, Obj2:CutsceneEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}
}