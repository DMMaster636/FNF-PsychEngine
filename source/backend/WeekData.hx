package backend;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

typedef WeekFile = {
	var songs:Array<Dynamic>;
	var difficulties:String;
	var weekBefore:String;
	var weekName:String;

	var storyName:String;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekColor:Array<Int>;

	var startUnlocked:Bool;
	var hiddenUntilUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public var folder:String = '';

	// JSON variables
	public var songs:Array<Dynamic>;
	public var difficulties:String;
	public var weekBefore:String;
	public var weekName:String;

	public var storyName:String;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekColor:Array<Int>;

	public var startUnlocked:Bool;
	public var hiddenUntilUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;

	public var fileName:String;

	public static function createWeekFile():WeekFile
	{
		return {
			songs: [
				["Bopeebo", "face", [146, 113, 253]],
				["Fresh", "face", [146, 113, 253]],
				["Dad Battle", "face", [146, 113, 253]]
			],
			difficulties: '',
			weekBefore: 'tutorial',
			weekName: 'Custom Week',
			storyName: 'Your New Week',
			weekCharacters: [#if BASE_GAME_FILES 'dad' #else 'bf' #end , 'bf', 'gf'],
			weekBackground: 'stage',
			weekColor: [249, 207, 81],
			startUnlocked: true,
			hiddenUntilUnlocked: false,
			hideStoryMode: false,
			hideFreeplay: false
		};
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String)
	{
		// here ya go - MiguelItsOut
		for (field in Reflect.fields(weekFile))
			if(Reflect.fields(this).contains(field)) // Reflect.hasField() won't fucking work :/
				Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

		this.fileName = fileName;
	}

	public static function reloadWeekFiles(isStoryMode:Null<Bool>)
	{
		if(isStoryMode == null) isStoryMode = PlayState.isStoryMode;

		weeksList = [];
		weeksLoaded.clear();
		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods(), Paths.getSharedPath()];
		var originalLength:Int = directories.length;

		for (mod in Mods.parseList().enabled)
			directories.push(Paths.mods(mod + '/'));
		#else
		var directories:Array<String> = [Paths.getSharedPath()];
		var originalLength:Int = directories.length;
		#end

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getSharedPath('weeks/weekList.txt'));
		for (weekName in sexList)
		{
			for (dirNum => dir in directories)
			{
				var fileToCheck:String = dir + 'weeks/' + weekName + '.json';
				if(!weeksLoaded.exists(weekName))
				{
					var week:WeekFile = getWeekFile(fileToCheck);
					if(week != null)
					{
						var weekFile:WeekData = new WeekData(week, weekName);

						#if MODS_ALLOWED
						if(dirNum >= originalLength) weekFile.folder = dir.substring(Paths.mods().length, dir.length-1);
						#end

						if(weekFile != null && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay)))
						{
							weeksLoaded.set(weekName, weekFile);
							weeksList.push(weekName);
						}
					}
				}
			}
		}

		#if MODS_ALLOWED
		for (dirNum => dir in directories)
		{
			var directory:String = dir + 'weeks/';
			if(FileSystem.exists(directory))
			{
				var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directory + 'weekList.txt');
				for (daWeek in listOfWeeks)
				{
					var path:String = directory + daWeek + '.json';
					if(FileSystem.exists(path)) addWeek(daWeek, path, dir, dirNum, originalLength);
				}

				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
						addWeek(file.substr(0, file.length - 5), path, dir, dirNum, originalLength);
				}
			}
		}
		#end
	}

	private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if(!weeksLoaded.exists(weekToCheck))
		{
			var week:WeekFile = getWeekFile(path);
			if(week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekToCheck);
				if(i >= originalLength)
				{
					#if MODS_ALLOWED
					weekFile.folder = directory.substring(Paths.mods().length, directory.length-1);
					#end
				}
				if((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
				{
					weeksLoaded.set(weekToCheck, weekFile);
					weeksList.push(weekToCheck);
				}
			}
		}
	}

	private static function getWeekFile(path:String):WeekFile
	{
		var rawJson:String = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(path)) rawJson = File.getContent(path);
		#else
		if(OpenFlAssets.exists(path)) rawJson = Assets.getText(path);
		#end

		if(rawJson != null && rawJson.length > 0)
			return cast tjson.TJSON.parse(rawJson);

		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String
		return weeksList[PlayState.storyWeek];

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);

	public static function setDirectoryFromWeek(?data:WeekData = null)
	{
		Mods.currentModDirectory = '';
		if(data != null && data.folder != null && data.folder.length > 0)
			Mods.currentModDirectory = data.folder;
	}
}