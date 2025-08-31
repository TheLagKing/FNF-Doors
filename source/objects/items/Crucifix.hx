package objects.items;

import flixel.sound.filters.FlxSoundFilterType;
import flixel.sound.filters.FlxSoundFilter;

class Crucifix extends Item{
    override function create(){
        this.itemData = {
            itemID: "crucifix",
            displayName: lp("crucifix")[0],
            displayDesc: lp("crucifix")[1],
            isPlural: lp("crucifix")[2],
            itemCoinPrice: 250,
            itemKnobPrice: 50,
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: ["story", "play"]
        }
    }

    override function onSongDeath() {
        if(!active) return;
        
        PlayState.healthLoss = 0;
        FlxTween.num(0, 1, Conductor.crochet / 1000 * 16, {startDelay: Conductor.crochet / 1000 * 16}, function(num){
            PlayState.healthLoss = num;
        });
        PlayState.instance.stopDeathEarly = true;
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        active = false;
        var healthTargetPercent:Float = 1;
        if([for (x in PlayState.instance.activeMechanics.keys()) x].contains("states.mechanics.HaltMechanic")){
            healthTargetPercent = 0.5;
        }

        FlxTween.tween(itemSprite, {
            x: FlxG.width / 2 - 27, 
            y: FlxG.height / 2 - 27,
            "scale.x": 0.5, 
            "scale.y": 0.5
        }, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut, onComplete: function(_){
            FlxTween.tween(itemSprite, {
                x: FlxG.width - 155, 
                y: PlayState.instance.theHealthBarAimedPosY + (PlayState.instance.healthBar.height / 2 - 110),
                "scale.x": 0.25, 
                "scale.y": 0.25
            }, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut, onComplete: function(_){
                PlayState.instance.camGame.flash(0x9CFFFFFF, Conductor.crochet / 1000 * 4, null, true);
                PlayState.instance.camHUD.flash(0x60FFFFFF, Conductor.crochet / 1000 * 4, null, true);
                FlxTween.tween(itemSprite, {
                    x: 0 - 55, 
                }, Conductor.crochet / 1000 * 4, {ease: FlxEase.backIn, onUpdate: function(twn) {
                    PlayState.instance.health = FlxMath.bound(FlxMath.remapToRange(itemSprite.x, 1280, 0, 0, healthTargetPercent) * DoorsUtil.maxHealth, 0.05, DoorsUtil.maxHealth);
                }, onComplete: function(_){
                    PlayState.instance.stopDeathEarly = false;
                    AwardsManager.crucifix = true;
                    useCommon();
                }});
            }});
        }});
        FlxTween.tween(boxSprite, {alpha: 0}, Conductor.crochet / 1000 * 8, {ease: FlxEase.cubeInOut});
    }

    override function onStoryDeath(){
        if(!active) return;

        active = false;
        StoryMenuState.instance.camGame.flash(0x9CFFFFFF, Conductor.crochet / 1000 * 4, null, true);
        StoryMenuState.instance.camHUD.flash(0x60FFFFFF, Conductor.crochet / 1000 * 4, null, true);
        FlxG.cameras.list[FlxG.cameras.list.length - 1].flash(0x60FFFFFF, Conductor.crochet / 1000 * 4, null, true);
        DoorsUtil.curRun.latestHealth = DoorsUtil.maxHealth;
        StoryMenuState.instance.stopDeathEarly = true;
        AwardsManager.crucifix = true;
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        useCommon();
    }
    

    override function onStoryUse(){
        cannotUse();
    }
    
    override function onSongUse(){
        cannotUse();
    }

    public function useCrucifix(){
        try{
            this.visible = false;
            this.active = false;
            DoorsUtil.curRun.curInventory.removeItem(itemData);
            this.kill();
        } catch(e){}
    }
}