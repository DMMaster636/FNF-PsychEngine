/*
// Maybe some other time    - DM
package substates;

import cutscenes.CutsceneHandler;
import objects.VideoSprite;

class CutscenePauseSubstate extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart cutscene'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var camPause:PsychCamera;

	var cutscene:Dynamic = null;
	public function new(cutscene:Dynamic)
	{
		FlxG.state.persistentUpdate = false;
		this.cutscene = cutscene;
		super();
	}

	override function create()
	{
		camPause = new PsychCamera();
		camPause.bgColor.alpha = 0;
		FlxG.cameras.add(camPause, false);

		if(cutscene.canSkip) menuItemsOG.push('Skip cutscene');
		if(cutscene.canExit) menuItemsOG.push('Exit to menu');
		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = PauseSubState.getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [camPause];

		super.create();
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(cantUnpause <= 0)
		{
			if(controls.BACK)
			{
				cantUnpause = 0.1;
				close();
				return;
			}
		}

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		if (controls.justReleased('accept') && (cantUnpause <= 0 || !controls.controllerMode))
		{
			if(Std.isOfType(cutscene, CutsceneHandler)) selectCutsceneOption();
			else if(Std.isOfType(cutscene, VideoSprite)) selectVideoOption();
			close();
		}
	}

	function selectVideoOption():Void
	{
		switch (menuItems[curSelected])
		{
			case "Resume":
				cutscene.resume();
			case "Restart cutscene":
				cutscene.videoSprite.bitmap.time = 0;
				cutscene.resume();
			case "Skip cutscene":
				trace('Skipped Video');
				cutscene.skippedVideo = true;
				cutscene.videoSprite.bitmap.onEndReached.dispatch();
			case "Exit to menu":
				cutscene.canPause = false;
				cutscene.overallFinish = cutscene.finishCallback = cutscene.onSkip = null;
				PauseSubState.exitSong();
		}
	}

	function selectCutsceneOption():Void
	{
		switch (menuItems[curSelected])
		{
			case "Resume":
				close();
			case "Restart cutscene":
				PauseSubState.restartSong(true);
			case "Skip cutscene":
				trace('Skipped Cutscene');
				cutscene.skippedCutscene = true;
				cutscene.destroy();
			case "Exit to menu":
				cutscene.canPause = false;
				cutscene.overallFinish = cutscene.finishCallback = cutscene.skipCallback = null;
				PauseSubState.exitSong();
		}
	}

	override function destroy()
	{
		FlxG.state.persistentUpdate = true;
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for(num => item in grpMenuShit.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if(item.targetY == 0) item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void
	{
		for (obj in grpMenuShit)
		{
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (num => str in menuItems)
		{
			var item = new Alphabet(90, 320, Language.getPhrase('pause_$str', str), true);
			item.isMenuItem = true;
			item.targetY = num;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}*/