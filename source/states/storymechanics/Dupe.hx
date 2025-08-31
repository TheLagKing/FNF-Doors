package states.storymechanics;

import flxanimate.FlxAnimate;
import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

class Dupe extends BaseSMMechanic {
    // Constants
    private static inline final JUMPSCARE_SCALE:Float = 0.6;
    private static inline final JUMPSCARE_DAMAGE:Float = 0.4;
    
    // Visual elements
    private var dupeBlack:FlxSprite;
    private var dupeSprite:FlxAnimate;
    private var dupeFrontBlack:FlxSprite;
    
    private var assignedDoor:String = "l"; // 'l' for left, 'r' for right

    private var hasTriggeredDupe:Bool = false;

    override function createPost() { 
        hasTriggeredDupe = false;
        initializeOverlays();
        initializeDupeSprite();
        assignTargetDoor();
    }
    
    private function initializeOverlays():Void {
        dupeBlack = new FlxSprite().makeSolid(FlxG.width+5, FlxG.height+5, FlxColor.BLACK);
        dupeBlack.alpha = 0.00001;
        dupeBlack.cameras = [camHUD];
        add(dupeBlack);

        dupeFrontBlack = new FlxSprite().makeSolid(FlxG.width+5, FlxG.height+5, FlxColor.BLACK);
        dupeFrontBlack.alpha = 0.00001;
        dupeFrontBlack.cameras = [camHUD];
        add(dupeFrontBlack);
    }
    
    private function initializeDupeSprite():Void {
        dupeSprite = new FlxAnimate();
        dupeSprite.showPivot = false;

        try {
            Paths.loadAnimateAtlas(dupeSprite, "story_mode_backgrounds/entities/Dupe");
        } catch(e:Dynamic) {
            FlxG.log.warn('Could not load atlas "story_mode_backgrounds/entities/Dupe": $e');
        }

        dupeSprite.anim.addBySymbol("jumpscare", "Jumpscare", 24, false);
        dupeSprite.anim.play("jumpscare");
        dupeSprite.antialiasing = ClientPrefs.globalAntialiasing;
        dupeSprite.alpha = 0.0001;
        dupeSprite.cameras = [camHUD];
        dupeSprite.scale.set(JUMPSCARE_SCALE, JUMPSCARE_SCALE);
        dupeSprite.updateHitbox();
        dupeSprite.setPosition(730, 360);
        add(dupeSprite);
    }
    
    private function assignTargetDoor():Void {
        if(game.room.leftDoor.doorNumber <= door) assignedDoor = "l";
        if(game.room.rightDoor.doorNumber <= door) assignedDoor = "r";
    }
    
    override function onDoorOpen(selectedDoor:DoorAttributes) { 
        if(selectedDoor.side.substr(0, 1) == assignedDoor) {
            if(!hasTriggeredDupe && !selectedDoor.isLocked) {
                triggerJumpscare(selectedDoor);
            } else {
                StoryMenuState.instance.updateDescription(Lang.getText("entityClosed", "story/interactions"));
            }
        }
    }
    
    private function triggerJumpscare(selectedDoor:DoorAttributes):Void {
        disableGameControls();
        zoomInToDoor(selectedDoor);
        
        new FlxTimer().start(2.3, function(tmr) {
            showJumpscareAnimation();
            
            dupeSprite.anim.onComplete = function() {
                handleJumpscareCompletion(selectedDoor);
            };
        });
    }
    
    private function disableGameControls():Void {
        game.canAccessDoor = false;
        game.doUpdate = false;
        game.overrideCamFollow = true;
        game.freezeItem = true;
        camGame.fade(FlxColor.BLACK, 1.6, false);
        MenuSongManager.playSound("walking leaving", 1.0);
    }
    
    private function zoomInToDoor(door:DoorAttributes):Void {
        FlxTween.tween(game.camFollowPos, {
            x: door.doorSpr.getGraphicMidpoint().x, 
            y: door.doorSpr.getGraphicMidpoint().y
        }, 1.4, {ease: FlxEase.linear});
        
        FlxTween.tween(camGame, {zoom: 1.3}, 1.8);
    }
    
    private function showJumpscareAnimation():Void {
        camGame.fade(0xFF000000, 0.00001, false, true);
        dupeBlack.alpha = 1;
        dupeSprite.alpha = 1;
        dupeSprite.anim.play("jumpscare", true, false, 23);
        dupeSprite.scale.set(0.001, 0.001);
        dupeSprite.updateHitbox();
        
        MenuSongManager.playSound("dupeScare", 1.0);
        
        FlxTween.tween(dupeSprite, {"scale.x": JUMPSCARE_SCALE, "scale.y": JUMPSCARE_SCALE}, 0.12, {
            onUpdate: function(twn) {
                dupeSprite.updateHitbox();
            }
        });
        
        new FlxTimer().start(0.5, function(tmr) {
            MenuSongManager.playSound("bf_sounds/Hurt"+FlxG.random.int(1,2), 1.0);
            camHUD.flash(0xC9FF0000, 1.6, null, true);
            FlxTween.tween(dupeFrontBlack, {alpha: 1}, 0.4);
        });
    }
    
    private function handleJumpscareCompletion(selectedDoor:DoorAttributes):Void {
        applyDamage();
        
        if(DoorsUtil.curRun.latestHealth <= 0) {
            game.fuckingDie("SONG", "dupe", function(){
                DoorsUtil.curRun.revivesLeft += 1;
            });
        } else {
            recoverFromJumpscare(selectedDoor);
        }
        
        markDoorAsUsed(selectedDoor);
    }
    
    private function applyDamage():Void {
        DoorsUtil.curRun.latestHealth -= JUMPSCARE_DAMAGE * (1 + game.curDifficulty);
    }
    
    private function recoverFromJumpscare(selectedDoor:DoorAttributes):Void {
        hideJumpscareElements();
        restoreGameControls();
        panelFallOffAnimation(selectedDoor.panelGroup);
    }
    
    private function hideJumpscareElements():Void {
        dupeSprite.alpha = 0;
        camGame.fade(0xFF000000, 0.00001, true, true);
        
        FlxTween.cancelTweensOf(dupeBlack);
        FlxTween.cancelTweensOf(dupeFrontBlack);
        FlxTween.tween(dupeBlack, {alpha: 0}, 0.1, {ease: FlxEase.cubeInOut});
        FlxTween.tween(dupeFrontBlack, {alpha: 0}, 0.1, {ease: FlxEase.cubeInOut});
    }
    
    private function restoreGameControls():Void {
        game.canAccessDoor = true;
        game.doUpdate = true;
        game.overrideCamFollow = false;
        game.freezeItem = false;
        game.selectedWeek = false;
        FlxTween.tween(camGame, {zoom: 0.75}, 0.9, {ease: FlxEase.cubeInOut});
    }
    
    private function markDoorAsUsed(selectedDoor:DoorAttributes):Void {
        hasTriggeredDupe = true;
        var doorData = {
            doorNumber: selectedDoor.side == "left" ? game.room.leftDoor.doorNumber : game.room.rightDoor.doorNumber,
            side: selectedDoor.side,
            isLocked: true,
            song: "None",
            hasBeenOpenedOnce: 1
        };
        
        if(selectedDoor.side == "left") {
            game.room.leftDoor = doorData;
            selectedDoor = game.room.leftDoor;
        } else {
            game.room.rightDoor = doorData;
            selectedDoor = game.room.rightDoor;
        }
    }

    private function panelFallOffAnimation(grp:FlxSpriteGroup):Void {
        var xOffs = FlxG.random.int(-40, 40, [-3, -2, -1, 0, 1, 2, 3]);
        FlxTween.tween(grp, {y: 609}, 0.3, {ease: FlxEase.bounceOut});
        FlxTween.tween(grp, {x: grp.x + xOffs}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
        FlxTween.tween(grp, {angle: grp.angle - xOffs/4}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
    }
}