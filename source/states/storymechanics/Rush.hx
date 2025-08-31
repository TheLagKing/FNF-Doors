package states.storymechanics;

import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

enum RushState {
    WAITING;    // Rush hasn't spawned yet, counting down
    SPAWNED;    // Rush has spawned and is moving
    KILLING;    // Rush is killing the player
    PASSED;     // Rush has passed and is no longer a threat
}

class Rush extends BaseSMMechanic {
    // State machine
    private var currentState:RushState = WAITING;
    
    public var isInCloset:Bool = false;
    var timeUntilRushSpawns:Float = 5;
    var rushSprite:FlxSprite;
    var rushTrail:FlxTrail;
    var rushFarSnd:FlxSound;
    var rushNearSnd:FlxSound;
    var hasFlickered:Bool = false;
    var lerpVal = 1.0;
    
    override function createPost() { 
        timeUntilRushSpawns = FlxG.random.float(4, 5);

        // Preload assets
        Paths.image("entities/rush/rush");
        Paths.image("entities/rush/particle");
        Paths.image("entities/rush/rushScare");
        Paths.sound("rushScarePre");
        Paths.sound("rushScareCharge");
        Paths.sound("rushScareKill");
        
        // Initialize sounds
        rushFarSnd = new FlxSound();
        rushFarSnd.loadEmbedded(Paths.sound("rush/RushPlaySound"));
        rushFarSnd.looped = true;
        rushFarSnd.persist = false;
        rushFarSnd.volume = 0;
        rushFarSnd.play();
        
        rushNearSnd = new FlxSound();
        rushNearSnd.loadEmbedded(Paths.sound("rush/RushFootsteps"));
        rushNearSnd.looped = true;
        rushNearSnd.persist = false;
        rushNearSnd.volume = 0;
        rushNearSnd.play();

        StoryMenuState.instance.entityComing = true;
        MenuSongManager.changeSongPitch(0.8, 1);
        MenuSongManager.changeSongVolume(0.3, 1);
        
        // Start in WAITING state
        changeRushState(WAITING);
    }
    
    // State transition method
    function changeRushState(newState:RushState) {
        var oldState = currentState;
        currentState = newState;
        
        // Execute enter actions for new state
        switch (currentState) {
            case SPAWNED:
                spawnRush();
            case KILLING:
                startKilling();
            case PASSED:
                StoryMenuState.instance.entityComing = false;
            default: // WAITING
                // Already set up
        }
    }
    
    function spawnRush() {
        if(isInCloset) {
            rushSprite = new FlxSprite().loadGraphic(Paths.image("entities/rush/rush"));
            rushSprite.antialiasing = ClientPrefs.globalAntialiasing;
            rushSprite.scale.set(0.8, 0.8);
            rushSprite.y = 108;
            rushSprite.color = 0xFFA5A5A5;

            rushTrail = new FlxTrail(rushSprite, Paths.image("entities/rush/particle"), 180, 0, 1, 1/180);
            rushTrail.offset.set(-100, -100);

            StoryMenuState.instance.insert(
                StoryMenuState.instance.members.indexOf(StoryMenuState.instance.closetForeground),
                rushTrail
            );

            StoryMenuState.instance.insert(
                StoryMenuState.instance.members.indexOf(StoryMenuState.instance.closetForeground), 
                rushSprite
            );

            rushSprite.setPosition(10000, 0);
            rushTrail.setPosition(10000, 0);
            rushSprite.velocity.set(-10000, 0);
        } else {
            changeRushState(KILLING);
        }
    }

    function startKilling() {
        StoryMenuState.instance.openSubState(new RushJumpscareSubState());
    }
    
    override function update(elapsed:Float) {
        // Update based on current state
        switch (currentState) {
            case WAITING:
                updateWaiting(elapsed);
            case SPAWNED:
                updateSpawned(elapsed);
            case KILLING:
                updateKilling(elapsed);
            case PASSED:
                updateSoundEffects(elapsed);
        }
    }
    
    function updateWaiting(elapsed:Float) {
        // Count down to Rush spawn
        timeUntilRushSpawns -= elapsed;
        
        // Vignette effects
        updateVignette(elapsed);
        
        // Sound and visual effects
        updateSoundEffects(elapsed);
        updateVisualEffects(elapsed);
        
        // Handle player interactions
        handlePlayerInteractions(elapsed);
        
        // Check if Rush should spawn now
        if(timeUntilRushSpawns <= 0) {
            changeRushState(SPAWNED);
        }
    }
    
    function updateSpawned(elapsed:Float) {
        // Check if player is safe
        if(!isInCloset) {
            changeRushState(KILLING);
            return;
        }
        
        // Check if Rush has passed
        if(rushSprite.x <= -5000) {
            changeRushState(PASSED);
            return;
        }
        
        // Continue updating effects
        updateVignette(elapsed);
        updateSoundEffects(elapsed);
        updateVisualEffects(elapsed);
    }
    
    function updateKilling(elapsed:Float) {
        // Mute sounds during killing
        if(rushFarSnd != null) rushFarSnd.volume = 0;
        if(rushNearSnd != null) rushNearSnd.volume = 0;
    }
    
    function updateVignette(elapsed:Float) {
        if(!ClientPrefs.data.shaders) return;
        if(currentState == WAITING && timeUntilRushSpawns < 2 && !isInCloset) {
            StoryMenuState.instance.vignetteShader.darkness -= elapsed * 3;
            StoryMenuState.instance.vignetteShader.extent += elapsed / 3;
        } else if(isInCloset) {
            var lerp = CoolUtil.boundTo(elapsed, 0, 1);
            StoryMenuState.instance.vignetteShader.darkness = FlxMath.lerp(
                StoryMenuState.instance.vignetteShader.darkness, 15, lerp);
            StoryMenuState.instance.vignetteShader.extent = FlxMath.lerp(
                StoryMenuState.instance.vignetteShader.extent, 0.25, lerp);
        }
    }

    function updateSoundEffects(elapsed:Float) {
        if(rushFarSnd != null) {
            if(currentState == WAITING) {
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilRushSpawns, 5, 0, 0.6, 1), 0.6, 1);
            } else if(currentState == SPAWNED && rushSprite != null) {
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(rushSprite.x - StoryMenuState.instance.camFollowPos.x, -20000, 0, 0, 1), 0, 1);
            } else if(currentState == PASSED) {
                lerpVal = 0; // Target volume is 0 when Rush has passed
                elapsed *= 1; // Increase the lerp speed to fade out faster
            }
            rushFarSnd.volume = FlxMath.lerp(rushFarSnd.volume, lerpVal, CoolUtil.boundTo(elapsed, 0, 1));
        }
        
        if(rushNearSnd != null) {
            if(currentState == WAITING) {
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilRushSpawns, 3, 0, 0, 1), 0, 1);
                rushNearSnd.pan = 0;
            } else if(currentState == SPAWNED && rushSprite != null) {
                lerpVal = CoolUtil.boundTo(FlxMath.remapToRange(rushSprite.x - StoryMenuState.instance.camFollowPos.x, -30000, 0, 0, 1), 0, 1);
                rushNearSnd.pan = CoolUtil.boundTo(FlxMath.remapToRange(rushSprite.x - StoryMenuState.instance.camFollowPos.x, -30000, 30000, -1, 1), -1, 1);
            } else if(currentState == PASSED) {
                lerpVal = 0; // Target volume is 0 when Rush has passed
                elapsed *= 2; // Increase the lerp speed to fade out faster
            }
            rushNearSnd.volume = FlxMath.lerp(rushNearSnd.volume, lerpVal, CoolUtil.boundTo(elapsed, 0, 1));
        }
    }
    
    function updateVisualEffects(elapsed:Float) {
        // Camera shake
        var shakeFactor:Float = 0;
        if(currentState == WAITING) {
            shakeFactor = CoolUtil.boundTo(FlxMath.remapToRange(timeUntilRushSpawns, 3, 0, 0, 1), 0, 1);
        } else if(currentState == SPAWNED && rushSprite != null) {
            shakeFactor = CoolUtil.boundTo(FlxMath.remapToRange(rushSprite.x - StoryMenuState.instance.camFollowPos.x, -10000, 0, 0, 1), 0, 1);
        }
        StoryMenuState.instance.camGame.shake(shakeFactor/100, 0.1, true);
        
        // Room flicker
        if(!hasFlickered && Std.isOfType(StoryMenuState.instance.roomObject, states.storyrooms.roomTypes.Normal)){
            (cast StoryMenuState.instance.roomObject : states.storyrooms.roomTypes.Normal).flicker(2, false);
            hasFlickered = true;
        }
    }
    
    function handlePlayerInteractions(elapsed:Float) {
        if(!isInCloset && currentState != PASSED){
            for(door in StoryMenuState.instance.doors){
                door.doorSpr.checkOverlap(StoryMenuState.instance.camGame);
                if(door.doorSpr.isHovered && FlxG.mouse.justPressed && isInCloset){
                    StoryMenuState.instance.updateDescription(Lang.getText("entityClosed", "story/interactions"));
                }
            }
    
            for(fur in StoryMenuState.instance.furniture){
                if(fur.sprite != null) {
                    fur.sprite.checkOverlap(StoryMenuState.instance.camGame);
                    if(!fur.name.toLowerCase().contains("closet") && fur.sprite.isHovered && FlxG.mouse.justPressed){
                        StoryMenuState.instance.updateDescription(Lang.getText("entityFurClosed", "story/interactions"));
                    } else if(fur.name.toLowerCase().contains("closet")){
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
        MenuSongManager.changeSongPitch(1, 3);
        MenuSongManager.changeSongVolume(1, 3);
        
        // Check if Rush is active when leaving closet
        if(currentState == SPAWNED) {
            changeRushState(KILLING);
        }
    }

    override function onFocus() {
        if(rushFarSnd != null) rushFarSnd.play();
        if(rushNearSnd != null) rushNearSnd.play();
        super.onFocus();
    }

    override function onFocusLost() {
        if(rushFarSnd != null) rushFarSnd.stop();
        if(rushNearSnd != null) rushNearSnd.stop();
        super.onFocusLost();
    }

    override function destroy() {
        if(rushFarSnd != null) rushFarSnd.stop();
        if(rushNearSnd != null) rushNearSnd.stop();
        super.destroy();
    }
    
    override function onDoorOpen(selectedDoor:DoorAttributes) { 
        if(rushFarSnd != null) rushFarSnd.stop();
        if(rushNearSnd != null) rushNearSnd.stop();
        super.onDoorOpen(selectedDoor);
    }
}

class RushJumpscareSubState extends StoryModeSubState {
    var jumpscareSprite:FlxSprite;
    var strobingLight:FlxSprite;

    public function new() {
        super();
    }
    
    override function create() {
        super.create();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        jumpscareSprite = new FlxSprite();
        jumpscareSprite.frames = Paths.getSparrowAtlas("entities/rush/rushScare");
        jumpscareSprite.animation.addByPrefix("scare", "scare", 24, false, false, false);
        jumpscareSprite.animation.play("scare");
        jumpscareSprite.scale.set(FlxG.width/1920, FlxG.height/1080);
        jumpscareSprite.updateHitbox();
        jumpscareSprite.setPosition(0, 0);
        add(jumpscareSprite);

        jumpscareSprite.animation.callback = handleJumpscareAnimationEvents;

        strobingLight = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        strobingLight.alpha = 0.0001;
        if(ClientPrefs.data.flashing){
            add(strobingLight);
        }

        startGaming();
        MenuSongManager.changeSongVolume(0, 0.5);
        MenuSongManager.playSound("rushScarePre", 1);
    }

    override function startGaming() {}

    override function stopGaming() {
        _parentState.persistentDraw = false;
        StoryMenuState.instance.fuckingDie("SONG", "rush", function(){
            DoorsUtil.curRun.revivesLeft += 1;
        });
    }

    function handleJumpscareAnimationEvents(name:String, frameNumber:Int, frameIndex:Int) {
        if(name != "scare") return;

        switch(frameIndex) {
            case 41: MenuSongManager.playSound("rushScareCharge", 1);
            case 53:
                MenuSongManager.playSound("rushScareKill", 1);
                if(ClientPrefs.data.flashing) {
                    strobingLight.alpha = 0.4;
                    FlxTween.color(strobingLight, 0.05, 0xA2FFFFFF, 0xA2FF0000, {
                        onComplete: function(twn) {
                            FlxTween.color(strobingLight, 0.05, 0xA2FF0000, 0xA2FFFFFF, {
                                type: LOOPING, loopDelay: 0.05
                            });
                        }, 
                        type: LOOPING, 
                        loopDelay: 0.05
                    });
                }
            case 57: stopGaming();
        }
    }
}