package states.stages;

import flixel.FlxBasic;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class BargainBG extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["bargainBG/JeffShopBG", "bargainBG/lights", "bargainBG/table",
						"bargainBG/bfChair", "bargainBG/bobChair", "bargainBG/goblinoChair",
						"bargainBG/shadow", "bargainBG/jeffTable"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback],
			"foreground" => [table, shading],
			"special" => [[tableBox, 0.2], [goblinoChair, 0.4], [bfChair, 0.4], [bobChair, 0.4], [shadow, 0.4]]
		];

		return map;
	}

	var stageback:BGSprite;
	var tableBox:BGSprite;
	var shadow:BGSprite;
	var goblinoChair:BGSprite;
	var bfChair:BGSprite;
	var bobChair:BGSprite;
	var table:BGSprite;
	var shading:BGSprite;
	var bargainAlphaState:Bool = true; //True = opaque, False = transparent

	var badAppleWhite:FlxSprite;

	override function create()
	{
		this.hasMom = true;
		//background
		stageback = new BGSprite('bargainBG/JeffShopBG', 0, 0, 1, 1);
		tableBox = new BGSprite('bargainBG/jeffTable', 862, 914, 1, 1);

		shadow = new BGSprite('bargainBG/shadow', 438, 1238, 1, 1);
		goblinoChair = new BGSprite('bargainBG/goblinoChair', 1667, 655, 1, 1);
		bobChair = new BGSprite('bargainBG/bobChair', 471, 655, 1, 1);
		bfChair = new BGSprite('bargainBG/bfChair', 1214, 600, 1, 1);
		
		add(stageback);

		table = new BGSprite('bargainBG/table', 786, 971, 1, 1);
		shading = new BGSprite('bargainBG/lights', 0, 0, 1, 1);
	}
	
	override function createPost()
	{
		remove(boyfriendGroup);
		remove(gfGroup);
		remove(dadGroup);
		remove(momGroup);
		add(dadGroup);
		add(tableBox);
		
		add(shadow);
		
		add(goblinoChair);
		add(bfChair);
		
		add(bobChair);
		add(momGroup);

		add(boyfriendGroup);
		add(gfGroup);

		add(table);
		add(shading);

		comboPosition = [820, 547];
		comboPosition[0] += 350;
		comboPosition[1] -= 0;

		if(PlayState.SONG.song.toLowerCase() == "dead-serious"){
			game.iconP2.changeIcon("bob");
			PlayState.instance.healthBar.backColorTransform.color = 0xFFCCB489;
			PlayState.instance.healthBar.updateBar();
		}
	}

	override function update(elapsed:Float){
		if (PlayState.SONG.song.toLowerCase() == 'dead-serious'){
			offsetX = Std.int(gf.getMidpoint().x - 600);
			offsetY = Std.int(gf.getMidpoint().y);
			bfoffsetX = Std.int(gf.getMidpoint().x - 550);
			bfoffsetY = Std.int(gf.getMidpoint().y - 220);
		} else {
			offsetX = Std.int(gf.getMidpoint().x - 400);
			offsetY = Std.int(gf.getMidpoint().y);
			bfoffsetX = Std.int(gf.getMidpoint().x - 550);
			bfoffsetY = Std.int(gf.getMidpoint().y - 220);
		}
	}
	//badApple
	
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName)
			{
				case 'bargainJeffAlpha':
					var thingsToAlpha:Array<Dynamic> = [];
					thingsToAlpha = [bfChair, bobChair, table];
					if(bargainAlphaState){
						for (t in thingsToAlpha){
							FlxTween.tween(t, {alpha: 0.4}, 0.6);
						}
						bargainAlphaState = false;
					} else {
						for (t in thingsToAlpha){
							FlxTween.tween(t, {alpha: 1}, 0.6);
						}
						bargainAlphaState = true;
					}

				case "Change Character":
					if(PlayState.SONG.song.toLowerCase() == "dead-serious"){
						PlayState.instance.healthBar.backColorTransform.color = 0xFFCCB489;
						PlayState.instance.healthBar.updateBar();
					}
			}
		}
}