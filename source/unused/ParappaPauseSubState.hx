package;

import flixel.graphics.frames.FlxAtlasFrames;

class ParappaPauseSubState extends MusicBeatState
{
	var continueButton:FlxSprite;
	var exitButton:FlxSprite;

	var continueSelect:Bool = false;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		add(bg);

		continueButton = new FlxSprite(0, FlxG.height * 0.7);
		continueButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI_continue');
		continueButton.animation.addByPrefix('selected', 'continue_game_br', 0, false);
		continueButton.animation.appendByPrefix('selected', 'continue_game_d');
		continueButton.animation.play('selected');
		add(continueButton);
		continueButton.screenCenter(XY);

		exitButton = new FlxSprite(continueButton.x + 250, continueButton.y + 250);
		exitButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI_exit');
		exitButton.animation.addByPrefix('selected', 'exit_br', 0, false);
		exitButton.animation.appendByPrefix('selected', 'exit_d');
		exitButton.animation.play('selected');
		add(exitButton);

		changeThing();

		super.create();
	}

	var cpuControlled:Bool = ClientPrefs.getGameplaySetting('botplay', false);
	var practiceMode:Bool = ClientPrefs.getGameplaySetting('practice', false);

	override function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			changeThing();

		if (controls.ACCEPT)
		{
			if (continueSelect)
			{
				MusicBeatState.switchState(new PlayState());
			}
			else
			{
				practiceMode = false;
				cpuControlled = false;
				PlayState.changedDifficulty = false;
				PlayState.seenCutscene = false;
				PlayState.deathCounter = 0;
				MusicBeatState.switchState(new states.MainMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		continueSelect = !continueSelect;

		if (continueSelect)
		{
			exitButton.animation.curAnim.curFrame = 1;
			continueButton.animation.curAnim.curFrame = 0;
		}
		else
		{
			exitButton.animation.curAnim.curFrame = 0;
			continueButton.animation.curAnim.curFrame = 1;
		}
	}
}
