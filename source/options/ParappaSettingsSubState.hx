package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class ParappaSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Parappa';
		rpcTitle = 'Parappa Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Require Good Rank',
			'If checked, requires you to beat a song with the Good rank.',
			'requireGood',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Freestyling',
			'If checked, allows you to go into a Freestyle Mode.',
			'freestyling',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Grading Style: ',
			"How should it be graded?\n(Break Based is recommended in most cases)",
			'gradingStyle',
			'string',
			'Break Based',
			['Interval Based', 'Break Based']);
		addOption(option);

		super();
	}
}
