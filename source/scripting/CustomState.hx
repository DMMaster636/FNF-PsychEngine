/*package scripting;

import flixel.FlxObject;

class CustomState extends MusicBeatState
{
	public static var name:String = 'unnamed';
	public static var instance:CustomState;

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "openCustomState", openCustomState);
		Lua_helper.add_callback(lua, "closeCustomState", closeCustomState);
		Lua_helper.add_callback(lua, "insertToCustomState", insertToCustomState);
	}
	#end
	
	public static function openCustomState(name:String, ?pauseGame:Bool = false)
	{
		if(pauseGame)
		{
			FlxG.camera.followLerp = 0;
			persistentUpdate = false;
			persistentDraw = true;
			PlayState.instance?.paused = true;
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				PlayState.instance?.vocals.pause();
				PlayState.instance?.opponentVocals.pause();
			}
		}
		FlxG.switchState(() -> new CustomState(name));
	}

	public static function closeCustomState()
	{
		if(instance != null)
		{
			PlayState.instance.closeState();
			return true;
		}
		return false;
	}

	public static function insertToCustomState(tag:String, ?pos:Int = -1)
	{
		if(instance != null)
		{
			var tagObject:FlxObject = cast (MusicBeatState.getVariables().get(tag), FlxObject);

			if(tagObject != null)
			{
				if(pos < 0) instance.add(tagObject);
				else instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}

	override function create()
	{
		instance = this;
		setOnHScript('customState', instance);

		callOnScripts('onCreate', [name]);
		super.create();
		callOnScripts('onCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomState.name = name;
		setOnHScript('customStateName', name);
		super();
	}
	
	override function update(elapsed:Float)
	{
		callOnScripts('onUpdate', [name, elapsed]);
		super.update(elapsed);
		callOnScripts('onUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		callOnScripts('onDestroy', [name]);
		instance = null;
		name = 'unnamed';

		setOnHScript('customState', null);
		setOnHScript('customStateName', name);
		super.destroy();
	}
}*/