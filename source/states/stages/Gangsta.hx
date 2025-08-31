package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Gangsta extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["gangsta/wall", "gangsta/store", "gangsta/tables",
						"gangsta/windows", "gangsta/suit-goblino-new", "gangsta/figureBG",
						"gangsta/eyesBG", "gangsta/timothyBG"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback, storefront],
			"foreground" => [windows],
			"special" => [[tables, 0.1], [timothy, 0.6], [goblino, 0.4], [figure, 0.6], [eyes, 0.6]]
		];

		return map;
	}

	var stageback:BGSprite;
	var storefront:BGSprite;
	var tables:BGSprite;
	var windows:BGSprite;

	var timothy:BGSprite;
	var goblino:BGSprite;
	var figure:BGSprite;
	var eyes:BGSprite;
	
	override function create()
	{
		stageback = new BGSprite('gangsta/wall', 0, 0, 1, 1);
		storefront = new BGSprite('gangsta/store', 0, 0, 1, 1);
		tables = new BGSprite('gangsta/tables', 115, 434, 1, 1);
		windows = new BGSprite('gangsta/windows', 66, 333, 1, 1);
		windows.alpha = 0.5;

		goblino = new BGSprite('gangsta/suit-goblino-new', 1314, 361, 1, 1, ["el-goblino-business"]);
		goblino.setGraphicSize(106, 141);
		goblino.updateHitbox();

		figure = new BGSprite('gangsta/figureBG', 540, 229, 1, 1, ["figure"]);
		figure.setGraphicSize(199, 537);
		figure.updateHitbox();

		eyes = new BGSprite('gangsta/eyesBG', 1344, 283, 1, 1, ["gangsta-eyes"], true);
		eyes.setGraphicSize(508, 469);
		eyes.updateHitbox();

		timothy = new BGSprite('gangsta/timothyBG', 878, 570, 1, 1, ["timothy"]);
		timothy.setGraphicSize(172, 145);
		timothy.updateHitbox();

		add(stageback);
		add(goblino);
		add(tables);
		add(windows);
		add(storefront);
		add(timothy);
		add(figure);
		add(eyes);
	}

	override function beatHit()
	{
		goblino.dance(true);
		figure.dance(true);
		timothy.dance(true);
	}

}