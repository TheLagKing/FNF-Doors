package backend.metadata;

import haxe.Json;
import sys.FileSystem;

enum UnlockMethod{
    KNOBS_ACHIEVEMENT;
	KNOBS;
	ACHIEVEMENT;
    ALWAYS_UNLOCKED;

    WIP;
}

typedef FreeplayCategory = {
	var catName:String;
	var catFPS:Int;
	var catSongs:Array<String>;
	var unlockCondition:UnlockMethod;
	var tiedAchievement:String;
	var knobCost:Int;
}

class FreeplayMetadata {
	public var categories:Array<FreeplayCategory>;

    public function new(){
        var path = Paths.getPreloadPath('data/freeplayCategories.json');

        categories = [];
        
        if (FileSystem.exists(path)) {
            var json:Dynamic = Json.parse(sys.io.File.getContent(path));

            var tempCategories:Array<Dynamic> = [];
            if (json != null) tempCategories = json;
            for(cat in tempCategories){
                categories.push({
                    catName: cat.catName,
                    catFPS: cat.catFPS,
                    catSongs: cat.catSongs,
                    unlockCondition: stringToUnlockMethod(cat.unlockCondition),
                    tiedAchievement: cat.tiedAchievement,
                    knobCost: cat.knobCost
                });
            }
        } else {
            trace('WARNING: No FreeplayMetadata found');
        }
    }

    public function stringToUnlockMethod(unlockCondition:String):UnlockMethod {
        switch (unlockCondition.toUpperCase()) {
            case "KNOBS": return UnlockMethod.KNOBS;
            case "ACHIEVEMENT": return UnlockMethod.ACHIEVEMENT;
            case "KNOBS_ACHIEVEMENT": return UnlockMethod.KNOBS_ACHIEVEMENT;
            case "ALWAYS_UNLOCKED": return UnlockMethod.ALWAYS_UNLOCKED;
            case "WIP": return UnlockMethod.WIP;
            default:
                trace('WARNING: Unknown unlock condition: $unlockCondition, defaulting to FROM_STORY_MODE');
                return UnlockMethod.KNOBS;
        }
    }
}