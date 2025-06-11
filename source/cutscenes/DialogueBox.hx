package cutscenes;

import haxe.Json;
import openfl.utils.Assets;
import flixel.addons.text.FlxTypeText;

import objects.TypedAlphabet;

typedef TextData = {
	var position:Array<Float>;
	var is_alphabet:Bool;

	var font:String;
	var size:Int;
	var width:Int;
	var color:Array<Int>;

	var border_style:String;
	var border_size:Int;
	var border_color:Array<Int>;
}

typedef BoxAnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

typedef DialogueBoxFile = {
	var image:String;
	var no_antialiasing:Bool;
	var scale:Float;
	var position:Array<Float>;

	var animations:Array<BoxAnimArray>;

	var text:TextData;
}

class DialogueBox extends FlxSpriteGroup
{
	public static final DEFAULT_BOX:String = 'default';

	var box:FlxSprite;

	var swagDialogue:FlxTypeText;

	public function new()
	{
		super();
	}
}