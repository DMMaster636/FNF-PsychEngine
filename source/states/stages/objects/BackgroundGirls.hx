package states.stages.objects;

import backend.animation.PsychAnimationController;

class BackgroundGirls extends FlxSprite
{
	var isPissed:Bool = true;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
		animation.addByIndices('danceLeft-alt', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight-alt', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		antialiasing = false;
		swapDanceType();

		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
		animation.play('danceLeft');
	}

	var danceDir:Bool = false;
	public function swapDanceType():Void
	{
		isPissed = !isPissed;
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (!danceDir) animation.play(isPissed ? 'danceLeft-alt' : 'danceLeft', true);
		else animation.play(isPissed ? 'danceRight-alt' : 'danceRight', true);
	}
}