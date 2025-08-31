package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Sencounter extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["sencounter/sencounter", "sencounter/sencounter_black",
			"mansion/rain", "mansion/SeekRedoneBG"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, black],
			"foreground" => [],
			"special" => [[]]
		];

		return map;
	}

	//fake seek bg
	var wall:FlxSprite;
	var outside:Rain;

	//sencounter
    var bg:FlxSprite;
    var black:FlxSprite;

	var real:Bool = false;
	var isBlack:Bool = false;

	var dadbaseY:Float = 0.0;
	var bfbaseY:Float = 0.0;

	override function create()
	{
		outside = new Rain(-750, -150, 3000, 1080, [0xFF2f1225, 0xff000000]);
		outside.rainSpeed = 1;
		outside.rainAngle = -10;
        outside.scrollFactor.set(0,0);
		add(outside);

        wall = new FlxSprite(-750, -140).loadGraphic(Paths.image('seekBG/seekBG'));
        wall.scale.set(1.1, 1.1);
        wall.updateHitbox();
		wall.antialiasing = ClientPrefs.globalAntialiasing;
		add(wall);

		bg = new FlxSprite(-750, -140).loadGraphic(Paths.image("sencounter/sencounter"));
		bg.antialiasing = false;
        bg.scale.set(1.1, 1.1);
        bg.updateHitbox();
		bg.alpha = 0.00001;
		add(bg);
        
		black = new FlxSprite(-750, -140).loadGraphic(Paths.image("sencounter/sencounter_black"));
		black.antialiasing = false;
        black.scale.set(1.1, 1.1);
        black.updateHitbox();
		black.alpha = 0.00001;
		add(black);
	}
	
	override function createPost()
	{
		dadbaseY = dad.y;
		bfbaseY = boyfriend.y;
	}

	override function update(elapsed:Float)
	{
		switch(dad.curCharacter.toLowerCase()){
			case "seek":
                offsetX = Std.int(dad.getMidpoint().x + 350);
                offsetY = Std.int(dad.getMidpoint().y - 100);
				bfoffsetX = Std.int(boyfriend.getMidpoint().x - 360);
				bfoffsetY = Std.int(boyfriend.getMidpoint().y - 200);
			case "sencounter_seek":
				offsetX = Std.int(dad.getMidpoint().x + 1000);
				offsetY = Std.int(dad.getMidpoint().y + 500);
				bfoffsetX = Std.int(dad.getMidpoint().x + 900);
				bfoffsetY = Std.int(dad.getMidpoint().y + 300);
			case "sencounter_black":
				offsetX = Std.int(dad.getMidpoint().x + 1000);
				offsetY = Std.int(dad.getMidpoint().y + 500);
				bfoffsetX = Std.int(dad.getMidpoint().x + 900);
				bfoffsetY = Std.int(dad.getMidpoint().y + 300);
		}

		if(real){
			dad.y = FlxMath.lerp(dad.y, dadbaseY, CoolUtil.boundTo(elapsed*6, 0, 1));
			boyfriend.y = FlxMath.lerp(boyfriend.y, bfbaseY, CoolUtil.boundTo(elapsed*6, 0, 1));
		}
	}

	override function stepHit()
	{

	}

	override function beatHit()
	{
		if(real){
			dad.y += 15;
			boyfriend.y += 15;
		}
	}

	override function sectionHit()
	{
	}

	
    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName)
			{
				case "Change Character":
					dadbaseY = dad.y;
					bfbaseY = boyfriend.y;

				case "sen_real":
					remove(outside);
					remove(wall);
					bg.alpha = 1;
					real = true;

				case "sen_black":
					isBlack = !isBlack;

					if(isBlack){
						bg.alpha = 0.0001;
						black.alpha = 1;
					} else {
						bg.alpha = 1;
						black.alpha = 0.0001;
					}
			}
		}
}