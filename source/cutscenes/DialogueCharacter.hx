package cutscenes;

import haxe.Json;
import lime.utils.Assets;

typedef DialogueAnimArray = {
	var enter_name:String;
	var enter_offsets:Array<Int>;
	var idle_name:String;
	var idle_offsets:Array<Int>;
}

typedef DialogueCharacterFile = {
	var image:String;
	var flipX:Bool;
	var animations:DialogueAnimArray;
	var position:Array<Float>;
}

class DialogueCharacter extends FlxSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf';

	public var jsonFile:DialogueCharacterFile = null;
	public var dialogueAnimations:DialogueAnimArray = null;

	public var curCharacter:String = 'bf';
	public var position:Array<Float> = [0, 0];

	public function new(x:Float = 0, y:Float = 0, character:String = null)
	{
		super(x, y);

		changeCharacter(character);
		antialiasing = false;
	}

	public function changeCharacter(character:String)
	{
		if(character == null) character = DEFAULT_CHARACTER;
		if(character == curCharacter) return;

		curCharacter = character;

		reloadCharacterJson(character);
		frames = Paths.getSparrowAtlas('pixelUI/dialogue/' + jsonFile.image);
		reloadAnimations();

		position = jsonFile.position;
	}

	public function reloadCharacterJson(character:String)
	{
		var characterPath:String = 'images/pixelUI/dialogue/$character.json';
		var rawJson = null;

		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if(!FileSystem.exists(path)) path = Paths.getSharedPath(characterPath);
		if(!FileSystem.exists(path)) path = Paths.getSharedPath('images/pixelUI/dialogue/$DEFAULT_CHARACTER.json');
		rawJson = File.getContent(path);
		#else
		var path:String = Paths.getSharedPath(characterPath);
		rawJson = Assets.getText(path);
		#end

		jsonFile = cast Json.parse(rawJson);
	}

	public function reloadAnimations()
	{
		if(jsonFile.animations != null && jsonFile.animations.length > 0)
		{
			dialogueAnimations = jsonFile.animations;
			animation.addByPrefix('enter', dialogueAnimations.enter_name, 12, false);
			animation.addByPrefix('idle', dialogueAnimations.idle_name, 12, true);
		}
	}

	public function playAnim(animName:String = null)
	{
		// Only these anims are supported... for NOW!
		if(animName != 'enter' || animName != 'idle') return;

		animation.play(animName, true);
		switch(animName)
		{
			case 'enter':
				offset.set(dialogueAnimations.enter_offsets[0], dialogueAnimations.enter_offsets[1]);
			case 'idle':
				offset.set(dialogueAnimations.idle_offsets[0], dialogueAnimations.idle_offsets[1]);
			default:
				offset.set(0, 0);
		}
	}
}