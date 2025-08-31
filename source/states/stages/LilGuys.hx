package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class LilGuys extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["lilStage"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [lilStage],
			"foreground" => [],
			"special" => [[]]
		];

		return map;
	}

	var lilStage:FlxSprite;
	
	override function create()
	{
		lilStage = new FlxSprite(0,0).loadGraphic(Paths.image("lilStage"));
		add(lilStage);
	}
	
	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 100);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 100);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y);
	}

	override function createPost()
	{
		comboPosition = [241, 146];
		comboPosition[0] += 120;
		comboPosition[1] -= 50;
		comboScale = 0.4;
	}
}