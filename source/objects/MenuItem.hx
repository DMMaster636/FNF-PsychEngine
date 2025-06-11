package objects;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;
	public var flashColor:FlxColor = 0xFF33FFFF;

	private var flashingElapsed:Float = 0;
	final flashes_ps:Int = 6;

	public var isFlashing(default, set):Bool = false;
	public function set_isFlashing(value:Bool):Bool
	{
		flashingElapsed = 0;
		color = value ? flashColor : FlxColor.WHITE;
		return isFlashing = value;
	}

	public function new(x:Float, y:Float, weekName:String = '', ?flashColor:FlxColor = 0xFF33FFFF)
	{
		super(x, y);

		loadGraphic(Paths.image('storymenu/' + weekName));
		this.flashColor = flashColor;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isFlashing)
		{
			flashingElapsed += elapsed;
			color = (Math.floor(flashingElapsed * FlxG.updateFramerate * flashes_ps) % 2 == 0) ? flashColor : FlxColor.WHITE;
		}
	}
}
