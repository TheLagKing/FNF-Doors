package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Library extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["figure/nofront", "figure/front", "figure/lantern"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback],
			"foreground" => [lamp],
			"special" => [[stagefront, 0.4]]
		];

		return map;
	}

	var stagefront:BGSprite;
	var stageback:BGSprite;
	var lamp:BGSprite;

	override function create()
	{
		stageback = new BGSprite('figure/nofront', -750, -140, 1, 1);
		stageback.scale.set(1.6, 1.6);
		stageback.updateHitbox();
		add(stageback);
	}
	
	override function createPost()
	{
		stagefront = new BGSprite('figure/front', -750, -140, 1, 1);
		stagefront.scale.set(1.6, 1.6);
		stagefront.updateHitbox();
		add(stagefront);

		lamp = new BGSprite('figure/lantern', -100, -400, 1, 1);
		lamp.scale.set(1.6, 1.6);
		lamp.updateHitbox();
		add(lamp);

		comboPosition = [635, 657];
		comboPosition[0] += 100;
		comboPosition[1] -= 0;
		comboScale = 0.5;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 300);
		offsetY = Std.int(dad.getMidpoint().y - 50);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 200);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
	}

}