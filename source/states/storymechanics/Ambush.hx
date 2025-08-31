package states.storymechanics;

import states.storyrooms.roomTypes.Normal;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

enum AmbushState {
    WAITING;            // Before ambush appears
    SPAWNED;            // Ambush has spawned and is moving for the first time
    SPAWNED_AGAIN;      // Ambush has spawned and is moving for all other times
    RETREATING;         // Ambush is retreating
    SAFE;               // Player is safe from Ambush
    KILLING;            // Ambush is killing the player
}

class Ambush extends BaseSMMechanic {
    public var isInCloset:Bool = false;

    // A rebound is defined by ambush going forward then backwards.
    var numberOfRebounds:Int = 1;
    var maxRebounds:Int = 1;
    var currentState:AmbushState = WAITING;

    var timeUntilAmbushSpawns:Float = 5;
    var ambushSprite:FlxSprite;
    var ambushTrail:FlxTrail;

    var ambushFarSnd:FlxSound;
    var ambushNearSnd:FlxSound;
    var greenFilter:FlxSprite;
    var hasFlickered:Bool = false;
    var lerpVal = 1.0;

    override function createPost() { 
        numberOfRebounds = FlxG.random.int(1, 4);
        maxRebounds = numberOfRebounds;
        timeUntilAmbushSpawns = FlxG.random.float(4, 5);
        currentState = WAITING;

        // Preload assets
        Paths.image("entities/ambush/ambush");
        Paths.image("entities/ambush/particle");
        Paths.image("entities/ambush/ambushScare");
        Paths.sound("ambushScarePre");
        Paths.sound("ambushScareCharge");
        Paths.sound("ambushScareKill");
        
        // Setup sounds
        ambushFarSnd = new FlxSound();
        ambushFarSnd.loadEmbedded(Paths.sound("ambush/AmbushPlaySound"));
        ambushFarSnd.looped = true;
        ambushFarSnd.persist = false;
        ambushFarSnd.volume = 0.00001;
        ambushFarSnd.play();
        FlxG.sound.list.add(ambushFarSnd);
        
        ambushNearSnd = new FlxSound();
        ambushNearSnd.loadEmbedded(Paths.sound("ambush/AmbushFootsteps"));
        ambushNearSnd.looped = true;
        ambushNearSnd.persist = false;
        ambushNearSnd.volume = 0.00001;
        ambushNearSnd.play();
        FlxG.sound.list.add(ambushNearSnd);

        // Setup green filter
        greenFilter = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF00FF00);
        greenFilter.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        greenFilter.blend = ADD;
        greenFilter.alpha = 0.00001;
        add(greenFilter);

        StoryMenuState.instance.entityComing = true;

        MenuSongManager.changeSongPitch(0.8, 1);
        MenuSongManager.changeSongVolume(0.3, 1);
    }
    
    function spawnAmbush() {
        if (isInCloset) {
            ambushSprite = new FlxSprite().loadGraphic(Paths.image("entities/ambush/ambush"));
            ambushSprite.antialiasing = ClientPrefs.globalAntialiasing;
            ambushSprite.scale.set(0.8, 0.8);
            ambushSprite.y = 108;
            ambushSprite.color = 0xFFA5A5A5;

            ambushTrail = new FlxTrail(ambushSprite, Paths.image("entities/ambush/particle"), 180, 0, 1, 1/180);
            ambushTrail.offset.set(-100, -100);
            ambushTrail.visible = true;
            
            StoryMenuState.instance.insert(
                StoryMenuState.instance.members.indexOf(StoryMenuState.instance.closetForeground),
                ambushTrail
            );

            StoryMenuState.instance.insert(
                StoryMenuState.instance.members.indexOf(StoryMenuState.instance.closetForeground), 
                ambushSprite
            );

            ambushSprite.setPosition(10000, 0);
            ambushTrail.setPosition(10000, 0);
            ambushSprite.velocity.set(-15000, 0);
            ambushSprite.flipX = false;
            
            currentState = SPAWNED;
        } else {
            currentState = KILLING;
            triggerJumpscare();
        }
    }

    function triggerJumpscare() {
        if(ambushFarSnd != null) ambushFarSnd.stop();
        if(ambushNearSnd != null) ambushNearSnd.stop();
        StoryMenuState.instance.openSubState(new AmbushJumpscareSubState());
    }

    function handleRebounds() {
        if (numberOfRebounds > 0) {
            if (ambushSprite.velocity.x > 0) {
                // Ambush going right and off-screen - reset for next attack
                ambushSprite.setPosition(2000, 0);
                ambushTrail.setPosition(2000, 0);
                ambushSprite.velocity.set(0, 0);
                
                currentState = RETREATING;
                
                new FlxTimer().start(FlxG.random.float(4, 5), function(_) {
                    numberOfRebounds--;
                    if (numberOfRebounds > 0) {
                        spawnAmbush();
                        currentState = SPAWNED_AGAIN;
                    } else {
                        currentState = SAFE;
                        StoryMenuState.instance.entityComing = false;
                    }
                });
            } else {
                // Ambush going left and off-screen - make it reverse direction
                ambushSprite.setPosition(-10000, 0);
                ambushTrail.setPosition(-10000, 0);
                ambushSprite.velocity.set(15000, 0);
                ambushSprite.flipX = true;
            }
        } else {
            ambushSprite.setPosition(10000, 0);
            ambushTrail.setPosition(10000, 0);
            ambushSprite.velocity.set(0, 0);
            currentState = SAFE;
            StoryMenuState.instance.entityComing = false;
        }
    }

    override function update(elapsed:Float) {
        switch (currentState) {
            case WAITING:
                updateWaitingState(elapsed);
            
            case SPAWNED | SPAWNED_AGAIN:
                updateSpawnedState(elapsed);
            
            case RETREATING:
                updateRetreatState(elapsed);
            
            case SAFE:
                updateSafeState(elapsed);
            
            case KILLING:
                // Nothing to update when killing - handled by jumpscare substate
                if (ambushFarSnd != null) ambushFarSnd.stop();
                if (ambushNearSnd != null) ambushNearSnd.stop();
        }

        // Always check entity interactions if not safe
        if (currentState != SAFE && currentState != KILLING && !isInCloset) {
            handleEntityInteractions(elapsed);
        }
    }

    private function updateWaitingState(elapsed:Float) {
        timeUntilAmbushSpawns -= elapsed;
        
        if (timeUntilAmbushSpawns <= 0) {
            spawnAmbush();
            return;
        }

        // Visual effects based on time remaining
        if (timeUntilAmbushSpawns < 3 && !isInCloset) {
            var lerp = CoolUtil.boundTo(elapsed, 0, 1);
			if(ClientPrefs.data.shaders){
                StoryMenuState.instance.vignetteShader.darkness -= elapsed * 3;
                StoryMenuState.instance.vignetteShader.extent += elapsed / 3;
            }
            greenFilter.alpha = FlxMath.lerp(greenFilter.alpha, 0.8, lerp);
        } else if (isInCloset) {
            var lerp = CoolUtil.boundTo(elapsed, 0, 1);
			if(ClientPrefs.data.shaders){
                StoryMenuState.instance.vignetteShader.darkness = FlxMath.lerp(StoryMenuState.instance.vignetteShader.darkness, 15, lerp);
                StoryMenuState.instance.vignetteShader.extent = FlxMath.lerp(StoryMenuState.instance.vignetteShader.extent, 0.25, lerp);
            }
            greenFilter.alpha = FlxMath.lerp(greenFilter.alpha, 0.00001, lerp/3);
        }
        
        // Update sound and camera shake
        updateSoundAndShake(elapsed);

        // Flicker lights once
        if (!hasFlickered) {
            (cast StoryMenuState.instance.roomObject : states.storyrooms.roomTypes.Normal).flicker(2, false);
            hasFlickered = true;
        }
    }

    private function updateSpawnedState(elapsed:Float) {
        if (!isInCloset) {
            if(ambushSprite != null && ambushSprite.x > -2000 && ambushSprite.x < 2000) {
                currentState = KILLING;
                triggerJumpscare();
                return;
            }
        }

        if (ambushSprite != null) {
            if (ambushSprite.x < -12000 || ambushSprite.x > 21000) {
                handleRebounds();
            }
        }

        // Update sound and camera shake
        updateSoundAndShake(elapsed);
    }

    private function updateRetreatState(elapsed:Float) {
        // Just update sounds while ambush is retreating
        updateSoundAndShake(elapsed);
    }

    private function updateSafeState(elapsed:Float) {
        // Fade out sounds
        lerpVal = 0;

        if (ambushFarSnd != null)
            ambushFarSnd.volume = FlxMath.lerp(
                ambushFarSnd.volume, 
                lerpVal, 
                CoolUtil.boundTo(elapsed*4, 0, 1));

        if (ambushNearSnd != null)
            ambushNearSnd.volume = FlxMath.lerp(
                ambushNearSnd.volume, 
                lerpVal, 
                CoolUtil.boundTo(elapsed*4, 0, 1));
                
        // Reduce camera shake
        StoryMenuState.instance.camGame.shake(
            FlxMath.lerp(
                ambushFarSnd.volume, 
                lerpVal, 
                CoolUtil.boundTo(elapsed, 0, 1))/50, 
            0.1, true);
            
        if(ClientPrefs.data.shaders){
            StoryMenuState.instance.vignetteShader.darkness = FlxMath.lerp(StoryMenuState.instance.vignetteShader.darkness, 15, CoolUtil.boundTo(elapsed*4, 0, 1));
            StoryMenuState.instance.vignetteShader.extent = FlxMath.lerp(StoryMenuState.instance.vignetteShader.extent, 0.25, CoolUtil.boundTo(elapsed*4, 0, 1));
        }
        greenFilter.alpha = FlxMath.lerp(greenFilter.alpha, 0.00001, CoolUtil.boundTo(elapsed*4, 0, 1));
    }

    private function updateSoundAndShake(elapsed:Float) {
        // Update far sound
        if (ambushFarSnd != null) {
            if (ambushSprite != null) 
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(ambushSprite.x - StoryMenuState.instance.camFollowPos.x, -20000, 0, 0, 1), 0, 1);
            else 
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilAmbushSpawns, 5, 0, 0.6, 1), 0.6, 1);

            ambushFarSnd.volume = FlxMath.lerp(
                ambushFarSnd.volume, 
                lerpVal, 
                CoolUtil.boundTo(elapsed, 0, 1));
        }

        // Update near sound
        if (ambushNearSnd != null) {
            if (ambushSprite == null) {
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilAmbushSpawns, 3, 0, 0, 1), 0, 1);
                ambushNearSnd.pan = 0;
            } else { 
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(ambushSprite.x - StoryMenuState.instance.camFollowPos.x, -30000, 0, 0, 1), 0, 1);
                ambushNearSnd.pan = CoolUtil.boundTo(FlxMath.remapToRange(ambushSprite.x - StoryMenuState.instance.camFollowPos.x, -30000, 30000, -1, 1), -1, 1);
            }
            
            ambushNearSnd.volume = FlxMath.lerp(
                ambushNearSnd.volume, 
                lerpVal, 
                CoolUtil.boundTo(elapsed, 0, 1));
        }

        // Calculate camera shake
        var shakeFactor:Float = 0;
        if (ambushSprite == null) {
            shakeFactor = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilAmbushSpawns, 3, 0, 0, 1), 0, 1);
        } else {
            shakeFactor = CoolUtil.boundTo(FlxMath.remapToRange(ambushSprite.x - StoryMenuState.instance.camFollowPos.x, -10000, 0, 0, 1), 0, 1);
        }
        StoryMenuState.instance.camGame.shake(shakeFactor/50, 0.1, true);
    }

    private function handleEntityInteractions(elapsed:Float) {
        if (!isInCloset && StoryMenuState.instance.entityComing) {
            // Handle long doors
            if ((cast StoryMenuState.instance.roomObject:Normal).generateLong) {
                for (softDoor in (cast StoryMenuState.instance.roomObject:Normal).softDoors) {
                    softDoor.checkOverlap(camGame);
                    if (softDoor.isHovered && FlxG.mouse.justPressed) {
                        StoryMenuState.instance.updateDescription(Lang.getText("entityLongClosed", "story/interactions"));
                    }
                }
            }
    
            // Handle doors
            for (door in StoryMenuState.instance.doors) {
                door.doorSpr.checkOverlap(StoryMenuState.instance.camGame);
                if (door.doorSpr.isHovered && FlxG.mouse.justPressed && isInCloset) {
                    StoryMenuState.instance.updateDescription(Lang.getText("entityClosed", "story/interactions"));
                }
            }
    
            // Handle furniture
            for (fur in StoryMenuState.instance.furniture) {
                if (fur.sprite != null) {
                    fur.sprite.checkOverlap(StoryMenuState.instance.camGame);
                    if (!fur.name.toLowerCase().contains("closet") && fur.sprite.isHovered && FlxG.mouse.justPressed) {
                        StoryMenuState.instance.updateDescription(Lang.getText("entityFurClosed", "story/interactions"));
                    } else if (fur.name.toLowerCase().contains("closet")) {
                        StoryMenuState.instance.roomsFunc(function(room:BaseSMRoom) {
                            room.onHandleFurniture(fur.sprite, fur.name, fur.side, fur.specificAttributes, elapsed);
                        });
                    }
                }
            }
        }
    }

    override function onClosetEnter() {
        isInCloset = true;
        StoryMenuState.instance.overrideCamFollow = true;
        
        MenuSongManager.changeSongPitch(0.6, 1);
        MenuSongManager.changeSongVolume(0.05, 1);
    }

    override function onClosetLeave() {
        isInCloset = false;
        StoryMenuState.instance.overrideCamFollow = false;
        
        if (ambushTrail != null)
            ambushTrail.visible = false;
        
        // If ambush has spawned and player leaves closet, trigger jumpscare
        if (currentState == SPAWNED || currentState == SPAWNED_AGAIN) {
            if(ambushSprite != null && ambushSprite.x > -2000 && ambushSprite.x < 2000) {
                currentState = KILLING;
                triggerJumpscare();
            }
        }
        
        MenuSongManager.changeSongPitch(1, 3);
        MenuSongManager.changeSongVolume(1, 3);
    }

    override function onFocus() {
        if (ambushFarSnd != null) ambushFarSnd.play();
        if (ambushNearSnd != null) ambushNearSnd.play();
        super.onFocus();
    }

    override function onFocusLost() {
        if (ambushFarSnd != null) ambushFarSnd.stop();
        if (ambushNearSnd != null) ambushNearSnd.stop();
        super.onFocusLost();
    }

    override function destroy() {
        if (ambushFarSnd != null) ambushFarSnd.stop();
        if (ambushNearSnd != null) ambushNearSnd.stop();
        super.destroy();
    }
    
    override function onDoorOpen(selectedDoor:DoorAttributes) { 
        if(ambushFarSnd != null) ambushFarSnd.stop();
        if(ambushNearSnd != null) ambushNearSnd.stop();
        super.onDoorOpen(selectedDoor);
    }
}

class AmbushJumpscareSubState extends StoryModeSubState {
    var jumpscareSprite:FlxSprite;
    var strobingLight:FlxSprite;

    public function new() {
        super();
    }
    
    override function create() {
        super.create();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        jumpscareSprite = new FlxSprite();
        jumpscareSprite.frames = Paths.getSparrowAtlas("entities/ambush/ambushScare");
        jumpscareSprite.animation.addByPrefix("scare", "scare", 24, false, false, false);
        jumpscareSprite.animation.play("scare");
        jumpscareSprite.scale.set(FlxG.width/1920, FlxG.height/1080);
        jumpscareSprite.updateHitbox();
        jumpscareSprite.setPosition(0, 0);
        add(jumpscareSprite);

        jumpscareSprite.animation.callback = handleJumpscareAnimationEvents;

        strobingLight = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        strobingLight.alpha = 0.0001;
        if (ClientPrefs.data.flashing) {
            add(strobingLight);
        }

        startGaming();

        MenuSongManager.changeSongVolume(0, 0.5);
        MenuSongManager.playSound("ambushScarePre", 1);
    }

    override function startGaming() {}

    override function stopGaming() {
        _parentState.persistentDraw = false;

        StoryMenuState.instance.fuckingDie("SONG", "ambush", function(){
            DoorsUtil.curRun.revivesLeft += 1;
        });
    }

    function handleJumpscareAnimationEvents(name:String, frameNumber:Int, frameIndex:Int) {
        if (name != "scare") return;

        switch(frameIndex) {
            case 10: // Ambush is fully visible now
            case 11: // Ambush starts lunging forward
                MenuSongManager.playSound("ambushScareCharge", 1);
            case 24: // Play bf death sound
                MenuSongManager.playSound("ambushScareKill", 1);
                if (ClientPrefs.data.flashing) {
                    strobingLight.alpha = 0.4;
                    FlxTween.color(strobingLight, 0.05, 0xc0FFFFFF, 0xc08eff90, {
                        onComplete: function(twn) {
                            FlxTween.color(strobingLight, 0.05, 0xc08ef88f, 0xc0FFFFFF, {
                                type: LOOPING, 
                                loopDelay: 0.05
                            });
                        }, 
                        type: LOOPING, 
                        loopDelay: 0.05
                    });
                }
            case 28:
                stopGaming();
        }
    }
}