package states;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;

import openfl.Assets;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.MainMenuState;
import substates.OutdatedSubState;

typedef TitleData = {
	var title_x:Float;
	var title_y:Float;
	var start_x:Float;
	var start_y:Float;
	var gf_x:Float;
	var gf_y:Float;
	var gf_name:String;
	var bg_sprite:String;
	var bpm:Float;
}

typedef CharacterData = {
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	final easterEggKeys:Array<String> = [
		'SHADOW', 'RIVEREN', 'BBPANZU', 'PESSY'
	];
	final allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("On the Title Screen", null);
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		Paths.music('freakyMenu');

		if(FlxG.save.data.flashing == null)
		{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new FlashingState());
		}
		else startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:Character;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		persistentUpdate = true;

		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		loadJsonData();
		#if TITLE_SCREEN_EASTER_EGG easterEggData(); #end
		Conductor.bpm = musicBPM;

		logoBl = new FlxSprite(logoPosition.x, logoPosition.y);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new Character(gfPosition.x, gfPosition.y, characterName, false, 'images');
		gfDance.x += gfDance.positionArray[0];
		gfDance.y += gfDance.positionArray[1];

		if(ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			gfDance.shader = logoBl.shader = swagShader.shader;
		}

		var animFrames:Array<FlxFrame> = [];
		titleText = new FlxSprite(enterPosition.x, enterPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (newTitle = animFrames.length > 0)
		{
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		add(gfDance);
		add(logoBl); //FNF Logo
		add(titleText); //"Press Enter to Begin" text
		add(credGroup);
		add(ngSpr);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	// JSON data
	var characterName:String = 'gfDanceTitle';
	var musicBPM:Float = 102;

	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);

	function loadJsonData()
	{
		if(Paths.fileExists('images/titleData.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('images/titleData.json');
			if(titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					var titleJSON:TitleData = tjson.TJSON.parse(titleRaw);
					gfPosition.set(titleJSON.gf_x, titleJSON.gf_y);
					logoPosition.set(titleJSON.title_x, titleJSON.title_y);
					enterPosition.set(titleJSON.start_x, titleJSON.start_y);
					musicBPM = titleJSON.bpm;

					if(titleJSON.gf_name != null && titleJSON.gf_name.trim().length > 0)
						characterName = titleJSON.gf_name.trim();

					if(titleJSON.bg_sprite != null && titleJSON.bg_sprite.trim().length > 0)
					{
						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(titleJSON.bg_sprite));
						if(titleJSON.bg_sprite.endsWith('-pixel')) bg.antialiasing = false;
						add(bg);
					}
				}
				catch(e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else trace('[WARN] No Title JSON detected, using default values.');
		}
		//else trace('[WARN] No Title JSON detected, using default values.');
	}

	function easterEggData()
	{
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		switch(easterEgg.toUpperCase())
		{
			case 'SHADOW':
				characterName = 'ShadowBump';
				animationName = 'Shadow Title Bump';
				gfPosition.x += 210;
				gfPosition.y += 40;
			case 'RIVEREN':
				characterName = 'ZRiverBump';
				animationName = 'River Title Bump';
				gfPosition.x += 180;
				gfPosition.y += 40;
			case 'BBPANZU':
				characterName = 'BBBump';
				animationName = 'BB Title Bump';
				danceLeftFrames = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
				danceRightFrames = [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
				gfPosition.x += 45;
				gfPosition.y += 100;
			case 'PESSY':
				characterName = 'PessyBump';
				animationName = 'Pessy Title Bump';
				gfPosition.x += 165;
				gfPosition.y += 60;
				danceLeftFrames = [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
				danceRightFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28];
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	private static var showOutdatedWarning:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle)
		{
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1) timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if(pressedEnter)
			{
				#if CHECK_FOR_UPDATES
				if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && OutdatedSubState.updateVersion != MainMenuState.psychEngineVersion)
				{
					persistentUpdate = showOutdatedWarning = false;
					openSubState(new OutdatedSubState());
				}
				else
				#end
				{
					titleText.color = FlxColor.WHITE;
					titleText.alpha = 1;
					
					if(titleText != null) titleText.animation.play('press');
	
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	
					transitioning = true;
	
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.switchState(() -> new MainMenuState());
						closedState = true;
					});
				}
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('secret'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
							black.scale.set(FlxG.width, FlxG.height);
							black.updateHitbox();
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {
								onComplete: function(twn:FlxTween)
								{
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									FlxG.switchState(() -> new TitleState());
								}
							});

							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
								FreeplayState.vocals.fadeOut();

							closedState = transitioning = playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) logoBl.animation.play('bump', true);
		if(gfDance != null && curBeat % gfDance.danceEveryNumBeats == 0) gfDance.dance();

		if(!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				#if PSYCH_WATERMARKS
				case 2:
					createCoolText(['Psych Engine by'], 40);
				case 4:
					addMoreText('Shadow Mario', 40);
					addMoreText('Riveren', 40);
				#else
				case 2:
					createCoolText(['The', 'Funkin Crew Inc.']);
				case 4:
					addMoreText('presents');
				#end
				case 5:
					deleteCoolText();
				#if PSYCH_WATERMARKS
				case 6:
					createCoolText(['Not associated', 'with'], -40);
				#else
				case 6:
					createCoolText(['In association', 'with'], -40);
				#end
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('Friday');
				case 15:
					#if !PSYCH_WATERMARKS
					if(curWacky[0] == "trending") addMoreText('Nigth');
					else #end addMoreText('Night');
				case 16:
					addMoreText("Funkin'");
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (skippedIntro) return;

		#if TITLE_SCREEN_EASTER_EGG
		if (playJingle) //Ignore deez
		{
			playJingle = false;
			var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
			if (easteregg == null) easteregg = '';
			easteregg = easteregg.toUpperCase();

			var sound:FlxSound = null;
			switch(easteregg)
			{
				case 'RIVEREN':
					sound = FlxG.sound.play(Paths.sound('JingleRiver'));
				case 'SHADOW':
					FlxG.sound.play(Paths.sound('JingleShadow'));
				case 'BBPANZU':
					sound = FlxG.sound.play(Paths.sound('JingleBB'));
				case 'PESSY':
					sound = FlxG.sound.play(Paths.sound('JinglePessy'));

				default: //Go back to normal ugly ass boring GF
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 2);
					skippedIntro = true;

					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					return;
			}

			transitioning = true;
			if(easteregg == 'SHADOW')
			{
				new FlxTimer().start(3.2, function(tmr:FlxTimer)
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.6);
					transitioning = false;
				});
			}
			else
			{
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 3);
				sound.onComplete = function()
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					transitioning = false;
					#if ACHIEVEMENTS_ALLOWED
					if(easteregg == 'PESSY') Achievements.unlock('pessy_easter_egg');
					#end
				};
			}
		}
		else #end //Default! Edit this one!!
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);

			var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
			if (easteregg == null) easteregg = '';
			easteregg = easteregg.toUpperCase();
			#if TITLE_SCREEN_EASTER_EGG
			if(easteregg == 'SHADOW')
			{
				FlxG.sound.music.fadeOut();
				if(FreeplayState.vocals != null)
					FreeplayState.vocals.fadeOut();
			}
			#end
		}
		skippedIntro = true;
	}
}