package objects.items;

import openfl.display.BlendMode;
import flixel.math.FlxRandom;

class Vitamins extends Item{
    override function create(){
        this.itemData = {
            itemID: "vitamins",
            displayName: lp("vitamins")[0],
            displayDesc: lp("vitamins")[1],
            isPlural: lp("vitamins")[2],
            itemCoinPrice: 100,
            itemKnobPrice: 15,
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: ["play"]
        }
    }

    override function onSongUse() { 
        var currentHG = PlayState.healthGain;
        if(DoorsUtil.curRun.runDiff == "Easy" || DoorsUtil.curRun.runDiff == "Normal"){
            PlayState.healthGain *= 4;
        }
        if(DoorsUtil.curRun.runDiff == "Hard"){
            PlayState.healthGain *= 3;
        }
        if(DoorsUtil.curRun.runDiff == "Hell"){
            PlayState.healthGain *= 2;
        }
        FlxG.sound.play(Paths.sound('vitamins'));

        PlayState.instance.vitaVignette = new FlxSprite(0,0).loadGraphic(Paths.image('storyItems/white_vignette'));
        PlayState.instance.vitaVignette.alpha = 0;
        PlayState.instance.vitaVignette.cameras = [PlayState.instance.camHUD];
        PlayState.instance.add(PlayState.instance.vitaVignette);
        FlxTween.tween(PlayState.instance.vitaVignette, {alpha:0.3}, Conductor.crochet / 1000 * 4, {ease: FlxEase.cubeOut});
        PlayState.instance.vitaVignette.color = 0xFF91FF00;

        new FlxTimer().start(15, function(tmr){
            PlayState.healthGain = currentHG;
            FlxTween.tween(PlayState.instance.vitaVignette, {alpha:0}, 0.6);
        });

        active = false;
        DoorsUtil.curRun.curInventory.removeItem(itemData);

        FlxTween.tween(itemSprite, {alpha: 0, x: itemSprite.x + FlxG.width/4}, Conductor.crochet / 1000 * 4, {ease: FlxEase.cubeInOut, onComplete: function(_){
            useCommon();
        }});
        FlxTween.tween(boxSprite, {alpha: 0}, Conductor.crochet / 1000 * 4, {ease: FlxEase.cubeInOut});
    }

    override function onStoryUse(){
        StoryMenuState.instance.updateDescription(Lang.getText("storyVitamins", "items/messages"));
        cannotUse();
    }
}