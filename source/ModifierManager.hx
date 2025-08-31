package;

import sys.io.File;
import haxe.Json;
import flixel.math.FlxRandom;

enum UnlockTypes {
    NONE;
    FINISHGAME;
    FINISHGAME_HARD;
    WORST_HOTEL_EVER;
    SEEK_MASTERY;
    FIGURE_MASTERY;
    HALT_MASTERY;
}

typedef Modifier = {
    // ALL MODIFIER TYPES
	name:String,
	desc:String,
	knobAddition:Float, //1.1 ; 1.5 etc
	knobMultiplier:Float,
    ID:Int,
    blocksModifiers:Array<Int>,
    categories:Array<String>,
    unlockCondition:UnlockTypes,
    ?specific:String, // null = not specific to anything, "story" = specific to story mode, "freeplay" = specific to freeplay

    // ONLY USED IN FREEPLAY
    ?showsUpEverywhere:Bool,
    ?allowedSongs:Null<Array<String>>,
    ?blacklistedSongs:Null<Array<String>>,
    ?hellSpecific:Bool,

    // ONLY USED IN STORY MODE
    ?shouldCheckOnAllSongs:Bool,
    ?checkOn:Null<Array<String>>, //for the modifiers that you only need to check on specific songs
}

class ModifierManager {
    private static final CATEGORY_ORDER:Array<String> = [
        "light", "money", "items", "health", "notes", "spawn", "rush", "screech", "timothy", "eyes", "figure", "seek", "halt", "jack", "glitch", "shadow", "void", "boring"
    ];

    public static var defaultModifiers:Array<Modifier> = [];
    public static var disabledModifierIDs:Array<Int> = [];

    // FREEPLAY SPECIFIC
    public static var freeplayScoreMod:Float = 1.0;
    public static var freeplayChosenModifiers:Array<Modifier> = [];

    public static function init(){
        defaultModifiers = [];

        inline function lp(text:String){
            return Lang.getModifierText(text);
        }

        var modifierJsonData:Dynamic = Json.parse(Paths.getTextFromFile("data/modifiers.json"));
        defaultModifiers = [];

        for(field in Reflect.fields(modifierJsonData)){
            var modData = Reflect.field(modifierJsonData, field);
            var newModifier:Modifier = cast {
                name: lp(field)[0],
                desc: lp(field)[1],
                knobAddition: modData.knobAddition??1.0,
                knobMultiplier: modData.knobMultiplier??1.0,
                ID: modData.id,
                blocksModifiers: modData.blocksMods,
                categories: modData.categories,
                unlockCondition: switch(modData.unlockCondition){
                    case "none": UnlockTypes.NONE;
                    case "finishgame": UnlockTypes.FINISHGAME;
                    case "finishgame_hard": UnlockTypes.FINISHGAME_HARD;
                    case "figure_mastery": UnlockTypes.FIGURE_MASTERY;
                    case "seek_mastery": UnlockTypes.SEEK_MASTERY;
                    case "halt_mastery": UnlockTypes.HALT_MASTERY;
                    default: UnlockTypes.NONE;
                },
                specific: modData.specific,
            
                showsUpEverywhere: modData.showsUpEverywhere,
                allowedSongs: modData.allowedSongs,
                blacklistedSongs: modData.blacklistedSongs,
                hellSpecific: modData.hellSpecific,
            
                shouldCheckOnAllSongs: modData.shouldCheckOnAllSongs,
                checkOn: modData.checkOn, 
            }

            defaultModifiers.push(newModifier);
        }

        defaultModifiers.sort(function(a,b){
            if(a.ID == 61) return -1;
            if(b.ID == 61) return 1;

            if(CATEGORY_ORDER.indexOf(a.categories[0]) < CATEGORY_ORDER.indexOf(b.categories[0])){
                return -1;
            } else if (CATEGORY_ORDER.indexOf(a.categories[0]) > CATEGORY_ORDER.indexOf(b.categories[0])){
                return 1;
            } else {
                return (a.knobAddition * a.knobMultiplier) < (b.knobAddition * b.knobMultiplier) ? 
                    -1 : 
                    (a.knobAddition * a.knobMultiplier) > (b.knobAddition * b.knobMultiplier) ? 
                        1 : 
                        0;
            }
            return 0;
        });

        disabledModifierIDs = [];
    }

    public static function returnModifier(ID:Int):Null<Modifier>{
        for(i in 0...defaultModifiers.length){
            if (defaultModifiers[i].ID == ID){
                return defaultModifiers[i];
            }
        }
        return null;
    }

    public static function addModifier(ID:Int, isFreeplay:Bool):Dynamic{
        var proposedModifier:Modifier = null;
        var acceptingModifier:Bool = false;
        for(i in 0...defaultModifiers.length){
            if (defaultModifiers[i].ID == ID){
                proposedModifier = defaultModifiers[i];
                break;
            }
        }

        if(!disabledModifierIDs.contains(proposedModifier.ID)){
            acceptingModifier = true;
            for(i in proposedModifier.blocksModifiers){
                disabledModifierIDs.push(i);
            }
            if(isFreeplay) freeplayChosenModifiers.push(proposedModifier);
            else DoorsUtil.curRun.runModifiers.push(proposedModifier);
        } else {
            acceptingModifier = false;
            return null;
        }

        if(isFreeplay) DoorsUtil.recalculateScoreModifier();
        else {
            DoorsUtil.saveRunData();
            DoorsUtil.recalculateKnobModifier();
        }

        return proposedModifier;
    }

    public static function removeModifier(ID:Int, isFreeplay:Bool):Modifier{
        var removedModifier:Modifier = null;
        if(isFreeplay){
            for(i in 0...freeplayChosenModifiers.length){
                if (freeplayChosenModifiers[i].ID == ID){
                    removedModifier = freeplayChosenModifiers[i];
                }
            }
            freeplayChosenModifiers.remove(removedModifier);
        } else {
            for(i in 0...DoorsUtil.curRun.runModifiers.length){
                if (DoorsUtil.curRun.runModifiers[i].ID == ID){
                    removedModifier = DoorsUtil.curRun.runModifiers[i];
                }
            }
            DoorsUtil.curRun.runModifiers.remove(removedModifier);
        }
        for(i in removedModifier.blocksModifiers){
            disabledModifierIDs.remove(i);
        }

        if(isFreeplay) DoorsUtil.recalculateScoreModifier();
        else {
            DoorsUtil.saveRunData();
            DoorsUtil.recalculateKnobModifier();
        }
        return removedModifier;
    }

    public static function onReset(){
        disabledModifierIDs = [];
        freeplayScoreMod = 1.0;
        freeplayChosenModifiers = [];
    }

    public static function isModifierApplicable(ID:Int, song:String):Bool{
        var mod = returnModifier(ID);
        
        return mod.checkOn.contains(song.toLowerCase());
    }

    public static function modifierActive(ID:Int, isFreeplay:Bool):Bool{
        if(isFreeplay){
            for(i in 0...freeplayChosenModifiers.length){
                if (freeplayChosenModifiers[i].ID == ID){
                    return true;
                }
            }
        } else {
            for(i in 0...DoorsUtil.curRun.runModifiers.length){
                if (DoorsUtil.curRun.runModifiers[i].ID == ID){
                    return true;
                }
            }
        }
        return false;
    }
}