package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Elevator extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["elevator/ElevatorBack Blurr", "elevator/Elevator Original", "spawnAnims/spawnFig"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback],
			"foreground" => [stagefront],
			"special" => [[elevator, 0.1]]
		];

		return map;
	}
	
    var spawnSprite:FlxSprite;
	
	var stageback:FlxBackdrop;
	var stagefront:FlxBackdrop;
	var elevator:BGSprite;

	var video:DoorsVideoSprite;

	override function create()
	{
		stageback = new FlxBackdrop(Paths.image('elevator/ElevatorBack Blurr'));
		stageback.antialiasing = ClientPrefs.globalAntialiasing;
		add(stageback);

		elevator = new BGSprite('elevator/Elevator Original', 500, 500, 1, 1);
		elevator.scale.set(0.8, 0.8);
		elevator.updateHitbox();
		elevator.antialiasing = ClientPrefs.globalAntialiasing;
		add(elevator);

		video = new DoorsVideoSprite().preload(Paths.video('elevator_end'), [DoorsVideoSprite.MUTED]);
		video.onReady.add(()->{
			video.setGraphicSize(FlxG.width);
            video.updateHitbox();
            video.screenCenter();
		});
		video.cameras = [camBars];
		add(video);
	}

	override function stepHit()
	{
		if(curStep == 3085) {
			FlxTween.tween(PlayState.instance.timeBar, {alpha: 0.0001}, Conductor.stepCrochet / 1000, {onComplete: function(twn){
				video.playVideo();
			}});
			FlxTween.tween(PlayState.instance.timeBar, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.timeBar.frontColorTransform, {alphaMultiplier: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.timeBar.backColorTransform, {alphaMultiplier: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.timeTxt, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.scoreTxt, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.healthBar, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.healthBar.frontColorTransform, {alphaMultiplier: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.healthBar.backColorTransform, {alphaMultiplier: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.iconP1, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.iconP2, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
			FlxTween.tween(PlayState.instance.taikoSpot, {alpha: 0.0001}, Conductor.stepCrochet / 1000);
		}
	}

	function moveElevator(?starting:Bool = true, ?fast:Bool = false){
		FlxTween.cancelTweensOf(stageback);
		FlxTween.cancelTweensOf(stagefront);
		if(starting){
			if(fast){
				FlxTween.tween(stageback, {"velocity.y": -2500}, 1, {ease: FlxEase.expoOut});
				FlxTween.tween(stagefront, {"velocity.y": -2500}, 1, {ease: FlxEase.expoOut});
				camGame.shake(0.004, 999, null, true, Y);
			} else {
				FlxTween.tween(stageback, {"velocity.y": -235}, 1, {ease: FlxEase.cubeOut});
				FlxTween.tween(stagefront, {"velocity.y": -235}, 1, {ease: FlxEase.cubeOut});
				camGame.shake(0.001, 999, null, true, Y);
			}
		} else {
			FlxTween.tween(stageback, {"velocity.y": 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(stagefront, {"velocity.y": 0}, 1, {ease: FlxEase.sineInOut});
		}
	}
	
	override function createPost()
	{
		stagefront = new FlxBackdrop(Paths.image('elevator/ElevatorFront Shadows'));
		stagefront.antialiasing = ClientPrefs.globalAntialiasing;
		stagefront.alpha = 0.6;
		add(stagefront);

		moveElevator(true, false);
		
        dad.alpha = 0.0001;
        if(!handleSpawnAnimationThruEvent){
            spawnIdleFigure();
        }
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x);
		offsetY = Std.int(dad.getMidpoint().y - 30);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 150);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
	}

	private function spawnIdleFigure(){
		spawnSprite = new FlxSprite(dad.x - 492, dad.y - 1688);
		spawnSprite.antialiasing = ClientPrefs.globalAntialiasing;
		spawnSprite.frames = Paths.getSparrowAtlas("spawnAnims/spawnFig");
		spawnSprite.scale.set(0.7, 0.7);
		spawnSprite.updateHitbox();
		spawnSprite.animation.addByPrefix("spawn", "Intro 1", 24, false);
		spawnSprite.animation.play("spawn");
		add(spawnSprite);
		FlxTween.tween(boyfriend, {x: boyfriend.x + 1}, 0.333, {onComplete:function(twn){
			moveElevator(true, true);
			boyfriend.x -= 1;
		}});
		spawnSprite.animation.finishCallback = function(animName){
			spawnSprite.alpha = 0.0001;
			dad.alpha = 1;
		}
	}

	
    var handleSpawnAnimationThruEvent:Bool = false;
    override function eventPushed(event:objects.Note.EventNote){
        switch(event.event){
            case "db-figureSpawn":
                handleSpawnAnimationThruEvent = true;
                //make sure that it doesn't autoplay at the beginning
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName){
				case "db-figureSpawn":
					spawnIdleFigure();
			}
		}
}