package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	//So this is kinda softcoded number of characters.
	//Basically what this does is this assumes that the **FIRST** character is gonna be bf right
	//Then it assumes the **SECOND** character is gf (and will hide it if it shouldn't exist in the stage)
	//Then every character after it will be it's own separate character that you control with the char dropdown thing in chart editor
	//The positions are stored in the balls (in the stages, most likely, may change)
	var characters:Array<String>;
	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var stage:String;
	var freeplayStage:String;

	var arrowSkin:String;
	var opponentArrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
	var hasHeartbeat:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var opponentArrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
	public var stage:String;
	public var freeplayStage:String;
	public var characters:Array<String> = ['bf', 'gf', 'dad'];
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var player3:String = 'tim_joke';
	public var gfVersion:String = 'gf';
	public var hasHeartbeat:Bool = false;

	static var dummySong:String = '{
		"characters": ["bf", "gf", "OPPONENT_NAME"],
		"player1": "bf",
		"player2": "OPPONENT_NAME",
		"events": [],
		"notes": [
			{
				"sectionNotes": [],
				"typeOfSection": 0,
				"lengthInSteps": 16,
				"gfSection": false,
				"altAnim": false,
				"mustHitSection": false,
				"changeBPM": false
			}
		],
		"gfVersion": "gf",
		"player3": null,
		"splashSkin": "noteSplashes",
		"song": "SONG_NAME",
		"stage": "STAGE_NAME",
		"freeplayStage": "STAGE_NAME",
		"validScore": true,
		"arrowSkin": "",
		"needsVoices": true,
		"speed": 2.5,
		"bpm": 180}
	';
	
	private static function convertToDoors(songJson:Dynamic){ // Convert Psych Charts to Doors Charts
		if(songJson.characters == null){
			songJson.characters = [];
			songJson.characters.push(songJson.player1);
			songJson.characters.push(songJson.gfVersion);
			songJson.characters.push(songJson.player2);
			if(songJson.player3 != "mom" && songJson.player3 != null){
				songJson.characters.push(songJson.player3);
			}
			trace(songJson.characters);
		}
	}

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		convertToDoors(songJson);
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function checkChartExists(jsonInput:String, ?folder:String):Bool
	{
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String   = Paths.formatToSongPath(jsonInput);

		//Prioritize assets folder path if it exists
		var path =Paths.json(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(path)) {
			return true;
		}

		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			return true;
		}
		#end

		return false;
	}


	public static function createDummySong(jsonInput:String, ?folder:String):SwagSong
	{
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		var swagShit:SwagSong = cast Json.parse(dummySong);
		swagShit.validScore = false;
		swagShit.song = formattedSong.trim();
		trace("Chart Missing from: "+formattedSong);
		return swagShit;
	}

	public static var theSongChartJsonToParse:Null<String> = null;
	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson:Null<String> = null;
		var songJson:Dynamic = null;
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		var path =Paths.json(formattedFolder + '/' + formattedSong);
		try{
			if(rawJson == null) {
				if(FileSystem.exists(path)) {
					#if sys
					rawJson = File.getContent(path).trim();
					#else
					rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
					#end
				}
			}

			if(rawJson != null)
			{
				if(jsonInput != "events" && jsonInput != "metadata") theSongChartJsonToParse = rawJson;
				
				while (!rawJson.endsWith("}"))
				{
					rawJson = rawJson.substr(0, rawJson.length - 1);
					// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
				}

			// FIX THE CASTING ON WINDOWS/NATIVE
			// Windows???
			// trace(songData);

			// trace('LOADED FROM JSON: ' + songData.notes);
			/* 
				for (i in 0...songData.notes.length)
				{
					trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
					// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
				}

					daNotes = songData.notes;
					daSong = songData.song;
					daBpm = songData.bpm; */

				songJson = parseJSONshit(rawJson);
				if(jsonInput != 'events') StageData.loadDirectory(songJson);
				onLoadJson(songJson);
			}
		}
		catch(err){
			var swagShit:SwagSong = cast Json.parse(dummySong);
			swagShit.validScore = false;
			swagShit.song = formattedSong.trim();
			trace(err);
			trace("Dummy Song Chart: "+formattedSong);
			songJson = swagShit;
		}

		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}

