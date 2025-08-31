package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Mutant extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["mutant/mutantcum", "mutant/mutantnocum", "mutant/splat",
						"mutant/web"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, bgcum],
			"foreground" => [boxes, splat, web],
			"special" => [[]]
		];

		return map;
	}

    var bg:FlxSprite;
    var bgcum:FlxSprite;
	var boxes:FlxSprite;
    var splat:FlxSprite;
    var web:FlxSprite;

	override function create()
	{
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("mutant/mutantnocum"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.scale.set(1.3, 1.3);
		bg.updateHitbox();

		bgcum = new FlxSprite(0, 0).loadGraphic(Paths.image("mutant/mutantcum"));
		bgcum.antialiasing = ClientPrefs.globalAntialiasing;
		//add(bgcum);
		bgcum.scale.set(1.3, 1.3);
		bgcum.updateHitbox();
	}
	
	override function createPost()
	{
		boxes = new FlxSprite(0, 0).loadGraphic(Paths.image("mutant/boxes"));
		boxes.antialiasing = ClientPrefs.globalAntialiasing;
		add(boxes);
		boxes.scale.set(1.3, 1.3);
		boxes.updateHitbox();

		splat = new FlxSprite(0, 0).loadGraphic(Paths.image("mutant/splat"));
		splat.antialiasing = ClientPrefs.globalAntialiasing;
		add(splat);
		splat.scale.set(1.3, 1.3);
		splat.updateHitbox();

		web = new FlxSprite(0, 0).loadGraphic(Paths.image("mutant/web"));
		web.antialiasing = ClientPrefs.globalAntialiasing;
		add(web);
		web.scale.set(1.3, 1.3);
		web.updateHitbox();
	}

	override function update(elapsed:Float)
	{
		offsetX = Std.int(dad.getMidpoint().x);
		offsetY = Std.int(dad.getMidpoint().y - 150);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 40);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 20);
	}

	override function stepHit()
	{

	}

	override function beatHit()
	{
		if(curBeat == 404){
			remove(bg);
			add(bgcum);
		}
	}

	override function sectionHit()
	{
        
	}
}