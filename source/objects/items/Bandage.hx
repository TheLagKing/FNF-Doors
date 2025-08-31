package objects.items;

import flixel.math.FlxRandom;

class Bandage extends Item{
    override function create(){
        this.itemData = {
            itemID: "bandages",
            displayName: lp("bandages")[0],
            displayDesc: lp("bandages")[1],
            isPlural: lp("bandages")[2],
            itemCoinPrice: 75,
            itemKnobPrice: 10,
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: ["story", "play"]
        }
    }

    override function update(elapsed:Float){
        if(stickOnBar) {
            itemSprite.y = FlxMath.lerp(itemSprite.y, (PlayState.instance.healthBar.y + PlayState.instance.healthBar.height/2 - itemSprite.height/2), CoolUtil.boundTo(elapsed*4, 0, 1));
        }
        super.update(elapsed);
    }

    var previousHealth:Float = 2.0;
    var stickOnBar:Bool = false;
    override function onSongUse() { 
        if(!active) return;
        PlayState.instance.healthBar.updateBar();
        active = false;
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        PlayState.healthGain *= 0.2;
        PlayState.healthLoss *= 0.2;

        FlxTween.quadMotion(itemSprite, 
            itemSprite.x, 
            itemSprite.y, 
            PlayState.instance.healthBar.x + ((FlxMath.remapToRange(PlayState.instance.health, 0, 2, 100, 0) * 0.01) * PlayState.instance.healthBar.width), 
            itemSprite.y, 
            PlayState.instance.healthBar.x + ((FlxMath.remapToRange(PlayState.instance.health, 0, 2, 100, 0) * 0.01) * PlayState.instance.healthBar.width), 
            (PlayState.instance.healthBar.y + PlayState.instance.healthBar.height/2 - itemSprite.height/2),
            Conductor.crochet / 1000 * 4,
            true,
            {ease: FlxEase.quadInOut, onStart: function(twn){
                stickOnBar = true; 
            }, onUpdate: function(twn) {
                itemSprite.y = FlxMath.lerp(itemSprite.y, (PlayState.instance.healthBar.y + PlayState.instance.healthBar.height/2 - itemSprite.height/2), 0.0167);
            }, onComplete: function(twn){
                FlxTween.tween(itemSprite, {alpha: 0}, Conductor.crochet / 1000 * 4, {startDelay: 5.0, ease: FlxEase.cubeInOut, onComplete: function(_){
                    stickOnBar = false;
                    useCommon();
                    PlayState.healthGain *= 5;
                    PlayState.healthLoss *= 5;
                }});
            }}
        );
        FlxTween.tween(itemSprite, {"scale.x": 0.25, "scale.y": 0.25}, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut, onComplete: function(twn){
            FlxTween.tween(itemSprite, {"scale.x": 0.125, "scale.y": 0.125}, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut});
        }});
        FlxTween.tween(boxSprite, {alpha: 0}, Conductor.crochet / 1000 * 4, {ease: FlxEase.cubeInOut});
    }
    
    override function onStoryUse() { 
        if(!active) return;
        trace(DoorsUtil.curRun.runDiff);

        if(DoorsUtil.curRun.runDiff.toLowerCase() == "easy" || DoorsUtil.curRun.runDiff.toLowerCase() == "normal"){
            DoorsUtil.addStoryHealth(FlxG.random.float(0.5, 1.0));
        }
        if(DoorsUtil.curRun.runDiff.toLowerCase() == "hard"){
            DoorsUtil.addStoryHealth(FlxG.random.float(0.3, 0.7));
        }
        if(DoorsUtil.curRun.runDiff.toLowerCase() == "hell"){
            DoorsUtil.addStoryHealth(FlxG.random.float(0.1, 0.4));
        }
        StoryMenuState.instance.healthBar.updateBar();
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        super.onStoryUse();
    }
}