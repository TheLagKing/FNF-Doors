package;

import PopUp;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxTextNew as FlxText;

using StringTools;

typedef Award = {
	name:String,
	description:String,
	achievementID:String,
	imageName:String,
	hidden:Bool,

	knobAward:Int
}

class AwardsManager {
	public static var fullAwards:Array<Award> = [];
	public static var achievementsStuff:Array<Dynamic> = [];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var runJackCounter:Int = 0;
	public static var hasOnlyPickedHigher:Bool = true;
	public static var hasOnlyPickedLower:Bool = true;
	public static var hasMissedHeartbeat:Bool = false;

	//Achievements to check after a song
	public static var rushFind:Bool = false;
	public static var screechFind:Bool = false;
	public static var seekFind:Bool = false;
	public static var timothyFind:Bool = false;
	public static var ambushFind:Bool = false;
	public static var eyesFind:Bool = false;
	public static var figureFind:Bool = false;
	public static var glitchFind:Bool = false;
	public static var haltFind:Bool = false;
	public static var jackFind:Bool = false;
	public static var RNJesus:Bool = false;
	public static var onTheEdge:Bool = false;
	public static var neverTripped:Bool = false;
	public static var completionist:Bool = false;
	public static var comboNotFound:Bool = false;

	//Achievements to check after a door
	public static var fuckScreech:Bool = false;
	public static var burnTheHotel:Bool = false;
	public static var seeingDouble:Bool = false;
	public static var donation:Bool = false;
	public static var smallBusiness:Bool = false;
	public static var crucifix:Bool = false;
	public static var welcomeBack:Bool = false;
	public static var anyoneHome:Bool = false;

	//Achievements to check after a run
	public static var youWin:Bool = false;
	public static var youWinHard:Bool = false;
	public static var thatsEasy:Bool = false;
	public static var tissButAScratch:Bool = false;
	public static var hotelHell:Bool = false;
	public static var cardiacArrest:Bool = false;
	public static var youreFast:Bool = false;
	public static var youreSlow:Bool = false;

	//Achievements to check after dying
	public static var absoluteFailure:Bool = false;
	public static var rip:Bool = false;
	public static var voidFind:Bool = false;
	
    public static function getAwardFromID(ID:String):Award {
		for (award in fullAwards){
			if (award.achievementID == ID) return award;
		}
		return null;
	}

	public static function getAwardImageName(award:Award):String {
		if (award != null && award.imageName != null) return award.imageName;
		return "default";
	}

	public static function onEndSong(instance:PlayState):Void {
		if(DoorsUtil.modifierActive(54) || DoorsUtil.modifierActive(55)) return;

		//Check for opponent achievements
		var afterSongAchievements:Array<String> = [
			'rushFind',			'screechFind',	'seekFind',
			'timothyFind',		'ambushFind',	'eyesFind',
			'figureFind',		'glitchFind',	'haltFind',
			'jackFind',			'RNJesus', 		'onTheEdge',
			'neverTripped',		'completionist', 'comboNotFound',
		];
		
		for(a in afterSongAchievements){
			if(Reflect.getProperty(AwardsManager, a)){
				onUnlock(a);
				Reflect.setProperty(FlxG.save.data, a, true);
			}
		}
	}

	public static function onLeaveDoor():Void {
		if(DoorsUtil.modifierActive(54) || DoorsUtil.modifierActive(55)) return;

		var afterDoorAchievements:Array<String> = [
			'fuckScreech',			'burnTheHotel',
			'seeingDouble',			"donation",
			"smallBusiness",		"anyoneHome",
			"crucifix", 			"welcomeBack"
		];

		for(a in afterDoorAchievements){
			if(Reflect.getProperty(AwardsManager, a)){
				onUnlock(a);
				Reflect.setProperty(FlxG.save.data, a, true);
			}
		}
		
		FlxG.save.data.hasOnlyPickedHigher = hasOnlyPickedHigher;
		FlxG.save.data.hasOnlyPickedLower = hasOnlyPickedLower;
		FlxG.save.data.hasMissedHeartbeat = hasMissedHeartbeat;
	}

	public static function onFinishRun():Void {		
		if(DoorsUtil.modifierActive(54) || DoorsUtil.modifierActive(55)) return;
		
		var afterRunAchievements:Array<String> = [
			'youWin',			'youWinHard',		'thatsEasy',
			'tissButAScratch',	'hotelHell',		'cardiacArrest',
			'youreFast',		'youreSlow'
		];

		for(a in afterRunAchievements){
			if(Reflect.getProperty(AwardsManager, a)){
				onUnlock(a);
				Reflect.setProperty(FlxG.save.data, a, true);
			}
		}

		FlxG.save.data.hasOnlyPickedHigher = hasOnlyPickedHigher;
		FlxG.save.data.hasOnlyPickedLower = hasOnlyPickedLower;
		FlxG.save.data.hasMissedHeartbeat = hasMissedHeartbeat;
		FlxG.save.flush();
	}

	public static function onDeath():Void {
		var afterRunAchievements:Array<String> = [
			'absoluteFailure', "rip", "voidFind"
		];

		for(a in afterRunAchievements){
			if(Reflect.getProperty(AwardsManager, a)){
				onUnlock(a);
				Reflect.setProperty(FlxG.save.data, a, true);
			}
		}
	}
	
    public static function onUnlock(aID:String):Void {
		var award = getAwardFromID(aID);
		
		if (award != null && !isUnlocked(award))
		{
			DoorsUtil.addKnobs(award.knobAward, 1);
			Main.popupManager.addPopup(new AwardPopup(6, award));
		}
	}

	public static function isUnlocked(award:Award):Bool {
		if(award != null){
			return Reflect.getProperty(FlxG.save.data, award.achievementID) != null && Reflect.getProperty(FlxG.save.data, award.achievementID) == true;
		}
		return false;
	}

	public static function isUnlockedID(awardID:String):Bool {
		if(awardID != null){
			return Reflect.getProperty(FlxG.save.data, awardID) != null && Reflect.getProperty(FlxG.save.data, awardID) == true;
		}
		return false;
	}

	public static function isAllUnlocked(){
		for (award in fullAwards){
			if(!isUnlocked(award)) return false;
		}
		return true;
	}

	public static function loadAchievements():Void {
		fullAwards = [
			{name: "", 	description: "", 	achievementID: 'anyoneHome',		imageName: 'anyoneHome',		hidden: false,	knobAward:20},
			{name: "", 	description: "", 	achievementID: 'rushFind', 			imageName: 'rushFind', 			hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'screechFind', 		imageName: 'screechFind',	 	hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'eyesFind', 			imageName: 'eyesFind', 			hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'ambushFind', 		imageName: 'ambushFind', 		hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'timothyFind', 		imageName: 'timothyFind', 		hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'haltFind', 			imageName: 'haltFind', 			hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'jackFind', 			imageName: 'jackFind', 			hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'seekFind', 			imageName: 'seekFind', 			hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'figureFind', 		imageName: 'figureFind', 		hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'glitchFind', 		imageName: 'glitchFind', 		hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'voidFind',		 	imageName: 'voidFind',			hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'rip',		 		imageName: 'rip',			 	hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'absoluteFailure', 	imageName: 'absoluteFailure', 	hidden: false,	knobAward:1},
			{name: "", 	description: "", 	achievementID: 'smallBusiness',	    imageName: 'smallBusiness',		hidden: false,	knobAward:30},
			{name: "", 	description: "", 	achievementID: 'donation', 			imageName: 'donation', 			hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'crucifix',	  	    imageName: 'crucifix',			hidden: false,	knobAward:75},
			{name: "", 	description: "", 	achievementID: 'fuckScreech', 		imageName: 'fuckScreech', 		hidden: false,	knobAward:50},
			{name: "", 	description: "", 	achievementID: 'burnTheHotel', 		imageName: 'burnTheHotel', 		hidden: false,	knobAward:75},
			{name: "", 	description: "", 	achievementID: 'seeingDouble', 		imageName: 'seeingDouble',		hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'comboNotFound', 	imageName: 'comboNotFound', 	hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'youWin', 			imageName: 'youWin', 			hidden: false,	knobAward:200},
			{name: "", 	description: "", 	achievementID: 'youWinHard', 		imageName: 'youWinHard', 		hidden: false,	knobAward:250},
			{name: "", 	description: "", 	achievementID: 'thatsEasy', 		imageName: 'thatsEasy', 		hidden: false,	knobAward:300},
			{name: "", 	description: "", 	achievementID: 'welcomeBack', 		imageName: 'welcomeBack',	 	hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'onTheEdge', 		imageName: 'onTheEdge', 		hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'neverTripped', 		imageName: 'neverTripped', 		hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'cardiacArrest', 	imageName: 'cardiacArrest', 	hidden: false,	knobAward:100},
			{name: "", 	description: "", 	achievementID: 'RNJesus', 			imageName: 'RNJesus', 			hidden: false,	knobAward:500},
			{name: "", 	description: "", 	achievementID: 'tissButAScratch', 	imageName: 'tissButAScratch', 	hidden: false,	knobAward:500},
			{name: "", 	description: "", 	achievementID: 'completionist', 	imageName: 'completionist', 	hidden: false,	knobAward:1000},
			{name: "", 	description: "", 	achievementID: 'hotelHell', 		imageName: 'hotelHell', 		hidden: false,	knobAward:400},
		];

		for(award in fullAwards){
			award.name = Lang.getAwardText(award.achievementID)[0];
			award.description = Lang.getAwardText(award.achievementID)[1];
		}

		if(FlxG.save.data.hasOnlyPickedHigher != null){
			hasOnlyPickedHigher = FlxG.save.data.hasOnlyPickedHigher;
		}
		if(FlxG.save.data.hasOnlyPickedHigher != null){
			hasOnlyPickedLower = FlxG.save.data.hasOnlyPickedLower;
		}
		if(FlxG.save.data.hasMissedHeartbeat != null){
			hasMissedHeartbeat = FlxG.save.data.hasMissedHeartbeat;
		}
	}
}