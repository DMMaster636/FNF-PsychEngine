package objects;

import backend.animation.PsychAnimationController;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var char:String = '';
	private var isPlayer:Bool = false;
	private var isAnimated:Bool = false;

	public function new(char:String = 'face', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();

		animation = new PsychAnimationController(this);

		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true)
	{
		if(this.char == char) return;

		var name:String = 'icons/' + char;
		if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
		if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

		isAnimated = Paths.fileExists('images/' + name + '.xml', TEXT);

		if(!isAnimated)
		{
			var graphic = Paths.image(name, allowGPU);
			var iSize:Float = Math.round(graphic.width / graphic.height);
			loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / iSize;
			iconOffsets[1] = (height - 150) / iSize;

			animation.add(char, [for(i in 0...frames.frames.length) i], 0, false);
			animation.play(char);
		}
		else
		{
			frames = Paths.getSparrowAtlas(name, allowGPU);
			animation.addByPrefix('0', 'normal', 24, true);
			animation.addByPrefix('1', 'losing', 24, true);
			animation.play('0');
		}
		updateHitbox();

		flipX = isPlayer;
		this.char = char;

		if(char.endsWith('-pixel')) antialiasing = false;
	}

	public function playAnim(animState:Int = 0)
	{
		if(isAnimated) animation.play('$animState');
		else animation.curAnim.curFrame = animState;
	}

	public var autoAdjustOffset:Bool = true;
	override function updateHitbox()
	{
		super.updateHitbox();
		if(autoAdjustOffset)
		{
			if(!isAnimated)
			{
				offset.x = iconOffsets[0];
				offset.y = iconOffsets[1];
			}
			else centerOffsets();
		}
	}

	public function getCharacter():String
		return char;
}