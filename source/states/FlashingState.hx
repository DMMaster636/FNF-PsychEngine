package states;

class FlashingState extends MusicBeatState
{
	static var leftState:Bool = false;
	var options:FlxTypedSpriteGroup<FlxText>;
	var isYes:Bool = true;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		final str:Array<String> = ["Hey, watch out!",
			"This Mod contains some flashing lights!",
			"", "Do you wish to disable them?", "", ""];
        var warnings:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();
		warnings.alpha = 0;
        for (num => txt in str)
        {
            if(txt.length < 1) continue;

            var warnText:FlxText = new FlxText(0, 0, FlxG.width, txt, 24);
            warnText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
            warnText.screenCenter();
            add(warnText);
            warnText.y += ((num - str.length / 2) * 32) + 16;
            warnings.add(warnText);
        }
        add(warnings);

		final keys:Array<String> = ["Yes", "No"];
		options = new FlxTypedSpriteGroup<FlxText>();
		options.alpha = 0;
		for (num => key in keys)
		{
			var button = new FlxText(0, 0, FlxG.width, key);
			button.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
            button.screenCenter();
            add(button);
			button.x += (160 * num) - 80;
            button.y += (((str.length - 1 + num) - str.length / 2) * 32) + 16;
			options.add(button);
		}
		add(options);

		FlxTween.tween(warnings, {alpha: 1}, 0.3, {
			onComplete: function(_) {
				FlxTween.tween(options, {alpha: 1}, 0.3, {
					onComplete: (_) -> updateItems()
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		if(!leftState)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
				isYes = !isYes;
				updateItems();
			}

			if(controls.ACCEPT) confirmSelection(true);
			if(controls.BACK) confirmSelection(false);
		}

		super.update(elapsed);
	}

	function confirmSelection(disable:Bool)
	{
		leftState = true;
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

		ClientPrefs.data.flashing = !disable;
		ClientPrefs.saveSettings();

		if(disable)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
			{
				FlxG.switchState(() -> new TitleState());
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(FlxColor.WHITE, 0.6, function()
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.6, false, function()
				{
					FlxG.switchState(() -> new TitleState());
				});
			});
		}
	}

	// it's clunky but it works.
	function updateItems() 
	{
		options.members[0].alpha = isYes ? 1.0 : 0.6;
		options.members[1].alpha = isYes ? 0.6 : 1.0;
	}
}