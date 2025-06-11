package cutscenes;

import cutscenes.DialogueBox;

typedef DialogueFile = {
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine = {
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	var boxState:Null<String>;
	var speed:Null<Float>;
	@:optional var sound:Null<String>;
}

// TO DO: Clean code? Maybe? idk
class DialogueBoxPsych extends FlxSpriteGroup
{
	public static var DEFAULT_TEXT_X = 175;
	public static var DEFAULT_TEXT_Y = 460;
	public static var LONG_TEXT_ADD = 24;
	var scrollSpeed = 4000;

	var dialogue:TypedAlphabet;
	var dialogueList:DialogueFile = null;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;
	var bgFade:FlxSprite = null;
	var box:FlxSprite;
	var textToType:String = '';

	var arrayCharacters:Array<DialogueCharacterPsych> = [];

	var currentText:Int = 0;
	var offsetPos:Float = -600;
	var skipText:FlxText;

	var textBoxTypes:Array<String> = ['normal', 'angry'];
	
	var curCharacter:String = "";
	//var charPositionList:Array<String> = ['left', 'center', 'right'];

	public function new(dialogueList:DialogueFile, ?song:String = null)
	{
		super();

		//precache sounds
		Paths.sound('dialogue');
		Paths.sound('dialogueClose');

		if(song != null && song != '')
		{
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		
		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);

		this.dialogueList = dialogueList;
		spawnCharacters();

		box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
		box.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
		box.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		box.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
		box.animation.play('normal', true);
		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		daText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		daText.setScale(0.7);
		add(daText);

		skipText = new FlxText(FlxG.width - 320, FlxG.height - 30, 300, Language.getPhrase('dialogue_skip', 'Press BACK to Skip'), 16);
		skipText.setFormat(null, 16, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
		skipText.borderSize = 2;
		add(skipText);

		startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public static var LEFT_CHAR_X:Float = -60;
	public static var RIGHT_CHAR_X:Float = -100;
	public static var DEFAULT_CHAR_Y:Float = 60;

	function spawnCharacters()
	{
		var charsMap:Map<String, Bool> = new Map<String, Bool>();
		for (dialogue in dialogueList.dialogue)
		{
			if(dialogue != null)
			{
				var charToAdd:String = dialogue.portrait;
				if(!charsMap.exists(charToAdd) || !charsMap.get(charToAdd))
					charsMap.set(charToAdd, true);
			}
		}

		for (individualChar in charsMap.keys())
		{
			var x:Float = LEFT_CHAR_X;
			var y:Float = DEFAULT_CHAR_Y;
			var char:DialogueCharacterPsych = new DialogueCharacterPsych(x + offsetPos, y, individualChar);
			char.setGraphicSize(Std.int(char.width * DialogueCharacterPsych.DEFAULT_SCALE * char.jsonFile.scale));
			char.updateHitbox();
			char.scrollFactor.set();
			char.alpha = 0.00001;
			add(char);

			var saveY:Bool = false;
			switch(char.jsonFile.dialogue_pos)
			{
				case 'center':
					char.x = FlxG.width / 2;
					char.x -= char.width / 2;
					y = char.y;
					char.y = FlxG.height + 50;
					saveY = true;
				case 'right':
					x = FlxG.width - char.width + RIGHT_CHAR_X;
					char.x = x - offsetPos;
			}
			x += char.jsonFile.position[0];
			y += char.jsonFile.position[1];
			char.x += char.jsonFile.position[0];
			char.y += char.jsonFile.position[1];
			char.startingPos = (saveY ? y : x);
			arrayCharacters.push(char);
		}
	}

	var daText:TypedAlphabet = null;
	var ignoreThisFrame:Bool = true; //First frame is reserved for loading dialogue images

	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;
	override function update(elapsed:Float)
	{
		if(ignoreThisFrame)
		{
			ignoreThisFrame = false;
			super.update(elapsed);
			return;
		}

		if(!dialogueEnded)
		{
			bgFade.alpha += 0.5 * elapsed;
			if(bgFade.alpha > 0.5) bgFade.alpha = 0.5;

			if(Controls.instance.ACCEPT || Controls.instance.BACK)
			{
				if(!daText.finishedText && !Controls.instance.BACK)
				{
					daText.finishText();
					if(skipDialogueThing != null) skipDialogueThing();
				}
				else if(Controls.instance.BACK || currentText >= dialogueList.dialogue.length)
				{
					dialogueEnded = true;
					for (boxType in textBoxTypes)
					{
						var checkArray:Array<String> = ['', 'center-'];
						var animName:String = box.animation.curAnim.name;
						for (check in checkArray)
						{
							if(animName == check + boxType || animName == check + boxType + 'Open')
								box.animation.play(check + boxType + 'Open', true);
						}
					}

					box.animation.curAnim.curFrame = box.animation.curAnim.frames.length - 1;
					box.animation.curAnim.reverse();
					if(daText != null)
					{
						daText.kill();
						remove(daText);
						daText.destroy();
					}
					skipText.visible = false;
					updateBoxOffsets(box);
					FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
				}
				else startNextDialog();
				FlxG.sound.play(Paths.sound(closeSound), closeVolume);
			}
			else if(daText.finishedText)
			{
				var char:DialogueCharacterPsych = arrayCharacters[lastCharacter];
				if(char != null && char.animation.curAnim != null && char.animationIsLoop() && char.animation.finished)
					char.playAnim(char.animation.curAnim.name, true);
			}
			else
			{
				var char:DialogueCharacterPsych = arrayCharacters[lastCharacter];
				if(char != null && char.animation.curAnim != null && char.animation.finished)
					char.animation.curAnim.restart();
			}

			if(box.animation.curAnim.finished)
			{
				for (boxType in textBoxTypes)
				{
					var checkArray:Array<String> = ['', 'center-'];
					var animName:String = box.animation.curAnim.name;
					for (check in checkArray)
					{
						if(animName == check + boxType || animName == check + boxType + 'Open')
							box.animation.play(check + boxType, true);
					}
				}
				updateBoxOffsets(box);
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0)
			{
				for (i => char in arrayCharacters)
				{
					if(char != null)
					{
						if(i != lastCharacter)
						{
							switch(char.jsonFile.dialogue_pos)
							{
								case 'left':
									char.x -= scrollSpeed * elapsed;
									if(char.x < char.startingPos + offsetPos) char.x = char.startingPos + offsetPos;
								case 'center':
									char.y += scrollSpeed * elapsed;
									if(char.y > char.startingPos + FlxG.height) char.y = char.startingPos + FlxG.height;
								case 'right':
									char.x += scrollSpeed * elapsed;
									if(char.x > char.startingPos - offsetPos) char.x = char.startingPos - offsetPos;
							}
							char.alpha -= 3 * elapsed;
							if(char.alpha < 0.00001) char.alpha = 0.00001;
						}
						else
						{
							switch(char.jsonFile.dialogue_pos)
							{
								case 'left':
									char.x += scrollSpeed * elapsed;
									if(char.x > char.startingPos) char.x = char.startingPos;
								case 'center':
									char.y -= scrollSpeed * elapsed;
									if(char.y < char.startingPos) char.y = char.startingPos;
								case 'right':
									char.x -= scrollSpeed * elapsed;
									if(char.x < char.startingPos) char.x = char.startingPos;
							}
							char.alpha += 3 * elapsed;
							if(char.alpha > 1) char.alpha = 1;
						}
					}
				}
			}
		}
		else //Dialogue ending
		{
			if(box != null && box.animation.curAnim.curFrame <= 0)
			{
				box.kill();
				remove(box);
				box.destroy();
				box = null;
			}

			if(bgFade != null)
			{
				bgFade.alpha -= 0.5 * elapsed;
				if(bgFade.alpha <= 0)
				{
					bgFade.kill();
					remove(bgFade);
					bgFade.destroy();
					bgFade = null;
				}
			}

			for (leChar in arrayCharacters)
			{
				if(leChar != null)
				{
					switch(leChar.jsonFile.dialogue_pos)
					{
						case 'left':
							leChar.x -= scrollSpeed * elapsed;
						case 'center':
							leChar.y += scrollSpeed * elapsed;
						case 'right':
							leChar.x += scrollSpeed * elapsed;
					}
					leChar.alpha -= elapsed * 10;
				}
			}

			if(box == null && bgFade == null)
			{
				for (i in 0...arrayCharacters.length)
				{
					var leChar:DialogueCharacterPsych = arrayCharacters[0];
					if(leChar != null)
					{
						arrayCharacters.remove(leChar);
						leChar.kill();
						remove(leChar);
						leChar.destroy();
					}
				}
				finishThing();
				kill();
			}
		}
		super.update(elapsed);
	}

	var lastCharacter:Int = -1;
	var lastBoxType:String = '';
	function startNextDialog():Void
	{
		var curDialogue:DialogueLine = null;
		do
		{
			curDialogue = dialogueList.dialogue[currentText];
		}
		while(curDialogue == null);

		if(curDialogue.text == null || curDialogue.text.length < 1) curDialogue.text = ' ';
		if(curDialogue.boxState == null) curDialogue.boxState = 'normal';
		if(curDialogue.speed == null || Math.isNaN(curDialogue.speed)) curDialogue.speed = 0.05;

		var animName:String = curDialogue.boxState;
		var boxType:String = textBoxTypes[0];
		for (typeBox in textBoxTypes)
		{
			if(typeBox == animName)
				boxType = animName;
		}

		var character:Int = 0;
		box.visible = true;
		for (i => char in arrayCharacters)
		{
			if(char.curCharacter == curDialogue.portrait)
			{
				character = i;
				break;
			}
		}
		var centerPrefix:String = '';
		var lePosition:String = arrayCharacters[character].jsonFile.dialogue_pos;
		if(lePosition == 'center') centerPrefix = 'center-';

		if(character != lastCharacter)
		{
			box.animation.play(centerPrefix + boxType + 'Open', true);
			updateBoxOffsets(box);
			box.flipX = (lePosition == 'left');
		}
		else if(boxType != lastBoxType)
		{
			box.animation.play(centerPrefix + boxType, true);
			updateBoxOffsets(box);
		}
		lastCharacter = character;
		lastBoxType = boxType;

		daText.text = curDialogue.text;
		daText.delay = curDialogue.speed;
		daText.sound = curDialogue.sound;
		if(daText.sound == null || daText.sound.trim() == '') daText.sound = 'dialogue';
		
		daText.y = DEFAULT_TEXT_Y;
		if(daText.rows > 2) daText.y -= LONG_TEXT_ADD;

		var char:DialogueCharacterPsych = arrayCharacters[character];
		if(char != null)
		{
			char.playAnim(curDialogue.expression, daText.finishedText);
			if(char.animation.curAnim != null)
			{
				var rate:Float = 24 - (((curDialogue.speed - 0.05) / 5) * 480);
				char.animation.curAnim.frameRate = FlxMath.bound(rate, 12, 48);
			}
		}
		currentText++;

		if(nextDialogueThing != null) nextDialogueThing();
	}

	inline public static function parseDialogue(path:String):DialogueFile
	{
		#if MODS_ALLOWED
		return cast (FileSystem.exists(path)) ? Json.parse(File.getContent(path)) : dummy();
		#else
		return cast (Assets.exists(path, TEXT)) ? Json.parse(Assets.getText(path)) : dummy();
		#end
	}

	inline public static function dummy():DialogueFile
	{
		return {
			dialogue: [
				{
					expression: "talk",
					text: "DIALOGUE NOT FOUND",
					boxState: "normal",
					speed: 0.05,
					portrait: "bf"
				}
			]
		};
	}

	public static function updateBoxOffsets(box:FlxSprite) // Had to make it static because of the editors
	{
		box.centerOffsets();
		box.updateHitbox();

		if(box.animation.curAnim.name.startsWith('angry'))
		{
			box.offset.set(50, 65);
		}
		else if(box.animation.curAnim.name.startsWith('center-angry'))
		{
			box.offset.set(50, 30);
		}
		else
		{
			box.offset.set(10, 0);
		}

		if(!box.flipX) box.offset.y += 10;
	}
}