package states.stages;

import flixel.math.FlxRandom;
import flixel.group.FlxGroup;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class RushGreenhouse extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [];
		theMap = [
			"images" => ["rush/greenhouse/bg", "rush/greenhouse/bg_lightning", 
						"rush/greenhouse/george_w_bush", "rush/greenhouse/shade",
						"rush_fog"]
		];

		return theMap;
	}

	
	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg],
			"foreground" => [bush, shade],
			"special" => [[fog, 0.6]]
		];

		return map;
	}

	var bg:FlxSprite;
	var bgthunder:FlxSprite;
	var bush:FlxSprite;
	var shade:FlxSprite;
	var fog:BGSprite;
	var fullWhite:FlxSprite;

	override function create()
	{		
		game.isGreenhouseStage = true;
		
		bg = new FlxSprite(-750, -140).loadGraphic(Paths.image("rush/greenhouse/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		bgthunder = new FlxSprite(-750, -140).loadGraphic(Paths.image("rush/greenhouse/bg_lightning"));
		bgthunder.antialiasing = ClientPrefs.globalAntialiasing;
		bgthunder.alpha = 0.00001;
		add(bgthunder);

		fullWhite = new FlxSprite(-750, -140).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.WHITE);
		fullWhite.alpha = 0.00001;
		add(fullWhite);

		boyfriendGroup.visible = false;

		fog = new BGSprite('rush_fog', 0, 0, 1.0, 1.0,['Occurrence Symbole 1 1'], true);
		fog.alpha = 1;
		fog.scale.set(0.64, 0.64);
		fog.updateHitbox();
		fog.screenCenter();
		fog.x -= 490;
		fog.y -= 20;
		fog.color = 0xFF000000;
		add(fog);
	}

	override function createPost(){
		bush = new FlxSprite(-750, -140).loadGraphic(Paths.image("rush/greenhouse/george_w_bush"));
		bush.antialiasing = ClientPrefs.globalAntialiasing;
		add(bush);

		shade = new FlxSprite(-750, -140).loadGraphic(Paths.image("rush/greenhouse/shade"));
		shade.antialiasing = ClientPrefs.globalAntialiasing;
		add(shade);

		dad.color = 0xff6c6c6c;

		comboPosition = [84, 341]; //average of the two characters
		comboPosition[0] -= 400;
		comboPosition[1] -= 100;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 305);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(dad.getMidpoint().x + 305);
		bfoffsetY = Std.int(dad.getMidpoint().y);

		thunderCooldown -= elapsed;
	}

	var thunderCooldown:Float = 0;
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
		FlxTween.color(dad, 3.0, 0xFFFFFFFF, 0xFF6c6c6c, {ease: FlxEase.expoOut});
	}
}