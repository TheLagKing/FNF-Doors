package states.stages;

import shaders.HeatwaveShader;
import openfl.filters.ShaderFilter;
import openfl.display.BlendMode;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class SeekCorridor extends BaseStage
{
    private var angleshit:Float = 1;
    private var anglevar:Float = 1;

    public static function getPreloadShit():Null<Map<String, Array<String>>>
    {
		var theMap:Map<String, Array<String>> = [
			"images" => ["seek_fog", "characters/seek_run/seek_legs", 
						"characters/bf_run/leggos", "seekBG/static",
                        'characters/bf_run/back_arm', "spawnAnims/spawnSeek",
                        "seekBG/columnFrontLeft", "seekBG/columnFrontRight",
                        "seekBG/drawerLeft", "seekBG/drawerRight",
                        "seekBG/fire", "seekBG/pillarLeft",
                        "seekBG/pillarRight", "seekBG/seekBG",
                        "seekBG/seekBGEnd", "seekBG/seekBGEndFront",
                        "seekBG/seekBGEndShading", "seekBG/seekBGFinal",
                        "seekBG/seekBGFinalEnd", "seekBG/seekBGFinalEndFront",
                        "seekBG/seekBGFinalEndShading", "seekBG/seekBGFinalShading",
                        "seekBG/seekBGShading", "seekBG/seekHand", "seekBG/tableLeft",
                        "seekBG/tableRight",
                    
                        "seekBG/planks/plankCenter", "seekBG/planks/plankFullRight", "seekBG/planks/plankLeft",
                        "seekBG/planks/plankRight", "seekBG/planks/plankRightBottom",
                    
                        "seekBG/eyes/eyeFullLeft", "seekBG/eyes/eyeFullLeftTop", "seekBG/eyes/eyeFullRight",
                        "seekBG/eyes/eyeLeft", "seekBG/eyes/eyeLeftTop", "seekBG/eyes/eyeRight", "seekBG/eyes/eyeRightTop"]
		];

        var removeArray:Array<String> = [];

        if(PlayState.SONG.song.toLowerCase() != 'ready-or-not')
        {
            removeArray.push("seekBG/static");
        }

        var balls:Array<String> = theMap.get('images');
        for(item in removeArray) balls.remove(item);
        theMap.set('images', balls);

		return theMap;
	}

    override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [wall],
			"foreground" => [outside, theRedStatic, theBigRed],
			"special" => [[fog, 0.2]],
            "boyfriend" => [seek_legs, mic, bf_legs]
		];

        var removeArray:Array<FlxSprite> = [];
        for(obj in map.get("foreground")){
            if(obj == null) removeArray.push(obj);
        }
        var balls:Array<FlxSprite> = cast map.get('foreground');
        for(item in removeArray) balls.remove(item);
        map.set('foreground', balls);

        for(obj in map.get("boyfriend")){
            if(obj == null) removeArray.push(obj);
        }

        var balls:Array<FlxSprite> = cast map.get('boyfriend');
        for(item in removeArray) balls.remove(item);
        map.set('boyfriend', balls);

		return map;
	}

    //corridor
    public var toggleSprint:Map<Int, Bool>;
    public var mustTriggerRun:Bool = false;

    //various properties
    public var isRunning:Bool = false;
    public var isRunningFast:Bool = false;

    //bf shit
    var bf_legs:FlxSprite;
    var mic:FlxSprite;

    //seek shit
    var seek_legs:FlxSprite;

    //bg shit
    var wall:FlxBackdrop;
    var fog:FlxBackdrop;
    var outside:Rain;

    //furniture shit
    var bgFurnitureGroup:FlxSpriteGroup;
    var fgFurnitureGroup:FlxSpriteGroup;
    var nextFurniture:FlxSprite;
    var nextFurniturePath:String = "";
    var nextForeground:Bool = false;
    var needsReplacingFurniture:Bool = true;
    var successPlacingFurniture:Bool = false;

    //seek eyes shit
    var hasParsedNextBackground:Bool = false;
    var nextSliceToParse:Int = 2048;
    var eyesGroup:FlxSpriteGroup;

    //planks shit
    var planksHasParsedNextBackground:Bool = false;
    var planksNextSliceToParse:Int = 2048;
    var planksGroup:FlxSpriteGroup;

    //fire shit
    var fireHasParsedNextBackground:Bool = false;
    var fireNextSliceToParse:Int = 1444;
    var fireGroup:FlxSpriteGroup;
    var fireFGGroup:FlxSpriteGroup;
    var fireShader:HeatwaveShader;
	var fireFilter:ShaderFilter;

    //specifically placed furniture and events
    var canPlaceFurniture:Bool = true;

    //movement shit
    var lastVel:Array<Float> = [];

    //ready or not shit
    var theRedStatic:FlxSprite;
    var theBigRed:FlxSprite;
    var isPov:Bool = false;

    //preload shit
    public var willRun:Bool = true;
    public var addStatic:Bool = false;

    //spawn anim shit
    var spawnSprite:FlxSprite;

    //dodge shit
    var dodgeBackground:FlxSprite;
    var dodgePillar:FlxSprite;
    var dodgePillarEye:FlxSprite;
    var dodgeForeground:FlxSprite;

    var spacebar:FlxSprite;

    var startedDodgeSection:Bool = false;
    var failedDodge:Bool = false;
    var canDodge:Bool = false;
	var hasDodged:Bool = false;
    var isDodging:Bool = false;

    //seek hand shit
    var seekHandGroup:FlxSpriteGroup;

	override function create()
	{
        PlayState.instance.hasSpawnAnimation = true;
		switch (PlayState.SONG.song.toLowerCase()){
			case 'encounter':
				//camHUD.fade(FlxColor.BLACK, 0.001, false, true);
				toggleSprint = [96 => false,
                                293 => false
                                ];
			case 'delve':
				toggleSprint = [80 => false,
                                497 => false];
            case 'ready-or-not':
                toggleSprint = [96 => false, 
                                224 => false,
                                352 => false,
                                479 => false,
                                480 => true,
                                549 => true];
                addStatic = true;
			case 'found-you':
				toggleSprint = [256 => false,
                                384 => false,
                                480 => true,
                                705 => true];
            case 'found-you-hell':
				toggleSprint = [128 => false,
                                576 => false,
                                640 => true,
                                861 => true];
			default:
				toggleSprint = [99999 => false];

                willRun = false;
		}

        if(willRun)
        {
	        PlayState.instance.addCharacterToList('bf_running', PlayState.instance.charListType('boyfriend'));
	        PlayState.instance.addCharacterToList('seek_run_body', PlayState.instance.charListType('dad'));
        }

        for(event in PlayState.instance.eventNotes)
        {
            if(event.event.toLowerCase() == 'toggleseekpov')
                addStatic = true;
        }

		startSeekBackground();

        if(addStatic)
        {
            theRedStatic = new FlxSprite(0, 0);
            theRedStatic.frames = Paths.getSparrowAtlas('seekBG/static');
            theRedStatic.animation.addByPrefix("idle", "static instance 1", 24, true);
            theRedStatic.animation.play("idle");
            theRedStatic.scale.set(1.5, 1.5);
            theRedStatic.updateHitbox();
            theRedStatic.alpha = 0.00001;
            theRedStatic.antialiasing = false; // made it more explicit lol
            add(theRedStatic);

            theBigRed = new FlxSprite(0, 0).makeSolid(1, 1, 0xFFFF0000);
            theBigRed.alpha = 0.00001;
            add(theBigRed);
        }
	}

    override function createPost(){
		comboPosition = [366, 674];
		comboPosition[0] += 0;
		comboPosition[1] -= 250;

        fgFurnitureGroup = new FlxSpriteGroup();
        add(fgFurnitureGroup);

        seekHandGroup = new FlxSpriteGroup();
        seekHandGroup.cameras = [PlayState.instance.camHUD];
        add(seekHandGroup);

        dad.alpha = 0.0001;
        if(!handleSpawnAnimationThruEvent){
            spawnIdleSeek();
        }
    }
	
	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
        fog.velocity.x = lastVel[0]??0.0;
        wall.velocity.x = lastVel[1]??0.0;
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
        try{lastVel = [fog.velocity.x, wall.velocity.x];} catch(e){}
        fog.velocity.x = 0;
        wall.velocity.x = 0;
	}

	var mustSlice:Bool = false;
    var timeUntilEndRun:Int;
	override function update(elapsed:Float)
	{
		mustSlice = false;
		if(isRunning){
			handleAnimations();
			for (t in toggleSprint.keys()){
				if(PlayState.instance.curBeat == t){
					stopSeekMoving(toggleSprint[t]);
					mustSlice = true;
				}
			}
		} else {
			for (t in toggleSprint.keys()){
				if(PlayState.instance.curBeat == t){
                    var beats = [for (k in toggleSprint.keys()) k];
                    beats.sort(function(a, b) return a - b);
                    var curIndex = beats.indexOf(t);
                    if (curIndex < beats.length - 1) {
                        var nextBeat = beats[curIndex + 1];
                        timeUntilEndRun = nextBeat - t;
                    }

					startSeekMoving(toggleSprint[t]);
                    spawnEndBackground(toggleSprint[t], timeUntilEndRun);
					mustSlice = true;
				}
			}
		}

        if(-eyesGroup.x > nextSliceToParse) {
            hasParsedNextBackground = false;
        }
        if(!hasParsedNextBackground) {
            spawnSeekEyes(PlayState.instance.songPercent * 100);
        }

        if(-planksGroup.x > planksNextSliceToParse) {
            planksHasParsedNextBackground = false;
        }
        if(!planksHasParsedNextBackground) {
            spawnPlanks();
        }

        if(-fireGroup.x > fireNextSliceToParse) {
            fireHasParsedNextBackground = false;
        }
        if(!fireHasParsedNextBackground) {
            spawnFire();
        }

        if(timeUntilEndRun < 8){        // 8 beats before, don't spawn furniture
            canPlaceFurniture = false;
        } else {
            canPlaceFurniture = true;
        }

        if(needsReplacingFurniture && canPlaceFurniture){
            successPlacingFurniture = placeFurniture((2100 - bgFurnitureGroup.x));
            needsReplacingFurniture = false;
            new FlxTimer().start(FlxG.random.float(0.2, 0.6), function(_){
                needsReplacingFurniture = true;
            }, 1);
            if (successPlacingFurniture){
                var objectsToSpawn = FlxG.random.int(1, 4);
                switch (objectsToSpawn){
                    case 1:
                        nextFurniture = new FlxSprite(0, 708).loadGraphic(Paths.image("seekBG/drawerLeft"));
                        nextFurniturePath = "seekBG/drawerLeft";
                        nextForeground = false;
                    case 2:
                        nextFurniture = new FlxSprite(0, 708).loadGraphic(Paths.image("seekBG/tableLeft"));
                        nextFurniturePath = "seekBG/tableLeft";
                        nextForeground = false;
                    case 3:
                        nextFurniture = new FlxSprite(0, 0).loadGraphic(Paths.image("seekBG/pillarLeft"));
                        nextFurniturePath = "seekBG/pillarLeft";
                        nextForeground = false;
                    case 4:
                        nextFurniture = new FlxSprite(0, 0).loadGraphic(Paths.image("seekBG/columnFrontLeft"));
                        nextFurniturePath = "seekBG/columnFrontLeft";
                        nextForeground = true;
                }
                nextFurniture.antialiasing = ClientPrefs.globalAntialiasing;
            }
        }



		if(mustSlice){
			toggleSprint.remove(PlayState.instance.curBeat);
		}

        if(addStatic){
            theBigRed.scale.set(FlxG.width * 2, FlxG.height * 2);
            theBigRed.screenCenter();
        }

        if(startedDodgeSection && !canDodge && !hasDodged && FlxG.keys.justPressed.SPACE) failedDodge = true;
        if(canDodge && !failedDodge && !hasDodged && FlxG.keys.justPressed.SPACE) hasDodged = true;
        if(canDodge && FlxG.keys.justPressed.SPACE) 
            spacebar.animation.play("beat", true, false, 0);

        handleCameraShit();
	}

    override function beatHit(){
        timeUntilEndRun -= 1;
    }
	
    private function startSeekBackground(){ // create the seek shitstorm
		outside = new Rain(-750, -150, 3000, 1080, [0xFF2f1225, 0xff000000]);
		outside.rainSpeed = 1;
		outside.rainAngle = -10;
        outside.scrollFactor.set(0,0);
		add(outside);

        bf_legs = new FlxSprite(1330, 830);
        bf_legs.visible = false;

        mic = new FlxSprite(1420, 800);
        mic.visible = false;

        seek_legs = new FlxSprite(-130, 650);
        seek_legs.visible = false;

        wall = new FlxBackdrop(Paths.image('seekBG/seekBG'), X, 0, 0);
        wall.antialiasing = ClientPrefs.globalAntialiasing;

        bgFurnitureGroup = new FlxSpriteGroup();
        eyesGroup = new FlxSpriteGroup();
        planksGroup = new FlxSpriteGroup();
        fireGroup = new FlxSpriteGroup();
        fireFGGroup = new FlxSpriteGroup();

        if(willRun)
        {
            fog = new FlxBackdrop(Paths.image('seek_fog'), XY);
            fog.cameras = [PlayState.instance.camHUD];
            fog.alpha = 0.4;
            fog.visible = false;
            fog.antialiasing = ClientPrefs.globalAntialiasing;
        }

        // Background things

        add(outside);

        add(wall);
        add(eyesGroup);
        add(bgFurnitureGroup);
        add(planksGroup);
        add(fireGroup);

        add(fog);

        // In front of bf things, not moving

        add(mic);
        add(seek_legs);
        add(bf_legs);

        // Front things
        
        add(fireFGGroup);
        add(fog);

        // furniture
        
        var objectsToSpawn = FlxG.random.int(1, 4);
        switch (objectsToSpawn){
            case 1:
                nextFurniture = new FlxSprite(2100 - bgFurnitureGroup.x, 708).loadGraphic(Paths.image("seekBG/drawerLeft"));
                nextFurniturePath = "seekBG/drawerLeft";
                nextForeground = false;
            case 2:
                nextFurniture = new FlxSprite(2100 - bgFurnitureGroup.x, 708).loadGraphic(Paths.image("seekBG/tableLeft"));
                nextFurniturePath = "seekBG/tableLeft";
                nextForeground = false;
            case 3:
                nextFurniture = new FlxSprite(2100 - bgFurnitureGroup.x, 0).loadGraphic(Paths.image("seekBG/pillarLeft"));
                nextFurniturePath = "seekBG/pillarLeft";
                nextForeground = false;
            case 4:
                nextFurniture = new FlxSprite(2100 - bgFurnitureGroup.x, 0).loadGraphic(Paths.image("seekBG/columnFrontLeft"));
                nextFurniturePath = "seekBG/columnFrontLeft";
                nextForeground = true;
        }
    }

    private function startSeekMoving(?fast:Bool = false){
        isRunning = true;
        isRunningFast = false;

        if(!fast){
            wall.velocity.x = -2816;
            fog.velocity.x = -2816;
            bgFurnitureGroup.velocity.x = -2816;
            fgFurnitureGroup.velocity.x = -2816;
            eyesGroup.velocity.x = -2816;
            planksGroup.velocity.x = -2816;
            fireGroup.velocity.x = -2816;
            fireFGGroup.velocity.x = -2816;

            bf_legs.frames = Paths.getSparrowAtlas('characters/bf_run/leggos');
            bf_legs.animation.addByPrefix('idle', 'LEGGOS', 36, true);
            bf_legs.antialiasing = ClientPrefs.globalAntialiasing;
            bf_legs.visible = false;
            bf_legs.animation.play('idle');

            seek_legs.frames = Paths.getSparrowAtlas('characters/seek_run/seek_legs');
            seek_legs.animation.addByPrefix('idle', 'legs anim', 24, true);
            seek_legs.antialiasing = ClientPrefs.globalAntialiasing;
            seek_legs.visible = false;
            seek_legs.animation.play('idle');

            mic.frames = Paths.getSparrowAtlas('characters/bf_run/back_arm');
            mic.animation.addByPrefix('idle', 'back arm', 36, true);
            mic.antialiasing = ClientPrefs.globalAntialiasing;
            mic.visible = false;
            mic.animation.play('idle');

            seek_legs.visible = true;
        } else {
            /*
            * Switch to seek bg final
            */
            wall.loadGraphic(Paths.image("seekBG/seekBGFinal"));
            if(ClientPrefs.data.shaders){
                fireShader = new HeatwaveShader();
                add(fireShader);
                fireFilter = new ShaderFilter(fireShader.shader);
                if(PlayState.storyDifficulty > 0){
                    PlayState.instance.camGameFilters.push(fireFilter);
                    PlayState.instance.updateCameraFilters("camGame");
                }
                if(PlayState.storyDifficulty > 1){ //HARD / HELL -> SHADER ON HUD TOO
                    PlayState.instance.camHUDFilters.push(fireFilter);
                    PlayState.instance.updateCameraFilters("camHUD");
                }
            }

            wall.velocity.x = -3520;
            fog.velocity.x = -3520;
            bgFurnitureGroup.velocity.x = -3520;
            fgFurnitureGroup.velocity.x = -3520;
            eyesGroup.velocity.x = -3520;
            planksGroup.velocity.x = -3520;
            fireGroup.velocity.x = -3520;
            fireFGGroup.velocity.x = -3520;

            bf_legs.frames = Paths.getSparrowAtlas('characters/bf_run/leggos');
            bf_legs.animation.addByPrefix('idle', 'LEGGOS', 40, true);
            bf_legs.antialiasing = ClientPrefs.globalAntialiasing;
            bf_legs.visible = false;
            bf_legs.animation.play('idle');

            seek_legs.frames = Paths.getSparrowAtlas('characters/seek_run/seek_legs');
            seek_legs.animation.addByPrefix('idle', 'legs anim', 24, true);
            seek_legs.antialiasing = ClientPrefs.globalAntialiasing;
            seek_legs.visible = false;
            seek_legs.animation.play('idle');

            mic.frames = Paths.getSparrowAtlas('characters/bf_run/back_arm');
            mic.animation.addByPrefix('idle', 'back arm', 40, true);
            mic.antialiasing = ClientPrefs.globalAntialiasing;
            mic.visible = false;
            mic.animation.play('idle');

            if(PlayState.SONG.song.toLowerCase() != "found-you") seek_legs.visible = true;
            else seek_legs.visible = false;
            isRunningFast = true;
        }

        outside.rainSpeed = 3;
        outside.rainAngle = -70;

        bf_legs.visible = true;
        mic.visible = true;
        fog.visible = true;
        
        PlayState.instance.boyfriendGroup.x = 1295;
        PlayState.instance.boyfriendGroup.y = 415;//+ 85;
    }

    private function spawnEndBackground(?fast:Bool = false, howManyBeatsUntilDoor:Int){
        var xPosition = (Conductor.crochet/1000 * howManyBeatsUntilDoor) * (fast ? 3520 : 2816);

        var endBack:FlxSprite = new FlxSprite(xPosition - 4515 - bgFurnitureGroup.x, 0).loadGraphic(Paths.image(fast ? "seekBG/seekBGFinalEnd" : "seekBG/seekBGEnd"));
        endBack.antialiasing = ClientPrefs.globalAntialiasing;
        bgFurnitureGroup.add(endBack);

        var endFront:FlxSprite = new FlxSprite(xPosition - 4515 - fgFurnitureGroup.x, 0).loadGraphic(Paths.image(fast ? "seekBG/seekBGFinalEndFront" : "seekBG/seekBGEndFront"));
        endFront.antialiasing = ClientPrefs.globalAntialiasing;
        fgFurnitureGroup.add(endFront);

        var endFront:FlxSprite = new FlxSprite(xPosition - 4515 - fgFurnitureGroup.x, 0).loadGraphic(Paths.image(fast ? "seekBG/seekBGFinalEndShading" : "seekBG/seekBGEndShading"));
        endFront.antialiasing = ClientPrefs.globalAntialiasing;
        fgFurnitureGroup.add(endFront);
    }

    private function stopSeekMoving(?fast:Bool = false){
        isRunning = false;
        isRunningFast = false;

        wall.velocity.x = 0;
        fog.velocity.x = 0;
        fog.x = 0;
        bgFurnitureGroup.velocity.x = 0;
        fgFurnitureGroup.velocity.x = 0;
        eyesGroup.velocity.x = 0;
        planksGroup.velocity.x = 0;
        fireGroup.velocity.x = 0;
        fireFGGroup.velocity.x = 0;
        
        wall.x -= 2000;
        bgFurnitureGroup.x -= 2000;
        fgFurnitureGroup.x -= 2000;
        eyesGroup.x -= 2000;
        planksGroup.x -= 2000;
        fireGroup.x -= 2000;
        fireFGGroup.x -= 2000;

        outside.rainSpeed = 1.5;
        outside.rainAngle = -20;

        seek_legs.visible = false;
        bf_legs.visible = false;
        mic.visible = false;
        fog.visible = false;
        
        PlayState.instance.boyfriendGroup.x = 1200;
        PlayState.instance.boyfriendGroup.y = 340;
    }

    private function handleAnimations(){
        var boyfriend = PlayState.instance.boyfriend;
        var bfAnimation = boyfriend.getAnimationName();
        if (bfAnimation == 'idle')
        {
            boyfriend.playAnim('idle', true, false, bf_legs.animation.curAnim.curFrame);
            mic.visible = true;
        } else {
            mic.visible = false;
        }

        var dad = PlayState.instance.dad;
        if(dad.curCharacter == "madseek") seek_legs.visible = false;
        else if (dad.curCharacter == "seek_run_body") seek_legs.visible = true;
        var dadAnimation = dad.getAnimationName();
        if (dadAnimation == 'idle')
        {
            dad.playAnim('idle', true, false, seek_legs.animation.curAnim.curFrame);
        }
    }

    var overlapCounter = 0;
    private function placeFurniture(x:Float){
        nextFurniture.x = x;
        overlapCounter = 0;

        // restrict spawning between 580 and 1496 if it's a pillar or column
        if((x % 2048 > 580 && x % 2048 < 1496)){
            return false;
        }


        for (spr in bgFurnitureGroup.members){
            if (nextFurniture.overlaps(spr)){
                overlapCounter += 1;
            }
        }

        nextFurniture.loadGraphic(Paths.image(nextFurniturePath.replace("Left", getClosestLightSource(x, nextFurniture.width))));
        nextFurniture.antialiasing = ClientPrefs.globalAntialiasing;

        if(overlapCounter == 0){
            push(nextFurniture, !nextForeground);
            return true;
        }
        return false;
    }

    private function push(spr:FlxSprite, ?isBackground:Bool = true){
        if(isBackground){
            bgFurnitureGroup.add(spr);
        } else {
            fgFurnitureGroup.add(spr);
        }
    }

    private function getClosestLightSource(x:Float, objWidth:Float){
        var lightSource1:Float = (650 - wall.x * 2048);
        var lightSource2:Float = (650 - wall.x * 2048);

        var objCenter:Float = x + objWidth / 2;

        var distance1:Float = Math.abs(lightSource1 - objCenter % 2048);
        var distance2:Float = Math.abs(lightSource2 - objCenter % 2048);

        if (distance1 < distance2) {
            return "Left";
        } else {
            return "Right";
        }
    }

    private function spawnSeekEyes(songProgress:Float) {
        var seekEye0:FlxSprite = new FlxSprite(8 - eyesGroup.x + 2048, 633).loadGraphic(Paths.image("seekBG/eyes/eyeFullLeft"));
        seekEye0.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye1:FlxSprite = new FlxSprite(17 - eyesGroup.x + 2048, 359).loadGraphic(Paths.image("seekBG/eyes/eyeFullLeftTop"));
        seekEye1.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye2:FlxSprite = new FlxSprite(287 - eyesGroup.x + 2048, 572).loadGraphic(Paths.image("seekBG/eyes/eyeLeft")); 
        seekEye2.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye3:FlxSprite = new FlxSprite(406 - eyesGroup.x + 2048, 456).loadGraphic(Paths.image("seekBG/eyes/eyeLeftTop")); 
        seekEye3.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye4:FlxSprite = new FlxSprite(1505 - eyesGroup.x + 2048, 495).loadGraphic(Paths.image("seekBG/eyes/eyeRight")); 
        seekEye4.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye5:FlxSprite = new FlxSprite(1644 - eyesGroup.x + 2048, 579).loadGraphic(Paths.image("seekBG/eyes/eyeRightTop")); 
        seekEye5.antialiasing = ClientPrefs.globalAntialiasing;

        var seekEye6:FlxSprite = new FlxSprite(1917 - eyesGroup.x + 2048, 547).loadGraphic(Paths.image("seekBG/eyes/eyeFullRight")); 
        seekEye6.antialiasing = ClientPrefs.globalAntialiasing;

        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye0);
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye1);
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye2); 
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye3);
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye4);
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye5);
        if(FlxG.random.bool(songProgress / 1.5)) eyesGroup.add(seekEye6);

        hasParsedNextBackground = true;
        nextSliceToParse += 2048;
    }

    private function spawnPlanks() {
        if(!isRunningFast) {
            planksHasParsedNextBackground = true;
            planksNextSliceToParse += 2048;
            return;
        }
        var plank0:FlxSprite = new FlxSprite(74 - planksGroup.x + 2048, 976).loadGraphic(Paths.image("seekBG/planks/plankLeft"));
        plank0.antialiasing = ClientPrefs.globalAntialiasing;

        var plank1:FlxSprite = new FlxSprite(657 - planksGroup.x + 2048, 926).loadGraphic(Paths.image("seekBG/planks/plankCenter"));
        plank1.antialiasing = ClientPrefs.globalAntialiasing;

        var plank2:FlxSprite = new FlxSprite(1112 - planksGroup.x + 2048, 897).loadGraphic(Paths.image("seekBG/planks/plankRight")); 
        plank2.antialiasing = ClientPrefs.globalAntialiasing;

        var plank3:FlxSprite = new FlxSprite(1089 - planksGroup.x + 2048, 1020).loadGraphic(Paths.image("seekBG/planks/plankRightBottom")); 
        plank3.antialiasing = ClientPrefs.globalAntialiasing;

        var plank4:FlxSprite = new FlxSprite(1683 - planksGroup.x + 2048, 913).loadGraphic(Paths.image("seekBG/planks/plankFullRight")); 
        plank4.antialiasing = ClientPrefs.globalAntialiasing;

        if(FlxG.random.bool(20)) planksGroup.add(plank0);
        if(FlxG.random.bool(20)) planksGroup.add(plank1);
        if(FlxG.random.bool(20)) planksGroup.add(plank2); 
        if(FlxG.random.bool(20)) planksGroup.add(plank3);
        if(FlxG.random.bool(20)) planksGroup.add(plank4);

        planksHasParsedNextBackground = true;
        planksNextSliceToParse += 2048;
    }

    private function spawnFire() {
        if(!isRunningFast) {
            fireHasParsedNextBackground = true;
            fireNextSliceToParse += 1444;
            return;
        }

        var fire:FlxSprite = new FlxSprite(-fireGroup.x + 2048, FlxG.random.int(-70, -50));
        fire.frames = Paths.getSparrowAtlas("seekBG/fire");
        fire.animation.addByPrefix("idle", "fire", 8, true);
        fire.animation.play("idle");
        fire.antialiasing = ClientPrefs.globalAntialiasing;

        var frontFire:FlxSprite = new FlxSprite(-fireGroup.x + 2048, FlxG.random.int(260, 330));
        frontFire.frames = Paths.getSparrowAtlas("seekBG/fire");
        frontFire.animation.addByPrefix("idle", "fire", 8, true);
        frontFire.animation.play("idle");
        frontFire.antialiasing = ClientPrefs.globalAntialiasing;
        frontFire.alpha = 0.5;

        fireGroup.add(fire);
        fireFGGroup.add(frontFire);

        // y : -50 ~ -70
        // x gap : 1444

        fireHasParsedNextBackground = true;
        fireNextSliceToParse += 1444;
    }

    var handleSpawnAnimationThruEvent:Bool = false;
    override function eventPushed(event:objects.Note.EventNote){
        switch(event.event){
            case "seekHand":
                Paths.image("seekBG/seekHand");

            case "seekDodge":
                PlayState.instance.hasSpawnAnimation = false;
                Paths.image("seekBG/dodgeFront");
                Paths.image("seekBG/dodgeRoom");
                Paths.image("seekBG/dodgePillar");
                Paths.image("seekBG/dodgePillarEyes");
                Paths.image("darkRoom/SpaceAnimation");
                Paths.sound("dodge");
                Paths.sound("crash");

            case "spawnSeek":
                handleSpawnAnimationThruEvent = true;
                //make sure that it doesn't autoplay at the beginning
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
            case "spawnSeekHand":
                spawnSeekHand(flValue1, value2);

            case "seekDodge":
                spawnNewDodgeRoom();

            case "spawnSeek":
                spawnIdleSeek();

            case "seekTweenIntoPlace":
                FlxTween.tween(dad, {x:450}, (Conductor.crochet/1000)*(flValue2*2), {ease: FlxEase.expoOut});

            case "seekEndSong":
                // value 1 = duration;ease
                // value 2 = if True, make him come back (for a fake-out)
                // IMPORTANT : Always use a fake-out after you made him disappear

                var killYourself = value1.split(";");
                var duration:Float = 0.6;
                var ease:String = "sineInOut";

                if(killYourself.length >= 1) duration = Std.parseFloat(killYourself[0]);
                if(killYourself.length >= 2) ease = killYourself[1];

                if(value2 == "True"){
                    FlxTween.tween(seek_legs, {x: seek_legs.x + 2000}, duration, {ease: PlayState.instance.getFlxEaseByString(ease)});
                    FlxTween.tween(dadGroup, {x: dadGroup.x + 2000}, duration, {ease: PlayState.instance.getFlxEaseByString(ease)});
                } else {
                    FlxTween.tween(seek_legs, {x: seek_legs.x - 2000}, duration, {ease: PlayState.instance.getFlxEaseByString(ease)});
                    FlxTween.tween(dadGroup, {x: dadGroup.x - 2000}, duration, {ease: PlayState.instance.getFlxEaseByString(ease)});
                }
            case "Change Character":
                if(value2 == "madseek"){
                    seek_legs.visible = false;
                } else if (value2 == "seek_run_body"){
                    seek_legs.visible = true;
                }

            case "toggleSeekPov":
                if(isPov) {
                    PlayState.instance.dadGroup.x -= 300;
                    theBigRed.alpha = 0;
                    theRedStatic.alpha = 0;
                    
                    camGame.fade(0x370500, 5, true, null, true);

                    PlayState.instance.timeBar.alpha = 1;
                    PlayState.instance.timeBar.frontColorTransform.alphaMultiplier = 1;
                    PlayState.instance.timeBar.backColorTransform.alphaMultiplier = 0.00001;
                    PlayState.instance.timeTxt.alpha = 1;
                    PlayState.instance.scoreTxt.alpha = 1;
                    PlayState.instance.healthBar.alpha = 1;
                    PlayState.instance.healthBar.frontColorTransform.alphaMultiplier = 1;
                    PlayState.instance.healthBar.backColorTransform.alphaMultiplier = 1;
                    PlayState.instance.iconP1.alpha = 1;
                    PlayState.instance.iconP2.alpha = 1;
                    fgFurnitureGroup.visible = true;
                } else {
                    PlayState.instance.dadGroup.x += 300;
                    theBigRed.alpha = 0.4;
                    theRedStatic.alpha = 1;
                    
                    camGame.fade(0x370500, 5, true, null, true);

                    PlayState.instance.timeBar.alpha = 0.000001;
                    PlayState.instance.timeBar.frontColorTransform.alphaMultiplier = 0.00001;
                    PlayState.instance.timeBar.backColorTransform.alphaMultiplier = 0.00001;
                    PlayState.instance.timeTxt.alpha = 0.000001;
                    PlayState.instance.scoreTxt.alpha = 0.000001;
                    PlayState.instance.healthBar.alpha = 0.000001;
                    PlayState.instance.healthBar.frontColorTransform.alphaMultiplier = 0.00001;
                    PlayState.instance.healthBar.backColorTransform.alphaMultiplier = 0.00001;
                    PlayState.instance.iconP1.alpha = 0.000001;
                    PlayState.instance.iconP2.alpha = 0.000001;
                    fgFurnitureGroup.visible = false;
                }
                isPov = !isPov;
		}
	}

    public function spawnIdleSeek(){
        spawnSprite = new FlxSprite(dad.x - 175, dad.y - 167);
        spawnSprite.antialiasing = ClientPrefs.globalAntialiasing;
        spawnSprite.frames = Paths.getSparrowAtlas("spawnAnims/spawnSeek");
        spawnSprite.scale.set(0.453, 0.453);
        spawnSprite.updateHitbox();
        spawnSprite.animation.addByPrefix("spawn", "spawn", 12, false);
        spawnSprite.animation.play("spawn");
        add(spawnSprite);
        spawnSprite.animation.finishCallback = function(animName){
            spawnSprite.alpha = 0.0001;
            PlayState.instance.camGame.flash(FlxColor.BLACK, 1, true);
            dad.alpha = 1;
        }
    }

    public function spawnNewDodgeRoom(){
        canDodge = false;
        hasDodged = false;

        dodgeBackground = new FlxSprite(0,0).loadGraphic(Paths.image("seekBG/dodgeRoom"));
        dodgeBackground.antialiasing = ClientPrefs.globalAntialiasing;
        addBehindDad(dodgeBackground);

        dodgePillar = new FlxSprite(0,0).loadGraphic(Paths.image("seekBG/dodgePillar"));
        dodgePillar.antialiasing = ClientPrefs.globalAntialiasing;
        addBehindDad(dodgePillar);

        dodgePillarEye = new FlxSprite(0,0).loadGraphic(Paths.image("seekBG/dodgePillarEyes"));
        dodgePillarEye.antialiasing = ClientPrefs.globalAntialiasing;
        addBehindDad(dodgePillarEye);

        dodgeForeground = new FlxSprite(0,0).loadGraphic(Paths.image("seekBG/dodgeFront"));
        dodgeForeground.antialiasing = ClientPrefs.globalAntialiasing;
        add(dodgeForeground);

        spacebar = new FlxSprite(0,0);
        spacebar.frames = Paths.getSparrowAtlas("darkRoom/SpaceAnimation");
        spacebar.antialiasing = ClientPrefs.globalAntialiasing;
        spacebar.animation.addByPrefix("beat", "Space", 24, false);
        spacebar.animation.play("beat", true, false, 96);
        spacebar.cameras = [game.camHUD];
        spacebar.scale.set(0.6, 0.6);
        spacebar.updateHitbox();
        spacebar.screenCenter();
        spacebar.alpha = 0.25;
        insert(game.members.indexOf(game.notes), spacebar);

        var timeBetweenBops = (Conductor.crochet / 1000) * (Conductor.bpm / 150);
        var distanceToSendRoom = Math.abs((timeBetweenBops * 6) * wall.velocity.x) - 250;

        dodgeBackground.x = dodgePillar.x = dodgePillarEye.x = dodgeForeground.x = distanceToSendRoom;
        dodgeBackground.velocity.x = dodgePillar.velocity.x = 
            dodgePillarEye.velocity.x = dodgeForeground.velocity.x = 
            wall.velocity.x;

        // NOT SUCH A FUN FACT: Tibu had a mental breakdown trying to make this "good" and failed horribly trying to "make it good"
        // So she just gave up trying
        // -Tibu (why is this in third person? idfk I already had enough, I am considering stepping down as a coder honestly)
        // sorry if you had to read this btw!!! I love most of y'all in the dev team :3 (=(0_0) <-- Beatblock guy idk cool game

        PlayState.instance.modchartTimers.set("bopTimer", new FlxTimer().start(
            timeBetweenBops, function(tmr){
                startedDodgeSection = true;

                if(tmr.loopsLeft == 2) // need to dodge !
                {
                    canDodge = true;
                }
                else if(tmr.loopsLeft == 0) // time's up
                {
                    if(!failedDodge && hasDodged) // all good, you dodged
                    {
                        canDodge = false;
                        isDodging = true;

                        var dodgeSound:FlxSound = new FlxSound();
                        dodgeSound.loadEmbedded(Paths.sound("dodge"));
                        dodgeSound.play();
                        FlxTween.tween(bf_legs, {y: bf_legs.y + 300}, timeBetweenBops, {ease: FlxEase.circOut});
                        FlxTween.tween(mic, {y: mic.y + 300}, timeBetweenBops, {ease: FlxEase.circOut});
                        FlxTween.tween(boyfriendGroup, {y: boyfriendGroup.y + 300}, timeBetweenBops, {ease: FlxEase.circOut, onComplete: function(twn){
                            FlxTween.tween(boyfriendGroup, {y: boyfriendGroup.y - 300}, timeBetweenBops, {ease: FlxEase.circOut});
                            FlxTween.tween(bf_legs, {y: bf_legs.y - 300}, timeBetweenBops, {ease: FlxEase.circOut});
                            FlxTween.tween(mic, {y: mic.y - 300}, timeBetweenBops, {ease: FlxEase.circOut});
                        }});

                        FlxTween.tween(seek_legs, {y: seek_legs.y + 300}, timeBetweenBops, {ease: FlxEase.circOut,startDelay:timeBetweenBops/4});
                        FlxTween.tween(dadGroup, {y: dadGroup.y + 300}, timeBetweenBops, {ease: FlxEase.circOut,startDelay:timeBetweenBops/4, onComplete:function(twn){
                            FlxTween.tween(dadGroup, {y: dadGroup.y - 300}, timeBetweenBops, {ease: FlxEase.circOut,startDelay:timeBetweenBops/4});
                            FlxTween.tween(seek_legs, {y: seek_legs.y - 300}, timeBetweenBops, {ease: FlxEase.circOut,startDelay:timeBetweenBops/4, onComplete:function(twn){
                                hasDodged = false;
                                isDodging = false;
                            }});
                        }});
                        FlxTween.tween(spacebar, {alpha: 0}, timeBetweenBops*2, {ease: FlxEase.sineInOut});
                    } else { // you lose a lot of health
                        game.health -= (PlayState.storyDifficulty+1)*0.4;

                        var crashSound:FlxSound = new FlxSound();
                        crashSound.loadEmbedded(Paths.sound("crash"));
                        crashSound.play();
                    }

                    startedDodgeSection = false;
                }

                var sound:FlxSound = new FlxSound();
                sound.loadEmbedded(Paths.sound("warningTick"));
                sound.volume = !canDodge ? 0.0 : (4-(tmr.loopsLeft-1))*0.25;
                sound.pitch = 1;
                sound.play();
                
                if(canDodge)
                {
                    spacebar.y -= 150;
                    FlxTween.tween(spacebar, {y: spacebar.y + 150}, timeBetweenBops/2, {ease: FlxEase.circOut});
                    spacebar.alpha += 0.275;

                    spacebar.animation.play("beat", true, false, 24);

                    spacebar.scale.set(spacebar.scale.x + 0.2, spacebar.scale.y + 0.2);
                }
                else
                {
                    spacebar.alpha += 0.1;
                }

                spacebar.updateHitbox();
                spacebar.screenCenter();

                trace(startedDodgeSection);
                trace(timeBetweenBops);
                trace(tmr.loopsLeft);
                trace(failedDodge);
                trace(hasDodged);
                trace((PlayState.storyDifficulty+1)*0.4);
                trace('- - - - - - - - - - - - - -');

            }, 5
        ));
    }

    function spawnSeekHand(duration:Float, movementType:String){
        //STATIC/UPDOWN/UP/DOWN

        var seekHand:FlxSprite = new FlxSprite();
        seekHand.frames = Paths.getSparrowAtlas("seekBG/seekHand");
        seekHand.animation.addByPrefix("idle", "Linha do tempo 1_", 24, true, true, false);
        seekHand.animation.play("idle");
        seekHand.antialiasing = ClientPrefs.globalAntialiasing;
        seekHand.scale.set((ClientPrefs.data.middleScroll ? 0.6 : 0.5), 0.5);
        seekHand.updateHitbox();
        seekHandGroup.add(seekHand);

        switch(movementType){
            case "STATIC":
                // total duration = Conductor.crochet/1000 * duration * 3
                seekHand.setPosition(FlxG.width, FlxG.random.int(0, 500));
                FlxTween.tween(seekHand, {x: FlxG.width - (ClientPrefs.data.middleScroll ? seekHand.width : seekHand.width/1.3)}, Conductor.crochet/1000 * duration/2, {ease: FlxEase.quartInOut, onComplete:function(twn){
                    FlxTween.tween(seekHand, {x: seekHand.x + 200}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineOut, onComplete:function(twn){
                        FlxTween.tween(seekHand, {x: seekHand.x - 200}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineIn, onComplete:function(twn){
                            FlxTween.tween(seekHand, {x: FlxG.width}, Conductor.crochet/1000 * duration/2, {ease: FlxEase.quartInOut, onComplete:function(twn){
                                seekHandGroup.remove(seekHand);
                                seekHand.kill();
                            }});
                        }});
                    }});
                }});
                FlxTween.tween(seekHand, {angle: FlxG.random.getObject([-5, 5])}, Conductor.crochet/1000 * duration, {ease: FlxEase.quartInOut, type: PINGPONG});
            case "UP":
                seekHand.setPosition(FlxG.width, FlxG.height);
                FlxTween.tween(seekHand, {x: FlxG.width - (ClientPrefs.data.middleScroll ? seekHand.width : seekHand.width/1.3)}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineIn, onComplete:function(twn){
                    FlxTween.tween(seekHand, {x: FlxG.width}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineOut, onComplete:function(twn){
                        seekHandGroup.remove(seekHand);
                        seekHand.kill();
                    }});
                }});
                FlxTween.tween(seekHand, {y: -seekHand.height}, Conductor.crochet/1000 * duration*2, {ease: FlxEase.quartInOut});
                FlxTween.tween(seekHand, {angle: -5}, Conductor.crochet/1000 * duration, {ease: FlxEase.quartInOut, type: PINGPONG});
            
            case "DOWN":
                seekHand.setPosition(FlxG.width, -seekHand.height);
                FlxTween.tween(seekHand, {x: FlxG.width - (ClientPrefs.data.middleScroll ? seekHand.width : seekHand.width/1.3)}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineIn, onComplete:function(twn){
                    FlxTween.tween(seekHand, {x: FlxG.width}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineOut, onComplete:function(twn){
                        seekHandGroup.remove(seekHand);
                        seekHand.kill();
                    }});
                }});
                FlxTween.tween(seekHand, {y: FlxG.height}, Conductor.crochet/1000 * duration*2, {ease: FlxEase.quartInOut});
                FlxTween.tween(seekHand, {angle: 5}, Conductor.crochet/1000 * duration, {ease: FlxEase.quartInOut, type: PINGPONG});
            
            case "UPDOWN":
                seekHand.setPosition(FlxG.width, FlxG.random.int(0, 300));
                FlxTween.tween(seekHand, {x: FlxG.width - (ClientPrefs.data.middleScroll ? seekHand.width : seekHand.width/1.3)}, Conductor.crochet/1000 * duration/2, {ease: FlxEase.quartInOut, onComplete:function(twn){
                    FlxTween.tween(seekHand, {x: seekHand.x + 200}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineOut, onComplete:function(twn){
                        FlxTween.tween(seekHand, {x: seekHand.x - 200}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineIn, onComplete:function(twn){
                            FlxTween.tween(seekHand, {x: FlxG.width}, Conductor.crochet/1000 * duration/2, {ease: FlxEase.quartInOut, onComplete:function(twn){
                                seekHandGroup.remove(seekHand);
                                seekHand.kill();
                            }});
                        }});
                    }});
                }});
                FlxTween.tween(seekHand, {y: seekHand.y + 200}, Conductor.crochet/1000 * duration, {ease: FlxEase.sineInOut, type:PINGPONG});
                FlxTween.tween(seekHand, {angle: FlxG.random.getObject([-5, 5])}, Conductor.crochet/1000 * duration, {ease: FlxEase.quartInOut, type: PINGPONG});
        }
    }

    function handleCameraShit(){
        if(isDodging){
            offsetX = Std.int(1263);
            offsetY = Std.int(672);
            bfoffsetX = Std.int(1263);
            bfoffsetY = Std.int(672);
            return;
        }

        if(isPov){
            offsetX = Std.int(dad.getMidpoint().x + 400);
            offsetY = Std.int(dad.getMidpoint().y);
            bfoffsetX = Std.int(dad.getMidpoint().x + 400);
            bfoffsetY = Std.int(dad.getMidpoint().y);
            return;
        } else {
            if(isRunning){
                switch(dad.curCharacter){
                    case "madseek":
                        bfoffsetX = Std.int(boyfriend.getMidpoint().x - 560);
                        bfoffsetY = Std.int(boyfriend.getMidpoint().y - 180);
                        bfoffsetX = Std.int(boyfriend.getMidpoint().x - 260);
                        bfoffsetY = Std.int(boyfriend.getMidpoint().y - 150);
                    case "seek_run_body":
                        offsetX = Std.int(dad.getMidpoint().x + 400);
                        offsetY = Std.int(dad.getMidpoint().y + 70);
                        bfoffsetX = Std.int(boyfriend.getMidpoint().x - 260);
                        bfoffsetY = Std.int(boyfriend.getMidpoint().y - 150);
                }
            } else {
                offsetX = Std.int(dad.getMidpoint().x + 350);
                offsetY = Std.int(dad.getMidpoint().y - 100);
                bfoffsetX = Std.int(boyfriend.getMidpoint().x - 360);
                bfoffsetY = Std.int(boyfriend.getMidpoint().y - 200);
            }
        }
    }
}