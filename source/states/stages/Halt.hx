package states.stages;

import flixel.math.FlxRandom;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class Halt extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["halt/Halt Closet", "halt/Halt Counter", "halt/Halt Table",
						"halt/Halt BG Alt", "halt/Halt BG Blur"]
		];

		return theMap;
	}

    override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [],
			"foreground" => [],
			"special" => [],
            "boyfriend" => [backArm, backFoot, frontFoot]
		];

        for(obj in objects){
            map.get("background").push(obj);
        }

        for(obj in backgroundObjects){
            map.get("special").push([obj, 0.4]);
        }

		return map;
	}

	public var objects:Array<FlxSprite> = [];
    public var backgroundObjects:Array<FlxSprite> = [];

    var backgroundArrayDefault:Array<FlxSprite>;

    var modificationFormulaThing:Float = 0;

    final closetY = -19 * 0.8;
    final counterY = 535 * 0.8;
    final tableY = 551 * 0.8;
    final backgroundWidth = 1419;
    final backgroundHeight = 864;
    final maxObjectWidth:Float = 1177;

    var theActualObject:FlxSprite;
    var needsReplacingObject:Bool = true;
    var nextPlacedX:Int = 0;
    var cameraX:Float = 0;
    var successPlacing:Bool = false;
    var isMovingLeft:Bool = true;
    var nextObjectToSpawn:FlxSprite;

    var background:FlxBackdrop;
    var backgroundBlur:FlxBackdrop;

    var nextBackground:FlxSprite;
    var nextBackground2:FlxSprite;
    var numberOfLeftBackgrounds = 1;
    var numberOfRightBackgrounds = 1;

    /*
    * BF walking stuff
    */

    var backArm:FlxSprite;
    var backFoot:FlxSprite;
    var frontFoot:FlxSprite;

	override function create()
	{
		Paths.image("halt/Halt Closet");
		Paths.image("halt/Halt Counter");
		Paths.image("halt/Halt Table");

		cameraX = PlayState.instance.camGame.scroll.x;
		var objectsToSpawn = new FlxRandom().int(1, 4);
		switch (objectsToSpawn)
        {
			case 1:
				nextObjectToSpawn = new FlxSprite(cameraX - maxObjectWidth - 200, closetY).loadGraphic(Paths.image("halt/Halt Closet"));
			case 2:
				nextObjectToSpawn = new FlxSprite(cameraX - maxObjectWidth - 200, counterY).loadGraphic(Paths.image("halt/Halt Counter"));
			case 3:
				nextObjectToSpawn = new FlxSprite(cameraX - maxObjectWidth - 200, tableY).loadGraphic(Paths.image("halt/Halt Table"));
			case 4:
				nextObjectToSpawn = new FlxSprite(cameraX - maxObjectWidth - 200, counterY).loadGraphic(Paths.image("halt/Halt Empty"));
		}

		background = new FlxBackdrop(Paths.image("halt/Halt BG Alt"));
        background.antialiasing = ClientPrefs.globalAntialiasing;

		backgroundBlur = new FlxBackdrop(Paths.image("halt/Halt BG Blur"));
        backgroundBlur.antialiasing = ClientPrefs.globalAntialiasing;

		var haltCloset:BGSprite = new BGSprite('halt/Halt Closet', 18, -19*0.8, 1, 1);
		var haltCounter:BGSprite = new BGSprite('halt/Halt Counter', 439, 533*0.8, 1, 1);
		
		push(background, 0, false);
		push(haltCloset, 175, true);
		push(haltCounter, 176, true);
	}
	
	var haltLeftArray = [];
	var haltRightArray = [];
	override function createPost()
	{
		this.songName = PlayState.SONG.song;
		switch(songName.toLowerCase()){
			case 'halt':
				haltLeftArray = [0, 128, 448];
				haltRightArray = [64, 320];
			case 'onward':
				haltLeftArray = [0, 160, 224, 352];
				haltRightArray = [96, 192, 288, 416];
			case 'onward-hell':
				haltLeftArray = [0, 96, 160, 224, 352, 480];
				haltRightArray = [32, 128, 192, 288, 416];
		}
        
		comboPosition = [1186, 662]; //average of the two characters
		comboPosition[0] += 600;
		comboPosition[1] -= 350;

        backArm = new FlxSprite(
            PlayState.instance.boyfriend.x - PlayState.instance.boyfriendGroup.x, 
            PlayState.instance.boyfriend.y - PlayState.instance.boyfriendGroup.y
        );
        backArm.frames = Paths.getSparrowAtlas("characters/boyfriend/halt/back_arm");
        backArm.antialiasing = ClientPrefs.globalAntialiasing;

        backFoot = new FlxSprite(
            PlayState.instance.boyfriend.x - PlayState.instance.boyfriendGroup.x, 
            PlayState.instance.boyfriend.y - PlayState.instance.boyfriendGroup.y
        );
        backFoot.frames = Paths.getSparrowAtlas("characters/boyfriend/halt/back_foot");
        backFoot.antialiasing = ClientPrefs.globalAntialiasing;

        frontFoot = new FlxSprite(
            PlayState.instance.boyfriend.x,
            PlayState.instance.boyfriend.y
        );
        frontFoot.frames = Paths.getSparrowAtlas("characters/boyfriend/halt/front_foot");
        frontFoot.antialiasing = ClientPrefs.globalAntialiasing;

        makeAnims(false);
        changeOffsets(false);

        PlayState.instance.boyfriendGroup.insert(
            PlayState.instance.boyfriendGroup.members.indexOf(PlayState.instance.boyfriend), backArm
        );
        PlayState.instance.boyfriendGroup.insert(
            PlayState.instance.boyfriendGroup.members.indexOf(PlayState.instance.boyfriend), backFoot
        );
        PlayState.instance.insert(
            PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) + 1, frontFoot
        );

        backArm.animation.play("idle", true, false);
        backFoot.animation.play("idle", true, false);
        frontFoot.animation.play("idle", true, false);

		push(backgroundBlur, 999, false);
		changeHaltDirection(true);
	}

	override function update(elapsed:Float)
	{
		fuckinHaltMechanic();
		modificationFormulaThing = PlayState.instance.boyfriend.x;
		if(isMovingLeft){
			modificationFormulaThing += (PlayState.instance.health * 500) + PlayState.instance.boyfriend.width - 480;
			PlayState.instance.dad.flipX = true;
		} else {
			modificationFormulaThing += ((DoorsUtil.maxHealth - PlayState.instance.health) * -500) - PlayState.instance.dad.width + 70;
			PlayState.instance.dad.flipX = false;
		}
		
        if(PlayState.instance.enableHaltLerp || DoorsUtil.modifierActive(38)){
            PlayState.instance.dad.x = FlxMath.lerp(PlayState.instance.dad.x, modificationFormulaThing, CoolUtil.boundTo(elapsed * 8, 0, 1));
        } else {
            PlayState.instance.dad.x = modificationFormulaThing;
        }

        comboPosition = [game.boyfriend.getMidpoint().x, game.boyfriend.getMidpoint().y - 300];
        snapToBfPos();
        
        if (!PlayState.instance.boyfriend.getAnimationName().contains("miss") && backFoot.animation.curAnim.name == "miss"){
            backFoot.animation.play("idle", true, false, backFoot.animation.curAnim.curFrame);
            frontFoot.animation.play("idle", true, false, frontFoot.animation.curAnim.curFrame);
        } 

        if(PlayState.instance.boyfriend.getAnimationName() == "idle"){
            backArm.visible = true;
            backFoot.animation.curAnim.curFrame = frontFoot.animation.curAnim.curFrame;
            boyfriend.playAnim('idle', true, false, frontFoot.animation.curAnim.curFrame);
        } else {
            backArm.visible = false;

            if(PlayState.instance.boyfriend.getAnimationName().contains("miss") && backFoot.animation.curAnim.name != "miss"){
                backFoot.animation.play("miss", true, false, backFoot.animation.curAnim.curFrame);
                frontFoot.animation.play("miss", true, false, frontFoot.animation.curAnim.curFrame);
            }
        }
	}

    private function makeAnims(startFlipped:Bool){
        backArm.animation.addByPrefix("idle", "back_mic", 24, true, startFlipped, false);

        backFoot.animation.addByPrefix("idle", "idle", 24, true, !startFlipped, false);
        backFoot.animation.addByPrefix("miss", "missidle", 24, true, !startFlipped, false);

        frontFoot.animation.addByPrefix("idle", "foot", 24, true, !startFlipped, false);
        frontFoot.animation.addByPrefix("miss", "miss_foot", 24, true, !startFlipped, false);
    }

    private function changeOffsets(bfWillFlip:Bool){
        if(bfWillFlip){
            backArm.offset.set(57, -151);
            backFoot.offset.set(22, -202);
            frontFoot.offset.set(30, -178);
        } else {
            backArm.offset.set(-144, -151);
            backFoot.offset.set(-22, -202);
            frontFoot.offset.set(-71, -178);
        }
    }

    private function snapToBfPos(){
        frontFoot.setPosition(
            PlayState.instance.boyfriend.x,
            PlayState.instance.boyfriend.y
        );
    }

    private function fuckinHaltMechanic(){
        if (isMovingLeft){
            cameraX = PlayState.instance.camGame.scroll.x;
            if (cameraX - backgroundWidth*2 - 200 < -backgroundWidth * numberOfLeftBackgrounds){
                numberOfLeftBackgrounds += 1;
            }
            
            //Update function
            if(needsReplacingObject){
                successPlacing = placeHaltObjects(cameraX - maxObjectWidth - 200);
                if (successPlacing){
                    needsReplacingObject = false;
                    new FlxTimer().start(new FlxRandom().float(4, 8), haltObjectCallback, 1);
                    var objectsToSpawn = new FlxRandom().int(1, 3);
                    switch (objectsToSpawn){
                        case 1:
                            nextObjectToSpawn = new FlxSprite(0, closetY).loadGraphic(Paths.image("halt/Halt Closet"));
                        case 2:
                            nextObjectToSpawn = new FlxSprite(0, counterY).loadGraphic(Paths.image("halt/Halt Counter"));
                        case 3:
                            nextObjectToSpawn = new FlxSprite(0, tableY).loadGraphic(Paths.image("halt/Halt Table"));
                    }
                    nextObjectToSpawn.antialiasing = ClientPrefs.globalAntialiasing;
                }
            }
        } else {
            cameraX = PlayState.instance.camGame.scroll.x + PlayState.instance.camGame.width;
            if (cameraX + backgroundWidth > backgroundWidth * numberOfRightBackgrounds){
                numberOfRightBackgrounds += 1;
            }
            
            //Update function
            if(needsReplacingObject){
                successPlacing = placeHaltObjects(cameraX + 200);
                if (successPlacing){
                    needsReplacingObject = false;
                    new FlxTimer().start(new FlxRandom().float(4, 8), haltObjectCallback, 1);
                    var objectsToSpawn = new FlxRandom().int(1, 3);
                    switch (objectsToSpawn){
                        case 1:
                            nextObjectToSpawn = new FlxSprite(0, closetY).loadGraphic(Paths.image("halt/Halt Closet"));
                        case 2:
                            nextObjectToSpawn = new FlxSprite(0, counterY).loadGraphic(Paths.image("halt/Halt Counter"));
                        case 3:
                            nextObjectToSpawn = new FlxSprite(0, tableY).loadGraphic(Paths.image("halt/Halt Table"));
                    }
                    nextObjectToSpawn.antialiasing = ClientPrefs.globalAntialiasing;
                }
            }
        }
    }

    public function changeHaltDirection(changeToRight:Bool = false){
        if (changeToRight){
            PlayState.instance.boyfriendGroup.velocity.set(200, 0);
            PlayState.instance.triggerEventNote("Change Character", "bf", "haltbf", 0);
            PlayState.instance.iconP1.flipX = true;
            changeOffsets(false);
            isMovingLeft = false;
        } else {
            PlayState.instance.boyfriendGroup.velocity.set(-200, 0);
            PlayState.instance.triggerEventNote("Change Character", "bf", "haltbf-flip", 0);
            PlayState.instance.iconP1.flipX = false;
            changeOffsets(true);
            isMovingLeft = true;
        }
        backArm.flipX = isMovingLeft;
        backFoot.flipX = isMovingLeft;
        frontFoot.flipX = isMovingLeft;
    }

    private function haltObjectCallback(timer:FlxTimer){
        needsReplacingObject = true;
    }

    var overlapCounter = 0;
    private function placeHaltObjects(x:Float){
        //Will only be used in halt
        nextObjectToSpawn.x = x;
        overlapCounter = 0;
        for (spr in objects){
            if (nextObjectToSpawn.overlaps(spr)){
                overlapCounter += 1;
            }
        }
        if(overlapCounter == 0){
            push(nextObjectToSpawn, numberOfLeftBackgrounds + numberOfRightBackgrounds, true);
            return true;
        }
        return false;
    }

	private function push(spr:FlxSprite, ?layer = 1, ?isHaltObject = false, ?inFrontOfBF = false){
		if(isHaltObject){
			objects.insert(layer, spr);
		} else {
			backgroundObjects.insert(layer, spr);
		}

		insert(layer, spr);
	}

	override function beatHit()
	{
		for (b in haltLeftArray){
			if(curBeat == b){
				changeHaltDirection(true);
			} else if(curBeat == b - 4 || curBeat == b - 2){
				changeHaltDirection(true);
			} else if(curBeat == b - 3 || curBeat == b - 1){
				changeHaltDirection(false);
			}
		}

		for (b in haltRightArray){
			if(curBeat == b){
				changeHaltDirection(false);
			} else if(curBeat == b - 4 || curBeat == b - 2){
				changeHaltDirection(false);
			} else if(curBeat == b - 3 || curBeat == b - 1){
				changeHaltDirection(true);
			}
		}
	}
}