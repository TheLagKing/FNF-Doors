package states.stages;

import openfl.display.BlendMode;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class Lobby extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["lobbyShadow", "LobbyBG", "static"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [stageback],
			"foreground" => [staticc, shadow],
			"special" => [[]]
		];

		return map;
	}

	var staticc:BGSprite;
	var stageback:FlxSprite;
	var stagefront:FlxSprite;
	
	var fire:FlxSprite;

	var shadow:FlxSprite;
	var gfShadow:FlxSprite;

	override function create()
	{
		stageback = new FlxSprite(-500, -40).loadGraphic(Paths.image("guidanceBG/background"));
		stageback.antialiasing = ClientPrefs.globalAntialiasing;
		add(stageback);
		
		fire = new FlxSprite(720, 720);
		fire.frames = Paths.getSparrowAtlas("guidanceBG/fire");
		fire.animation.addByPrefix("idle", "idle0", 8, true);
		fire.animation.play("idle");
		fire.scale.set(0.1, 0.1);
		fire.updateHitbox();
		fire.antialiasing = ClientPrefs.globalAntialiasing;
		add(fire);
		
		stagefront = new FlxSprite(-500, -40).loadGraphic(Paths.image("guidanceBG/foreground"));
		stagefront.antialiasing = ClientPrefs.globalAntialiasing;
		add(stagefront);

		shadow = new FlxSprite(935, 1055).loadGraphic(Paths.image("lobbyShadow"));
		shadow.alpha = 0.4;
		shadow.scale.set(0.6, 1);
		shadow.updateHitbox();
		shadow.antialiasing = ClientPrefs.globalAntialiasing;
		add(shadow);

		gfShadow = new FlxSprite(745, 945).loadGraphic(Paths.image("lobbyShadow"));
		gfShadow.alpha = 0.4;
		gfShadow.scale.set(0.5, 0.9);
		gfShadow.updateHitbox();
		gfShadow.antialiasing = ClientPrefs.globalAntialiasing;
		add(gfShadow);

		staticc = new BGSprite('static', -750, -140, 1, 1, ['static idle'], true);
		staticc.scale.set(1.6, 1.6);
		staticc.updateHitbox();
		staticc.alpha = 0.7;
		add(staticc);
	}

	override function createPost(){
		if(PlayState.SONG.song.toLowerCase() == "guidance" || PlayState.SONG.song.toLowerCase() == "guidance-hell") {
			FlxTween.tween(dad, {alpha : 0.8}, 16);
			FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFF9B9B9B);
			FlxTween.color(gf, 0.6, gf.color, 0xFF9B9B9B);
		}

		comboPosition = [558, 845];
		comboPosition[0] += 200;
		comboPosition[1] -= 250;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 240);
		offsetY = Std.int(dad.getMidpoint().y + 300);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 100);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
	}
	
	override function stepHit()
	{
		if(PlayState.SONG.song.toLowerCase() == "guidance") {
			if (curStep == 128){
				FlxTween.tween(staticc, {alpha : 0}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFFFFFFF);
				FlxTween.color(gf, 0.6, gf.color, 0xFFFFFFFF);
			}
			if (curStep == 768){
				FlxTween.tween(staticc, {alpha : 0.7}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFF9B9B9B);
				FlxTween.color(gf, 0.6, gf.color, 0xFF9B9B9B);
				FlxTween.tween(dad, {alpha : 0}, 20);
			}
		} else if (PlayState.SONG.song.toLowerCase() == "guidance-hell"){
			if (curStep == 128){
				FlxTween.tween(staticc, {alpha : 0}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFFFFFFF);
				FlxTween.color(gf, 0.6, gf.color, 0xFFFFFFFF);
			}
			if (curStep == 768){
				FlxTween.tween(staticc, {alpha : 0.7}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFF9B9B9B);
				FlxTween.color(gf, 0.6, gf.color, 0xFF9B9B9B);
				FlxTween.tween(dad, {alpha : 0.3}, 0.6);
			}
			if (curStep == 896){
				FlxTween.tween(staticc, {alpha : 0.5}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFABABAB);
				FlxTween.color(gf, 0.6, gf.color, 0xFFABABAB);
				FlxTween.tween(dad, {alpha : 0.5}, 0.6);
			}
			if (curStep == 960){
				FlxTween.tween(staticc, {alpha : 0.3}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFCBCBCB);
				FlxTween.color(gf, 0.6, gf.color, 0xFFCBCBCB);
				FlxTween.tween(dad, {alpha : 0.6}, 0.6);
			}
			if (curStep == 1088){
				FlxTween.tween(staticc, {alpha : 0.0}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFFFFFFF);
				FlxTween.color(gf, 0.6, gf.color, 0xFFFFFFFF);
				FlxTween.tween(dad, {alpha : 0.8}, 0.6);
			}
			if (curStep == 1999){
				PlayState.instance.camGame.flash(FlxColor.CYAN, 3, null, true);
				FlxTween.tween(staticc, {alpha : 1.0}, 0.6);
				FlxTween.tween(dad, {alpha : 1.0}, 0.6);
				dad.blend = BlendMode.MULTIPLY;
				boyfriend.blend = BlendMode.ADD;
			}
			if (curStep == 2256){
				PlayState.instance.camGame.flash(FlxColor.CYAN, 3, null, true);
				FlxTween.tween(staticc, {alpha : 0.4}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFFCBCBCB);
				FlxTween.color(gf, 0.6, gf.color, 0xFFCBCBCB);
				FlxTween.tween(dad, {alpha : 0.8}, 0.6);
				dad.blend = BlendMode.HARDLIGHT;
				boyfriend.blend = BlendMode.NORMAL;
			}
			if (curStep == 2544){
				FlxTween.tween(staticc, {alpha : 0.9}, 0.6);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFF7B7B7B);
				FlxTween.color(gf, 0.6, gf.color, 0xFF7B7B7B);
				FlxTween.tween(dad, {alpha : 0.0}, 1.3);
			}
		}
	}
}
