package objects.items;

import states.mechanics.GuidanceNotes;
import flixel.math.FlxRandom;

class Candle extends Item{
    var isUsing:Bool = false;
    final maxDurability:Float = 25.0;
    private var isBroken:Bool = false;

    override function create(){
        this.itemData = {
            itemID: "candle",
            displayName: lp("candle")[0],
            displayDesc: lp("candle")[1],
            isPlural: lp("candle")[2],
            itemCoinPrice: 200,
            itemKnobPrice: 30,
            itemSlot: -1,
            durabilityRemaining: 45,
            maxDurability: 45,

            statesAllowed: ["play"]
        }
    }

    override function preload(){
        var theMap:Map<String, Array<String>> = [
			"images" => [],
            "sounds" => [],
            "music" => []
		];

		return theMap;
    }

    override function update(elapsed:Float) {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 8, 0, 1);
        
        if(this.isUsing){
            this.itemData.durabilityRemaining -= elapsed;
        }

        if(this.itemData.durabilityRemaining <= 0 && !isBroken){
            if (Std.isOfType(game, PlayState)) {
                isBroken = true;
                onSongBreak();
                DoorsUtil.curRun.curInventory.removeItem(itemData);
            }
        }

        super.update(elapsed);
    }

    override function onSongUse() { 
        if(PlayState.instance.activeMechanics.exists("states.mechanics.GuidanceNotes")){
            var guidanceNotes:GuidanceNotes = cast PlayState.instance.activeMechanics.get("states.mechanics.GuidanceNotes");
            isUsing = !isUsing;

            if(isUsing){ // light it up
                guidanceNotes.requirement = function(){
                    return true;
                }
                guidanceNotes.randomRequirement = function(){
                    return true;
                }
                songUseAnimation();
            } else { // kill
                guidanceNotes.requirement = function(){
                    return switch(PlayState.storyDifficulty){
                        case 0: game.ratingPercent < 0.90;
                        case 2: game.health <= 0.5 && game.ratingPercent < 0.85 && game.songMisses >= 20;
                        case 3: false;

                        case 1: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                        default: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                        
                    }
                }
                guidanceNotes.randomRequirement = function(){
                    return switch(PlayState.storyDifficulty){
                        case 0: FlxG.random.bool(50 * ((2.0 - game.health) / 2));
                        case 2: FlxG.random.bool(20 * ((2.0 - game.health) / 2));
                        case 3: false;
                        
                        case 1: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
                        default: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
                    }
                }
                songStopAnimation(false);
            }
        } else {
            cannotUse();
        }
    }

    function onSongBreak(){
        if(PlayState.instance.activeMechanics.exists("states.mechanics.GuidanceNotes")){
            var guidanceNotes:GuidanceNotes = cast PlayState.instance.activeMechanics.get("states.mechanics.GuidanceNotes");
            isUsing = !isUsing;
            guidanceNotes.requirement = function(){
                return switch(PlayState.storyDifficulty){
                    case 0: game.ratingPercent < 0.90;
                    case 2: game.health <= 0.5 && game.ratingPercent < 0.85 && game.songMisses >= 20;
                    case 3: false;

                    case 1: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                    default: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                    
                }
            }
            guidanceNotes.randomRequirement = function(){
                return switch(PlayState.storyDifficulty){
                    case 0: FlxG.random.bool(50 * ((2.0 - game.health) / 2));
                    case 2: FlxG.random.bool(20 * ((2.0 - game.health) / 2));
                    case 3: false;
                    
                    case 1: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
                    default: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
                }
            }
            songStopAnimation(true);
        } else {
            cannotUse();
        }
    }

    override function onStoryUse(){
        cannotUse();
    }

    function songUseAnimation() {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        FlxTween.tween(itemSprite, {"scale.x": 0.1625, "scale.y": 0.1625}, 0.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.color(durabilityBar.barForeground, 0.5, 0xFFFEDEBF, 0xFFFF0000, {ease: FlxEase.cubeOut, type: PINGPONG});
    }

    function songStopAnimation(?shouldBreak:Bool = false) {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        if(shouldBreak) {
            DoorsUtil.curRun.curInventory.removeItem(itemData);
            FlxTween.tween(boxSprite, {alpha: 0}, 0.5, {ease: FlxEase.sineOut, onComplete:function(twn){
                useCommon();
            }});
            FlxTween.tween(itemSprite, {"scale.x": 0.001, "scale.y": 0.001, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(durabilityBar, {x: FlxG.width - durabilityBar.width, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
        } else {
            FlxTween.tween(itemSprite, {"scale.x": 0.125, "scale.y": 0.125}, 0.5, {ease: FlxEase.sineInOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFEDEBF, {ease: FlxEase.cubeOut});
        }
    }
}