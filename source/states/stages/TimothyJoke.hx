package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class TimothyJoke extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["Timothy_bg", "Timothy_circle"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback],
			"foreground" => [stagefront],
			"special" => [[]]
		];

		return map;
	}

	var stagefront:BGSprite;
	var stageback:BGSprite;

	override function create()
	{
		stageback = new BGSprite('Timothy_bg', -900, -100, 1.0, 1.0);
		add(stageback);
	}
	
	override function createPost()
	{
		stagefront = new BGSprite('Timothy_circle', -500, 0, 1, 1);
		stagefront.scale.set(0.7, 0.7);
		stagefront.updateHitbox();
		add(stagefront);

		comboPosition = [0, 435];
		comboPosition[0] += 250;
		comboPosition[1] -= 120;
	}

	override function stepHit(){
		if(PlayState.SONG.song.toLowerCase() == "angry-spider"){
			if(curStep == 3784){
				var spyJumpscare:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("spyJumpscare"));
				spyJumpscare.setGraphicSize(0, FlxG.height);
				spyJumpscare.updateHitbox();
				spyJumpscare.cameras = [PlayState.instance.camHUD];
				spyJumpscare.screenCenter();
				add(spyJumpscare);
			}
		}
	}

	override function update(elapsed:Float){
		offsetX = 22;
		offsetY = 410;
		if(boyfriend.isAnimateAtlas){
			bfoffsetX = -78;
			bfoffsetY = 210;
		} else {
			bfoffsetX = 22;
			bfoffsetY = 410;
		}
	}
}