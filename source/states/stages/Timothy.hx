package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Timothy extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["timothy/timothy-bg-"+currentColor, "timothy/painting", "timothy/shine2",
						"timothy/darkness"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg],
			"foreground" => [dark, painting, shine],
			"special" => [[]]
		];

		return map;
	}

	public static var altID:Int = 0;

	public static var currentColor:String = "red";

	var rain:Rain;
	var bg:FlxSprite;
	var dark:FlxSprite;
	var painting:FlxSprite;
	var shine:FlxSprite;

	var possibleColors = ["red", "green", "blue", "purple"];

	override function create()
	{
		switch(altID){
			case 0: rain = new Rain(0, 0, 1920, 1080, [0xFF222057, 0xFF000000]);
			case 1: 
				rain = new Rain(0, 0, 1920, 1080, [0xFF222057, 0xFF000000]);
				rain.rainSpeed = 1;
				rain.rainAngle = -5;
				add(rain);
			default: rain = new Rain(0, 0, 1920, 1080, [0xFF222057, 0xFF000000]);
		}

		if(PlayState.isStoryMode){
			switch(altID){
				case 0: bg = new FlxSprite().loadGraphic(Paths.image("timothy/timothy-bg-"+DoorsUtil.curRun.currentRoom.room.roomColor));
				case 1: bg = new FlxSprite().loadGraphic(Paths.image("timothy_alt/timothy-bg-"+DoorsUtil.curRun.currentRoom.room.roomColor));
				default: bg = new FlxSprite().loadGraphic(Paths.image("timothy/timothy-bg-"+DoorsUtil.curRun.currentRoom.room.roomColor));
			}
		} else {
			switch(altID){
				case 0: bg = new FlxSprite().loadGraphic(Paths.image("timothy/timothy-bg-"+FlxG.random.getObject(possibleColors)));
				case 1: bg = new FlxSprite().loadGraphic(Paths.image("timothy_alt/timothy-bg-"+FlxG.random.getObject(possibleColors)));
				default: bg = new FlxSprite().loadGraphic(Paths.image("timothy/timothy-bg-"+FlxG.random.getObject(possibleColors)));
			}
		}
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		
		switch(altID){
			case 0: painting = new FlxSprite(-50, -42).loadGraphic(Paths.image("timothy/painting"));
			case 1: painting = new FlxSprite(-5000, -5000).makeGraphic(1, 1, 0xFF000000);
			default: painting = new FlxSprite(-50, -42).loadGraphic(Paths.image("timothy/painting"));
		}
		painting.antialiasing = ClientPrefs.globalAntialiasing;

		add(bg);
		add(painting);
	}
	
	override function createPost()
	{
		switch(altID){
			case 0: shine = new FlxSprite(479, -510).loadGraphic(Paths.image("timothy/shine2"));
			case 1: shine = new FlxSprite(0, 0).loadGraphic(Paths.image("timothy_alt/front"));
			default: shine = new FlxSprite(479, -510).loadGraphic(Paths.image("timothy/shine2"));
		}
		shine.antialiasing = ClientPrefs.globalAntialiasing;
		
		switch(altID){
			case 0: dark = new FlxSprite().loadGraphic(Paths.image("timothy/darkness"));
			case 1: dark = new FlxSprite(-5000, -5000).makeGraphic(1, 1, 0xFF000000);
			default: dark = new FlxSprite().loadGraphic(Paths.image("timothy/darkness"));
		}
		dark.antialiasing = ClientPrefs.globalAntialiasing;


		if(altID == 0){
			PlayState.instance.remove(PlayState.instance.dadGroup);
			PlayState.instance.remove(PlayState.instance.gfGroup);
			PlayState.instance.gfGroup.x += 65;
			PlayState.instance.gfGroup.y -= 40;
			PlayState.instance.add(PlayState.instance.gfGroup);
			PlayState.instance.add(PlayState.instance.dadGroup);
		}
		
		add(shine);
		add(dark);

        comboPosition = [1050, 441];
	}
	
	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 400);
		offsetY = Std.int(dad.getMidpoint().y + 100);
		
		bfoffsetX = Std.int(dad.getMidpoint().x + 300);
		bfoffsetY = Std.int(dad.getMidpoint().y + 20);

		/*
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 300);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y + 400);
		*/
	}
}