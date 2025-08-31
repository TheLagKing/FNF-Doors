package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Eyes extends BaseStage
{
	public static var altID:Int = 0;

	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => switch(altID) {
				case 1: ["eyes_alt/bg", "eyes_alt/shading"];
				case 2: ["eyes_alt2/bg"];
				case 3: ["eyes_alt3/bg", "eyes_alt3/front", "eyes_alt3/chandelier"];
				default: ["eyes/eyes_bg_temp", "eyesShadow"];
			} 
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback, shadow],
			"foreground" => [shading],
			"special" => [[]]
		];

		return map;
	}

	var stageback:BGSprite;
	var shadow:FlxSprite;
	var shading:FlxSprite;
	var chandelier:FlxSprite;

	override function create()
	{
		stageback = switch(altID) {
			case 1: new BGSprite('eyes_alt/bg', -750, -159, 1, 1);
			case 2: new BGSprite("eyes_alt2/bg", -800, -299, 1, 1);
			case 3: new BGSprite("eyes_alt3/bg", -800, -299, 1, 1);
			default: new BGSprite('eyes/eyes_bg_temp', -750, -140, 1, 1);
		}
		stageback.scale.set(1.1, 1.1);
		stageback.updateHitbox();
		add(stageback);

		shadow = new FlxSprite(-800, -800).makeGraphic(FlxColor.BLACK, 1, 1);
		shading = new FlxSprite(-800, -800).makeGraphic(FlxColor.BLACK, 1, 1);
		chandelier = new FlxSprite(-800, -800).makeGraphic(FlxColor.BLACK, 1, 1);
        PlayState.instance.hasSpawnAnimation = true;

		switch(altID){
			case 3:
				chandelier = new FlxSprite(-800, -299).loadGraphic(Paths.image("eyes_alt3/chandelier"));
				chandelier.scale.set(1.1, 1.1);
				chandelier.updateHitbox();
				chandelier.antialiasing = ClientPrefs.globalAntialiasing;
				add(chandelier);
			case 2:
				//do nothing
			case 1:
				shading = new FlxSprite(-750, -159).loadGraphic(Paths.image("eyes_alt/shading"));
				shading.scale.set(1.1, 1.1);
				shading.updateHitbox();
				shading.antialiasing = ClientPrefs.globalAntialiasing;
				add(shading);
			default:
				shadow = new FlxSprite(330, 530).loadGraphic(Paths.image("eyes/eyesShadow"));
				shadow.alpha = 0.4;
				shadow.scale.set(0.9, 1);
				shadow.updateHitbox();
				shadow.antialiasing = ClientPrefs.globalAntialiasing;
				add(shadow);
		}
	}

	override function createPost(){
		switch(altID){
			case 3:
				shading = new FlxSprite(-800, -299).loadGraphic(Paths.image("eyes_alt3/front"));
				shading.scale.set(1.1, 1.1);
				shading.updateHitbox();
				shading.antialiasing = ClientPrefs.globalAntialiasing;
				add(shading);
			default:
				//none
		}
		comboPosition = [400, 553]; //average of the two characters
		comboPosition[0] -= 0;
		comboPosition[1] -= 300;
		
        dad.alpha = 0.0001;
        if(!handleSpawnAnimationThruEvent){
            spawnIdleEyes();
        }
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 280);
		offsetY = Std.int(dad.getMidpoint().y - 100);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 300);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
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