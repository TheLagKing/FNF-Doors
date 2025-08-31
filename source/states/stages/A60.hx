package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class A60 extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["a60/bg", "a60/railing",
			"a60/vinnyVinesauce"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, vign],
			"foreground" => [railing],
			"special" => [[]]
		];

		return map;
	}

	//sencounter
    var bg:FlxSprite;
    var railing:FlxSprite;
	var vign:FlxSprite;

	override function create()
	{
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("a60/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
	}

	override function createPost(){
		railing = new FlxSprite(0, 0).loadGraphic(Paths.image("a60/railing"));
		railing.antialiasing = ClientPrefs.globalAntialiasing;
		railing.alpha = 0.4;
		add(railing);

		vign = new FlxSprite(0, 0).loadGraphic(Paths.image("a60/vinnyVinesauce"));
		vign.antialiasing = ClientPrefs.globalAntialiasing;
		add(vign);
	}

	override function update(elapsed:Float)
	{
		offsetX = Std.int(dad.getMidpoint().x + 250);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 260);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 70);
	}
}