package states.stages;

import flxanimate.FlxAnimate;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class Jack extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["jack/background", "jack/book-shelf", "jack/clock",
						"jack/lamp", "jack/pole", "jack/intro anim"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, bookshelf, clock, pole, lamp],
			"foreground" => [],
			"special" => [[jackIntro, 0.6]]
		];

		return map;
	}

	var bg:FlxSprite;
	var bookshelf:FlxSprite;
	var clock:FlxSprite;
	var lamp:FlxSprite;
	var pole:FlxSprite;
	var jackIntro:FlxSprite;
	override function create()
	{
		bg = new FlxSprite(0,0).loadGraphic(Paths.image("jack/background"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		bookshelf = new FlxSprite(118, 114).loadGraphic(Paths.image("jack/book-shelf"));
		bookshelf.antialiasing = ClientPrefs.globalAntialiasing;
		
		clock = new FlxSprite(979, 100).loadGraphic(Paths.image("jack/clock"));
		clock.antialiasing = ClientPrefs.globalAntialiasing;

		lamp = new FlxSprite(754, 222).loadGraphic(Paths.image("jack/lamp"));
		lamp.antialiasing = ClientPrefs.globalAntialiasing;

		pole = new FlxSprite(386, 0).loadGraphic(Paths.image("jack/pole"));
		pole.antialiasing = ClientPrefs.globalAntialiasing;

		add(bg);
		add(bookshelf);
		add(clock);
		add(lamp);
		add(pole);

		var jackBlack = new FlxSprite(529, 209).makeSolid(223, 320, FlxColor.BLACK);
		add(jackBlack);
		
		boyfriendGroup.visible = false;
	}

	override function createPost(){
		jackIntro = new FlxSprite(415, 150);
		jackIntro.frames = Paths.getSparrowAtlas("jack/intro anim");
		jackIntro.animation.addByPrefix("intro", "closet-anim", 24, false, false, false);
		jackIntro.antialiasing = ClientPrefs.globalAntialiasing;
		add(jackIntro);

		comboPosition = [225, 363];
		comboPosition[0] += 200;
		comboPosition[1] -= 100;
		comboScale = 0.5;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(640);
		offsetY = Std.int(360);
		bfoffsetX = Std.int(640);
		bfoffsetY = Std.int(360);
	}

	
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName)
			{
				case "jack_intro":
					jackIntro.animation.play("intro", true, false);
					new FlxTimer().start(0.8, function(tmr){
						FlxTween.tween(PlayState.instance.iconP2, {alpha: 1}, 0.4);
					});

				case "jack_close":
					jackIntro.animation.play("intro", true, true);
					new FlxTimer().start(1.8, function(tmr){
						FlxTween.tween(PlayState.instance.iconP2, {alpha: 0}, 0.4);
					});
			}
	}
}