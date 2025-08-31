package objects.items;

import states.storymechanics.Screech;
import states.mechanics.ScreechMechanic;
import openfl.Assets;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import flixel.math.FlxRandom;

class Lighter extends Item{
    private var isUsing:Bool = false;
    private final maxDurability:Float = 30.0;
    private var lighterLight:FlxSprite;
    private var lighterGlow:FlxSprite;
    private var copies:Map<String, Dynamic>;
    private var isBroken:Bool = false;

    override function create(){
        this.itemData = {
            itemID: "lighter",
            displayName: lp("lighter")[0],
            displayDesc: lp("lighter")[1],
            isPlural: lp("lighter")[2],
            itemCoinPrice: 100,
            itemKnobPrice: 15,
            itemSlot: -1,
            durabilityRemaining: 30,
            maxDurability: 30,
            statesAllowed: ["story", "play"]
        }
    }

    override function preload(){
        var theMap:Map<String, Array<String>> = [
            "images" => ["lighterGlow"],
            "sounds" => ["LighterOpen", "LighterClose"],
            "music" => []
        ];

        return theMap;
    }

    override function update(elapsed:Float){
        if(this.isUsing){
            this.itemData.durabilityRemaining -= elapsed;
            checkDurability();
        }
        
        super.update(elapsed);
    }
    
    private function checkDurability() {
        if(this.itemData.durabilityRemaining <= 0 && !isBroken){
            isBroken = true;
            if(Std.isOfType(game, StoryMenuState)){
                onStoryBreak();
            } else if (Std.isOfType(game, PlayState)) {
                onSongBreak();
            }
            DoorsUtil.curRun.curInventory.removeItem(itemData);
        }

        if(this.itemData.durabilityRemaining >= this.itemData.maxDurability){
            this.itemData.durabilityRemaining = this.itemData.maxDurability;
        }
    }

    override function onSongUse() { 
        if(!PlayState.instance.activeMechanics.exists("states.mechanics.ScreechMechanic")){
            cannotUse();
            return;
        }
        
        var screechMechanic:ScreechMechanic = cast PlayState.instance.activeMechanics.get("states.mechanics.ScreechMechanic");
        isUsing = !isUsing;
        AwardsManager.fuckScreech = true;
        
        if(isUsing){
            turnOnLighterInPlayState(screechMechanic);
        } else {
            turnOffLighterInPlayState(screechMechanic);
        }
    }
    
    private function turnOnLighterInPlayState(screechMechanic:ScreechMechanic) {
        screechMechanic.onLight();
        
        if(lighterGlow == null) {
            lighterGlow = new FlxSprite(0, 0).loadGraphic(Paths.image(("lighterGlow")));
            lighterGlow.blend = ADD;
            lighterGlow.alpha = 0;
            lighterGlow.screenCenter();
            lighterGlow.x += 400;
            lighterGlow.y += 200;
        }
        
        FlxTween.cancelTweensOf(lighterGlow);
        if(!PlayState.instance.members.contains(lighterGlow)) 
            PlayState.instance.add(lighterGlow);
            
        FlxTween.tween(lighterGlow, {alpha: 0.2}, 1.5, {ease: FlxEase.expoOut});
        songUseAnimation();
    }
    
    private function turnOffLighterInPlayState(screechMechanic:ScreechMechanic) {
        screechMechanic.onDark();
        
        FlxTween.cancelTweensOf(lighterGlow);
        FlxTween.tween(lighterGlow, {alpha: 0}, 0.4, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn){
                PlayState.instance.remove(lighterGlow);
            }
        });
        
        songStopAnimation(false);
    }

    private function onSongBreak(){
        if(!PlayState.instance.activeMechanics.exists("states.mechanics.ScreechMechanic")) return;
        
        var screechMechanic:ScreechMechanic = cast PlayState.instance.activeMechanics.get("states.mechanics.ScreechMechanic");
        screechMechanic.onDark();
            
        FlxTween.cancelTweensOf(lighterGlow);
        FlxTween.tween(lighterGlow, {alpha: 0}, 0.4, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn){
                PlayState.instance.remove(lighterGlow);
            }
        });

        songStopAnimation(true);
    }

    private function onStoryBreak(){
        MenuSongManager.playSound('LighterClose', 1.0);
        
        if(StoryMenuState.instance.isDark){
            handleStoryBreakInDarkness();
        } else {
            handleStoryBreakInLight();
        }

        storyStopAnimation(true);
    }
    
    private function handleStoryBreakInDarkness() {
        if(StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onDark();
        }
        
        StoryMenuState.instance.bigDarkness.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
        StoryMenuState.instance.bigDarkness.screenCenter();
        StoryMenuState.instance.remove(lighterGlow);
        
        restoreEntityDarkState();
    }
    
    private function handleStoryBreakInLight() {
        FlxTween.cancelTweensOf(lighterGlow);
        FlxTween.tween(lighterGlow, {alpha: 0}, 0.4, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn){
                StoryMenuState.instance.remove(lighterGlow);
            }
        });
    }

    override function onStoryUse(){
        if(copies == null){
            copies = new Map<String, Dynamic>();
        }

        isUsing = !isUsing;
        
        if(isUsing){
            StoryMenuState.instance.useLight();
            openLighterInStory();
        } else {
            closeLighterInStory();
        }
    }
    
    private function openLighterInStory() {
        MenuSongManager.playSound('LighterOpen', 1.0);

        if(StoryMenuState.instance.isDark){
            openLighterInStoryDarkness();
        } else {
            openLighterInStoryLight();
        }

        storyUseAnimation();
    }
    
    private function openLighterInStoryDarkness() {
        if(StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onLight();
        }

        lighterLight = new FlxSprite(0, 0).loadGraphic(Assets.getBitmapData(Paths.getPreloadPath("images/lighter.png")));
        lighterGlow = new FlxSprite(0, 0).loadGraphic(Paths.image("lighterGlow"));
        lighterGlow.alpha = 0.3;
        
        StoryMenuState.instance.bigDarkness.screenCenter();
        StoryMenuState.instance.bigDarkness.x += 400;
        StoryMenuState.instance.bigDarkness.y += 200;

        lighterLight.screenCenter();
        lighterGlow.screenCenter();
        lighterGlow.x += 400;
        lighterGlow.y += 200;
        
        FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLightDoor);
        FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLight);

        StoryMenuState.instance.guidedLightDoor.alpha = 0;
        StoryMenuState.instance.guidedLight.alpha = 0;

        saveDoorDarkState();

        CoolUtil.invertedAlphaMaskFlxSprite(
            StoryMenuState.instance.bigDarkness, lighterLight, StoryMenuState.instance.bigDarkness, 255
        );

        StoryMenuState.instance.insert(
            StoryMenuState.instance.members.indexOf(StoryMenuState.instance.bigDarkness), 
            lighterGlow
        );
    }
    
    private function openLighterInStoryLight() {
        if(lighterGlow == null) {
            lighterGlow = new FlxSprite(0, 0).loadGraphic(Paths.image(("lighterGlow")));
            lighterGlow.blend = ADD;
            lighterGlow.alpha = 0;
            lighterGlow.screenCenter();
            lighterGlow.x += 400;
            lighterGlow.y += 200;
        }
        
        FlxTween.cancelTweensOf(lighterGlow);
        if(!StoryMenuState.instance.members.contains(lighterGlow)) 
            StoryMenuState.instance.add(lighterGlow);
            
        FlxTween.tween(lighterGlow, {alpha: 0.2}, 1.5, {ease: FlxEase.expoOut});
    }
    
    private function closeLighterInStory() {
        MenuSongManager.playSound('LighterClose', 1.0);
        
        if(StoryMenuState.instance.isDark){
            closeLighterInStoryDarkness();
        } else {
            closeLighterInStoryLight();
        }

        storyStopAnimation(false);
    }
    
    private function closeLighterInStoryDarkness() {
        if(StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onDark();
        }
        
        StoryMenuState.instance.bigDarkness.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
        StoryMenuState.instance.bigDarkness.screenCenter();
        StoryMenuState.instance.remove(lighterGlow);
        
        restoreEntityDarkState();
    }
    
    private function closeLighterInStoryLight() {
        FlxTween.cancelTweensOf(lighterGlow);
        FlxTween.tween(lighterGlow, {alpha: 0}, 0.4, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn){
                StoryMenuState.instance.remove(lighterGlow);
            }
        });
    }
    
    private function saveDoorDarkState() {
        for(i in 0...StoryMenuState.instance.doors.length){
            if(copies.exists("doors")){
                var tmp = copies.get("doors");
                tmp.push(StoryMenuState.instance.doors[i].isDarkBlocked);
                copies.set("doors", tmp);
            } else {
                copies.set("doors", [StoryMenuState.instance.doors[i].isDarkBlocked]);
            }

            StoryMenuState.instance.doors[i].isDarkBlocked = false;
        }

        if(StoryMenuState.instance.roomObject != null && Std.isOfType(StoryMenuState.instance.roomObject, states.storyrooms.roomTypes.Normal)) {
            var roomObject:states.storyrooms.roomTypes.Normal = cast StoryMenuState.instance.roomObject;
            if(roomObject.softDoorsLocked == null) return;
            for (i in 0...roomObject.softDoorsLocked.length) {
                if (copies.exists("softdoors")) {
                    var tmp = copies.get("softdoors");
                    tmp.push(roomObject.softDoorsLocked[i]);
                    copies.set("softdoors", tmp);
                } else {
                    copies.set("softdoors", [roomObject.softDoorsLocked[i]]);
                }
                roomObject.softDoorsLocked[i] = false;
            }
        }
    }
    
    private function restoreEntityDarkState() {
        if(copies == null) return;
        
        if(copies.exists("doors")){
            for(i in 0...StoryMenuState.instance.doors.length){
                var tmp = copies.get("doors");
                StoryMenuState.instance.doors[i].isDarkBlocked = tmp[i];
            }
        }
        if(StoryMenuState.instance.roomObject != null && Std.isOfType(StoryMenuState.instance.roomObject, states.storyrooms.roomTypes.Normal)) {
            var roomObject:states.storyrooms.roomTypes.Normal = cast StoryMenuState.instance.roomObject;
            if(roomObject.softDoorsLocked == null) return;
            for (i in 0...roomObject.softDoorsLocked.length) {
                var tmp = copies.get("softdoors");
                roomObject.softDoorsLocked = tmp[i];
            }
        }
    }

    private function storyUseAnimation() {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        FlxTween.tween(itemSprite, {"scale.x": 0.1625, "scale.y": 0.1625}, 0.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.color(durabilityBar.barForeground, 0.5, 0xFFFEDEBF, 0xFFFF0000, {ease: FlxEase.cubeOut});
    }

    private function storyStopAnimation(?shouldBreak:Bool = false) {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        if (shouldBreak) {
            DoorsUtil.curRun.curInventory.removeItem(itemData);
            FlxTween.tween(boxSprite, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(itemSprite, {"scale.x": 0.001, "scale.y": 0.001, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(durabilityBar, {y: FlxG.height + durabilityBar.height, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFF0000, {ease: FlxEase.cubeOut});
        } else {
            FlxTween.tween(itemSprite, {"scale.x": 0.125, "scale.y": 0.125}, 0.5, {ease: FlxEase.sineInOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFEDEBF, {ease: FlxEase.cubeOut});
        }
    }

    private function songUseAnimation() {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        FlxTween.tween(itemSprite, {"scale.x": 0.1625, "scale.y": 0.1625}, 0.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.color(durabilityBar.barForeground, 0.5, 0xFFFEDEBF, 0xFFFF0000, {ease: FlxEase.cubeOut});
    }

    private function songStopAnimation(?shouldBreak:Bool = false) {
        FlxTween.cancelTweensOf(boxSprite);
        FlxTween.cancelTweensOf(itemSprite);
        FlxTween.cancelTweensOf(durabilityBar);
        FlxTween.cancelTweensOf(durabilityBar.barForeground);

        if(shouldBreak) {
            DoorsUtil.curRun.curInventory.removeItem(itemData);
            FlxTween.tween(boxSprite, {alpha: 0}, 0.5, {
                ease: FlxEase.sineOut, 
                onComplete: function(twn){
                    useCommon();
                }
            });
            FlxTween.tween(itemSprite, {"scale.x": 0.001, "scale.y": 0.001, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(durabilityBar, {x: -durabilityBar.width, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFF0000, {ease: FlxEase.cubeOut});
        } else {
            FlxTween.tween(itemSprite, {"scale.x": 0.125, "scale.y": 0.125}, 0.5, {
                ease: FlxEase.sineInOut
            });
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFEDEBF, {ease: FlxEase.cubeOut});
        }
    }
}