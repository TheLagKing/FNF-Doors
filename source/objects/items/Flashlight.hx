package objects.items;

import states.storymechanics.Screech;
import states.mechanics.ScreechMechanic;
import openfl.Assets;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import flixel.math.FlxRandom;

class Flashlight extends Item {
    private var isUsing:Bool = false;
    private final maxDurability:Float = 60.0;
    private var flashlightLight:FlxSprite;
    private var copies:Map<String, Dynamic>;
    private var isBroken:Bool = false;
    
    override function create() {
        this.itemData = {
            itemID: "flashlight",
            displayName: lp("flashlight")[0],
            displayDesc: lp("flashlight")[1],
            isPlural: lp("flashlight")[2],
            itemCoinPrice: 200,
            itemKnobPrice: 30,
            itemSlot: -1,
            durabilityRemaining: 45,
            maxDurability: 45,
            statesAllowed: ["story", "play"]
        }
    }    

    override function preload() {
        var theMap:Map<String, Array<String>> = [
            "images" => ["flashlight"],
            "sounds" => ["FlashlightOpen", "FlashlightClose"],
            "music" => []
        ];

        return theMap;
    }

    override function update(elapsed:Float) {
        updateLightPosition(elapsed);
        
        if(this.isUsing) {
            this.itemData.durabilityRemaining -= elapsed/2;
            checkDurability();
        }

        super.update(elapsed);
    }
    
    private function updateLightPosition(elapsed:Float) {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 8, 0, 1);
        if (!isUsing) return;
        
        var mouseX = FlxG.mouse.getPosition().x;
        var mouseY = FlxG.mouse.getPosition().y;
        
        if (!onPlayState && StoryMenuState.instance.isDark) {
            updateBigDarknessPosition(mouseX, mouseY, lerpVal);
        } else {
            updateFlashlightPosition(mouseX, mouseY, lerpVal);
        }
    }
    
    private function updateBigDarknessPosition(mouseX:Float, mouseY:Float, lerpVal:Float) {
        StoryMenuState.instance.bigDarkness.setPosition(
            FlxMath.lerp(
                StoryMenuState.instance.bigDarkness.x, 
                mouseX - (StoryMenuState.instance.bigDarkness.width/2), 
                lerpVal
            ), 
            FlxMath.lerp(
                StoryMenuState.instance.bigDarkness.y, 
                mouseY - (StoryMenuState.instance.bigDarkness.height/2), 
                lerpVal
            )
        );
    }
    
    private function updateFlashlightPosition(mouseX:Float, mouseY:Float, lerpVal:Float) {
        flashlightLight.setPosition(
            FlxMath.lerp(
                flashlightLight.x, 
                mouseX - (flashlightLight.width/2), 
                lerpVal
            ), 
            FlxMath.lerp(
                flashlightLight.y, 
                mouseY - (flashlightLight.height/2), 
                lerpVal
            )
        );
    }
    
    private function checkDurability() {
        if (this.itemData.durabilityRemaining <= 0 && !isBroken) {
            isBroken = true;
            if (Std.isOfType(game, StoryMenuState)) {
                onStoryBreak();
            } else if (Std.isOfType(game, PlayState)) {
                onSongBreak();
            }
        }

        if(this.itemData.durabilityRemaining >= this.itemData.maxDurability){
            this.itemData.durabilityRemaining = this.itemData.maxDurability;
        }
    }

    override function onSongUse() { 
        if (!PlayState.instance.activeMechanics.exists("states.mechanics.ScreechMechanic")) {
            cannotUse();
            return;
        }
        
        var screechMechanic:ScreechMechanic = cast PlayState.instance.activeMechanics.get("states.mechanics.ScreechMechanic");
        isUsing = !isUsing;
        AwardsManager.fuckScreech = true;
        
        if (isUsing) {
            turnOnFlashlightInPlayState(screechMechanic);
        } else {
            turnOffFlashlightInPlayState(screechMechanic);
        }
    }
    
    private function turnOnFlashlightInPlayState(screechMechanic:ScreechMechanic) {
        screechMechanic.onLight();

        if (flashlightLight == null) {
            flashlightLight = new FlxSprite(0, 0).loadGraphic(Paths.image(("flashlight")));
            flashlightLight.blend = ADD;
            flashlightLight.alpha = 0;
        }
        
        FlxTween.cancelTweensOf(flashlightLight);
        if (!PlayState.instance.members.contains(flashlightLight)) 
            PlayState.instance.add(flashlightLight);
            
        FlxTween.tween(flashlightLight, {alpha: 0.2}, 0.5, {ease: FlxEase.expoOut});
        songUseAnimation();
    }
    
    private function turnOffFlashlightInPlayState(screechMechanic:ScreechMechanic) {
        screechMechanic.onDark();
        
        FlxTween.cancelTweensOf(flashlightLight);
        MenuSongManager.playSound('FlashlightClose', 1.0);
        
        FlxTween.tween(flashlightLight, {alpha: 0}, 0.5, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn) {
                PlayState.instance.remove(flashlightLight);
            }
        });
        
        songStopAnimation(false);
    }

    private function onSongBreak() {
        if (!PlayState.instance.activeMechanics.exists("states.mechanics.ScreechMechanic")) return;
        
        var screechMechanic:ScreechMechanic = cast PlayState.instance.activeMechanics.get("states.mechanics.ScreechMechanic");
        screechMechanic.onDark();
            
        FlxTween.cancelTweensOf(flashlightLight);
        MenuSongManager.playSound('FlashlightClose', 1.0);
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        
        FlxTween.tween(flashlightLight, {alpha: 0}, 0.5, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn) {
                PlayState.instance.remove(flashlightLight);
                useCommon();
            }
        });
        
        songStopAnimation(true);
    }

    private function onStoryBreak() {
        MenuSongManager.playSound('LighterClose', 1.0);
        
        if (StoryMenuState.instance.isDark) {
            handleStoryBreakInDarkness();
        } else {
            handleStoryBreakInLight();
        }
        
        storyStopAnimation(true);
    }
    
    private function handleStoryBreakInDarkness() {
        if (StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onDark();
        }

        StoryMenuState.instance.bigDarkness.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
        StoryMenuState.instance.bigDarkness.screenCenter();

        restoreEntityDarkState();

        FlxTween.tween(StoryMenuState.instance.guidedLightDoor, {alpha: 1}, FlxG.random.float(1.0, 2.0), {ease: FlxEase.circOut});
        FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.6}, FlxG.random.float(1.0, 2.0), {
            ease: FlxEase.circOut, 
            onComplete: function(twn) {
                FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.4}, 2.0, {ease: FlxEase.quadInOut, type: PINGPONG});
            }
        });
    }
    
    private function handleStoryBreakInLight() {
        if (flashlightLight == null) return;

        FlxTween.cancelTweensOf(flashlightLight);
        MenuSongManager.playSound('FlashlightClose', 1.0);
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        
        FlxTween.tween(flashlightLight, {alpha: 0}, 0.5, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn) {
                StoryMenuState.instance.remove(flashlightLight);
                useCommon();
            }
        });
    }

    override function onStoryUse() {
        if (copies == null) {
            copies = new Map<String, Dynamic>();
        }

        isUsing = !isUsing;
        AwardsManager.fuckScreech = true;
        
        if (isUsing) {
            openFlashlightInStory();
        } else {
            closeFlashlightInStory();
        }
    }
    
    private function openFlashlightInStory() {
        MenuSongManager.playSound('FlashlightOpen', 1.0);

        if (StoryMenuState.instance.isDark) {
            openFlashlightInStoryDarkness();
        } else {
            openFlashlightInStoryLight();
        }
        
        storyUseAnimation();
    }
    
    private function openFlashlightInStoryDarkness() {
        if (StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onLight();
        }

        flashlightLight = new FlxSprite(0, 0).loadGraphic(Assets.getBitmapData(Paths.getPreloadPath("images/flashlight.png")));

        FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLightDoor);
        FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLight);

        StoryMenuState.instance.guidedLightDoor.alpha = 0;
        StoryMenuState.instance.guidedLight.alpha = 0;

        saveAndResetEntityDarkState();

        CoolUtil.invertedAlphaMaskFlxSprite(
            StoryMenuState.instance.bigDarkness, flashlightLight, StoryMenuState.instance.bigDarkness, 255
        );
    }
    
    private function openFlashlightInStoryLight() {
        if (flashlightLight == null) {
            flashlightLight = new FlxSprite(0, 0).loadGraphic(Paths.image(("flashlight")));
            flashlightLight.blend = ADD;
            flashlightLight.alpha = 0;
        }
        
        FlxTween.cancelTweensOf(flashlightLight);
        
        if (!StoryMenuState.instance.members.contains(flashlightLight)) 
            StoryMenuState.instance.add(flashlightLight);
            
        FlxTween.tween(flashlightLight, {alpha: 0.2}, 0.5, {ease: FlxEase.expoOut});
    }
    
    private function closeFlashlightInStory() {
        MenuSongManager.playSound('FlashlightClose', 1.0);

        if (StoryMenuState.instance.isDark) {
            closeFlashlightInStoryDarkness();
        } else {
            closeFlashlightInStoryLight();
        }
        
        storyStopAnimation(false);
    }
    
    private function closeFlashlightInStoryDarkness() {
        if (StoryMenuState.instance.activeEntities.exists("states.storymechanics.Screech")) {
            var screechMechanic:Screech = cast StoryMenuState.instance.activeEntities.get("states.storymechanics.Screech");
            screechMechanic.onDark();
        }

        StoryMenuState.instance.bigDarkness.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
        StoryMenuState.instance.bigDarkness.screenCenter();

        restoreEntityDarkState();

        FlxTween.tween(StoryMenuState.instance.guidedLightDoor, {alpha: 1}, FlxG.random.float(1.0, 2.0), {ease: FlxEase.circOut});
        FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.6}, FlxG.random.float(1.0, 2.0), {
            ease: FlxEase.circOut, 
            onComplete: function(twn) {
                FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.4}, 2.0, {ease: FlxEase.quadInOut, type: PINGPONG});
            }
        });
    }
    
    private function closeFlashlightInStoryLight() {
        FlxTween.cancelTweensOf(flashlightLight);
        FlxTween.tween(flashlightLight, {alpha: 0}, 0.5, {
            ease: FlxEase.expoOut, 
            onComplete: function(twn) {
                StoryMenuState.instance.remove(flashlightLight);
            }
        });
    }
    
    private function saveAndResetEntityDarkState() {
        saveDoorDarkState();
        saveFurnitureDarkState();
    }
    
    private function saveDoorDarkState() {
        for (i in 0...StoryMenuState.instance.doors.length) {
            if (copies.exists("doors")) {
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
    
    private function saveFurnitureDarkState() {
        for (i in 0...StoryMenuState.instance.furniture.length) {
            if (copies.exists("furniture")) {
                var tmp = copies.get("furniture");
                tmp.push(StoryMenuState.instance.furniture[i].isDarkBlocked);
                copies.set("furniture", tmp);
            } else {
                copies.set("furniture", [StoryMenuState.instance.furniture[i].isDarkBlocked]);
            }
            StoryMenuState.instance.furniture[i].isDarkBlocked = false;
        }
    }
    
    private function restoreEntityDarkState() {
        if (copies == null) return;
        
        restoreDoorDarkState();
        restoreFurnitureDarkState();
    }
    
    private function restoreDoorDarkState() {
        if (!copies.exists("doors")) return;
        
        for (i in 0...StoryMenuState.instance.doors.length) {
            var tmp = copies.get("doors");
            StoryMenuState.instance.doors[i].isDarkBlocked = tmp[i];
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
    
    private function restoreFurnitureDarkState() {
        if (!copies.exists("furniture")) return;
        
        for (i in 0...StoryMenuState.instance.furniture.length) {
            var tmp = copies.get("furniture");
            StoryMenuState.instance.furniture[i].isDarkBlocked = tmp[i];
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

        if (shouldBreak) {
            DoorsUtil.curRun.curInventory.removeItem(itemData);
            FlxTween.tween(boxSprite, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(itemSprite, {"scale.x": 0.001, "scale.y": 0.001, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.tween(durabilityBar, {x: -durabilityBar.width, alpha: 0}, 0.5, {ease: FlxEase.sineOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFF0000, {ease: FlxEase.cubeOut});
        } else {
            FlxTween.tween(itemSprite, {"scale.x": 0.125, "scale.y": 0.125}, 0.5, {ease: FlxEase.sineInOut});
            FlxTween.color(durabilityBar.barForeground, 0.5, durabilityBar.barForeground.color, 0xFFFEDEBF, {ease: FlxEase.cubeOut});
        }
    }
}