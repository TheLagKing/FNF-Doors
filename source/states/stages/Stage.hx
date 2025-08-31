package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Stage extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["stageback", "stagefront", "stage_light",
						"stagecurtains"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg],
			"foreground" => [stageFront, stageLight, stageLight2, stageCurtains],
			"special" => [[]]
		];

		return map;
	}

	var bg:BGSprite;
	var stageFront:BGSprite;
	var stageLight:BGSprite;
	var stageLight2:BGSprite;
	var stageCurtains:BGSprite;

	override function create()
	{
		bg = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);
		if(!ClientPrefs.data.lowQuality) {
			stageLight = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
			stageLight.scale.set(1.1);
			stageLight.updateHitbox();
			add(stageLight);

			stageLight2 = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
			stageLight2.scale.set(1.1);
			stageLight2.updateHitbox();
			stageLight2.flipX = true;
			add(stageLight2);

			stageCurtains = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
	}
}