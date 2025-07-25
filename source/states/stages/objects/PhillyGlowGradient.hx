package states.stages.objects;

import backend.animation.PsychAnimationController;

class PhillyGlowGradient extends FlxSprite
{
	public var originalY:Float;
	public var originalHeight:Int = 400;
	public var intendedAlpha:Float = 1;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		animation = new PsychAnimationController(this);
		originalY = y;

		loadGraphic(Paths.image('philly/gradient')); //This shit was refusing to properly load FlxGradient so fuck it
		scrollFactor.set(0, 0.75);
		setGraphicSize(2000, originalHeight);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		var newHeight:Int = Math.round(height - 1000 * elapsed);
		if(newHeight > 0)
		{
			alpha = intendedAlpha;
			setGraphicSize(2000, newHeight);
			updateHitbox();
			y = originalY + (originalHeight - height);
		}
		else
		{
			alpha = 0;
			y = -5000;
		}

		super.update(elapsed);
	}

	public function bop()
	{
		setGraphicSize(2000, originalHeight);
		updateHitbox();
		y = originalY;
		alpha = intendedAlpha;
	}
}