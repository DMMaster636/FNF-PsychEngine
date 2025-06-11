/*
// Maybe some other time    - DM
package objects;

import backend.animation.PsychAnimationController;
import scripting.LuaUtils;

class Countdown extends FlxSprite
{
	private var hasImage:Bool = false;

	private var imageFile:String = null;
	private var soundFile:FlxSound = new FlxSound();

	private var playbackRate:Float = 1;

	public function new(image:String, sound:String)
	{
		super();

		animation = new PsychAnimationController(this);

		this.moves = false;

		scrollFactor.set();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		if(PlayState.instance != null) playbackRate = PlayState.instance.playbackRate;

		imageFile = image;
		soundFile.loadEmbedded(Paths.sound(sound, true, false), false, true);
		#if FLX_PITCH soundFile.pitch = playbackRate; #end
		soundFile.volume = 0.6;

		var countdownGraphic = (imageFile != null && imageFile.length > 0) ? Paths.image(imageFile) : null;
		if(countdownGraphic != null)
		{
			hasImage = true;
			loadGraphic(countdownGraphic);
		}

		if(PlayState.isPixelStage) setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
		screenCenter();

		antialiasing = (ClientPrefs.data.antialiasing && !PlayState.isPixelStage);

		LuaUtils.getTargetInstance().add(this);
	}

	public function playCountdown()
	{
		if(soundFile.exists) soundFile.play();

		if(!hasImage) new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(_) this.destroy());
		else
		{
			FlxTween.tween(this, {alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					if(LuaUtils.getTargetInstance().members.contains(this))
						LuaUtils.getTargetInstance().remove(this);
					this.destroy();
				}
			});
		}
	}
}*/