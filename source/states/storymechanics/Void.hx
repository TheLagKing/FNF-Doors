package states.storymechanics;

import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

enum VoidState {
    WAITING;
    SPAWNED;
    KILLING;
}

class Void extends BaseSMMechanic {
    // void
    var voidSound:FlxSound;
    var theVoidStatic:FlxSprite;

    var voidDiff:Int = Math.floor(door / 10);
    var voidOffset:Float = 0;

    var timeUntilVoidSpawns:Float = 95;
    var timeUntilVoidKills:Float = 45;
    
    // State machine
    var currentState:VoidState = VoidState.WAITING;
    var stateTimer:Float = 0;

    override function create() { 
        theVoidStatic = new FlxSprite(0, 0);
        theVoidStatic.frames = Paths.getSparrowAtlas('seekBG/static', 'shared');
        theVoidStatic.animation.addByPrefix("idle", "static instance 1", 24, true);
        theVoidStatic.animation.play("idle");
        theVoidStatic.scale.set(1.5, 1.5);
        theVoidStatic.updateHitbox();
        theVoidStatic.alpha = 0.00001;
        add(theVoidStatic);

        if(game.bossState == "Greenhouse") {
            if(door < 94) voidOffset = 0;
            else if(door < 97) voidOffset = 12;
            else voidOffset = 24;
        }
        
        timeUntilVoidSpawns -= (voidDiff * 5 + 0.01);
        timeUntilVoidSpawns /= (DoorsUtil.modifierActive(32) ? 2: (DoorsUtil.modifierActive(31) ? 0.0001: 1));
        
        stateTimer = timeUntilVoidSpawns;
    }

    override function updatePost(elapsed:Float) {
        switch (currentState) {
            case WAITING:
                stateTimer -= elapsed;
                if (stateTimer <= 0) {
                    transitionState(VoidState.SPAWNED);
                }
                
            case SPAWNED:
                stateTimer -= elapsed;
                if (stateTimer <= 0) {
                    transitionState(VoidState.KILLING);
                }
                
            case KILLING:
                // Final state, no transitions
        }
    }
    
    private function transitionState(newState:VoidState) {
        // Exit actions for current state
        switch (currentState) {
            case WAITING:
                // No exit actions needed
            case SPAWNED:
                // No exit actions needed
            case KILLING:
                // No exit actions needed
        }
        
        // Update state
        currentState = newState;
        
        // Entry actions for new state
        switch (newState) {
            case WAITING:
                stateTimer = timeUntilVoidSpawns;
                
            case SPAWNED:
                voidSound = new FlxSound().loadEmbedded(Paths.sound("void"), false, false);
                voidSound.play(false, voidOffset*1000);
                voidSound.volume = 1.0;
                voidSound.persist = false;

                stateTimer = timeUntilVoidKills - voidOffset;

                FlxTween.tween(theVoidStatic, {alpha:0.25}, stateTimer, {ease: FlxEase.cubeIn});
                if(ClientPrefs.data.shaders) {
                    FlxTween.tween(game.vignetteShader, {extent: 35, darkness: 0.25}, stateTimer, {ease: FlxEase.circIn});
                }
                FlxTween.tween(camHUD, {alpha: 0.00001}, stateTimer);
                MenuSongManager.changeSongPitch(0.2, stateTimer);
                MenuSongManager.changeSongVolume(0.00001, stateTimer);
                
            case KILLING:
                game.fuckingDie("VOID", "void", function(){
                    DoorsUtil.curRun.revivesLeft += 1;
                });
                camHUD.alpha = 1;
        }
    }

    override function onFocus() {
        if(voidSound != null) voidSound.play();
    }

    override function onFocusLost() {
        if(voidSound != null) voidSound.stop();
    }

    override function changeState() {
        if(voidSound != null) voidSound.stop();
    }

    override function destroy() {
        if(voidSound != null) voidSound.stop();
        super.destroy();
    }
    
    override function onDoorOpen(selectedDoor:DoorAttributes) { 
        if(voidSound != null) voidSound.stop();
        super.onDoorOpen(selectedDoor);
    }
}