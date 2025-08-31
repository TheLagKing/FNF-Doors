package;

import backend.metadata.FreeplayMetadata;
import sys.io.File;
import haxe.Json;
import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var misses:Map<String, Int> = new Map();
	#else
	public static var weekScores:Map<String, Int> = new Map<String, Int>();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var misses:Map<String, Int> = new Map<String, Int>();
	#end


	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?misses:Int = -1, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
			}
		}
		else {
			setScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
		}
		if(getMisses(diff == 3 ? song + "-hell ": song) == -1 || misses < getMisses(diff == 3 ? song + "-hell ": song)) setMisses((diff == 3 ? song + "-hell ": song), misses);
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + CoolUtil.getDifficultyFilePath(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		} else FlxG.save.data.weekScores = weekScores;

		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		} else FlxG.save.data.songScores = songScores;

		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		} else FlxG.save.data.songRating = songRating;

		if (FlxG.save.data.misses != null)
		{
			misses = FlxG.save.data.misses;
		} else {
			FlxG.save.data.misses = misses;
			var allSongs:Array<String> = [];
			var tmp:Array<Array<String>> = [];
			var freeplayMetadata:FreeplayMetadata = new FreeplayMetadata();
			for(testicle in freeplayMetadata.categories){
				if(testicle.unlockCondition == KNOBS_ACHIEVEMENT || testicle.unlockCondition == ALWAYS_UNLOCKED)
				for(song in testicle.catSongs){
					allSongs.push(song);
				}
			}
	
			for (song in allSongs) {
				song = song.trim();
				if (!FlxG.save.data.misses.exists(formatSong(song, 1))) {
					setMisses(song, -1);
				}
			}

			trace(FlxG.save.data.misses);
		}
	}

	public static function setMisses(song:String, misses:Int):Void
	{
		var daSong:String = formatSong(song, 1);
		FlxG.save.data.misses.set(daSong, misses);
		FlxG.save.flush();
	}

	public static function getMisses(song:String):Int
	{
		var daSong:String = formatSong(song, 1);
		if (!FlxG.save.data.misses.exists(daSong))
			setMisses(daSong, -1);

		return FlxG.save.data.misses.get(daSong);
	}

	public static function haveAllFC():Bool
	{
		for (song in misses.keys())
		{
			if (getMisses(formatSong(song, 1)) != 0 || getMisses(formatSong(song, 0)) != 0 || getMisses(formatSong(song, 2)) != 0 || getMisses(formatSong(song, 3)) != 0)
			{
				return false;
			}
		}

		return true;
	}
}