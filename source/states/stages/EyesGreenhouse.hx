package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class EyesGreenhouse extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [];
		theMap = [
			"images" => ["eyes_greenhouse/bg", "eyes_greenhouse/bg_lightning", 
						"eyes_greenhouse/shading", "eyes_greenhouse/vignette"]
		];

		return theMap;
	}
	
	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, bgthunder],
			"foreground" => [shade, fullWhite],
			"special" => [[purpleShade, 0.4]]
		];

		return map;
	}

	var bg:FlxSprite;
	var bgthunder:FlxSprite;
	var purpleShade:FlxSprite;
	var shade:FlxSprite;
	var fullWhite:FlxSprite;

	override function create()
	{
		game.isGreenhouseStage = true;
        PlayState.instance.hasSpawnAnimation = true;
		
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("eyes_greenhouse/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		bgthunder = new FlxSprite(0, 0).loadGraphic(Paths.image("eyes_greenhouse/bg_lightning"));
		bgthunder.antialiasing = ClientPrefs.globalAntialiasing;
		bgthunder.alpha = 0.0001;
		add(bgthunder);
	}
	
	override function createPost()
	{
		purpleShade = new FlxSprite(0, 0).loadGraphic(Paths.image("eyes_greenhouse/shading"));
		purpleShade.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(purpleShade);

		shade = new FlxSprite(0, 0).loadGraphic(Paths.image("eyes_greenhouse/vignette"));
		shade.antialiasing = ClientPrefs.globalAntialiasing;
		add(shade);

		fullWhite = new FlxSprite(0, 0).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.WHITE);
		fullWhite.alpha = 0.00001;
		add(fullWhite);

		comboPosition = [400, 553]; //average of the two characters
		comboPosition[0] -= 0;
		comboPosition[1] -= 300;
		
        dad.alpha = 0.0001;
        if(!handleSpawnAnimationThruEvent){
            spawnIdleEyes();
        }
	}

	var thunderCooldown:Float = 0;
	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 280);
		offsetY = Std.int(dad.getMidpoint().y - 100);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 300);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);

		boyfriend.color = 0xff5c5c5c;

		thunderCooldown -= elapsed;
	}

	override function stepHit()
		{
			if(FlxG.random.bool(10) && thunderCooldown <= 0){
				thunderCooldown = FlxG.random.float(8, 24);
				thunder();
			}
		}

	function thunder(){
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
		
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		shade.alpha = 0;
		bgthunder.alpha = 1;
		fullWhite.alpha = 0.1;
		FlxTween.tween(shade, {alpha: 1}, 3, {ease: FlxEase.expoOut});
		FlxTween.tween(bgthunder, {alpha: 0}, 3, {ease: FlxEase.expoOut});
		FlxTween.tween(fullWhite, {alpha: 0}, 3, {ease: FlxEase.expoOut});
	}

	
    var spawnSprite:FlxSprite;
	private function spawnIdleEyes(){
		spawnSprite = new FlxSprite(dad.x - 325, dad.y - 200);
		spawnSprite.antialiasing = ClientPrefs.globalAntialiasing;
		spawnSprite.frames = Paths.getSparrowAtlas("spawnAnims/spawnEyes");
		spawnSprite.animation.addByPrefix("spawn", "spawn", 24, false);
		spawnSprite.animation.play("spawn");
		spawnSprite.scale.set(1.05, 1.05);
		spawnSprite.updateHitbox();
		add(spawnSprite);
		spawnSprite.animation.finishCallback = function(animName){
			spawnSprite.alpha = 0.0001;
            PlayState.instance.camGame.flash(FlxColor.BLACK, 1, true);
			dad.alpha = 1;
		}
	}
	
    var handleSpawnAnimationThruEvent:Bool = false;
    override function eventPushed(event:objects.Note.EventNote){
        switch(event.event){
            case "spawnEyes":
                handleSpawnAnimationThruEvent = true;
                //make sure that it doesn't autoplay at the beginning
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName){
				case "spawnEyes":
					spawnIdleEyes();
			}
		}
}