package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Bad extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["butbad/bg", "butbad/back chimney", "butbad/fire loop/fire loop",
						"butbad/chimney", "butbad/chandelier"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, chimney, chimneyback, fire],
			"foreground" => [chandelier],
			"special" => [[]]
		];

		return map;
	}

    var bg:FlxSprite;
    var chimneyback:FlxSprite;
    var fire:FlxSprite;
    var chimney:FlxSprite;
    var chandelier:FlxSprite;

	override function create()
	{
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("butbad/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
        
		chimneyback = new FlxSprite(1267, 694).loadGraphic(Paths.image("butbad/back chimney"));
		chimneyback.antialiasing = ClientPrefs.globalAntialiasing;
		add(chimneyback);
		
		fire = new FlxSprite(1178, 556);
		fire.frames = Paths.getSparrowAtlas('butbad/fire loop/fire loop');
		fire.animation.addByPrefix('I','fire', 24);
		fire.animation.play('I');
		fire.antialiasing = ClientPrefs.globalAntialiasing;
		add(fire);

		chimney = new FlxSprite(1219, 73).loadGraphic(Paths.image("butbad/chimney"));
		chimney.antialiasing = ClientPrefs.globalAntialiasing;
		add(chimney);
	}
	
	override function createPost()
	{
		chandelier = new FlxSprite(1174, -99).loadGraphic(Paths.image("butbad/chandelier"));
		chandelier.antialiasing = ClientPrefs.globalAntialiasing;
		add(chandelier);
	}

	override function update(elapsed:Float)
	{
		offsetX = Std.int(dad.getMidpoint().x);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y);
	}

	override function stepHit()
	{

	}

	override function beatHit()
	{
		
	}

	override function sectionHit()
	{
        
	}
}