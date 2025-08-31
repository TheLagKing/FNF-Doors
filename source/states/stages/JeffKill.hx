package states.stages;

import shaders.RainShader;

import backend.BaseStage;
import backend.BaseStage.Countdown;

#if !flash 
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
#end

class JeffKill extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["jeff-kill/jeffbgwip", "jeff-kill/treewip"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg],
			"foreground" => [fg],
			"special" => [[]]
		];

		return map;
	}

	var bg:FlxSprite;
	var fg:FlxSprite;
	var text:FlxSprite;
	var endText:FlxSprite;
	
	override function create()
	{
		bg = new FlxSprite(0,0).loadGraphic(Paths.image("jeff-kill/jeffbgwip"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scale.set(1.5, 1.5);
		bg.updateHitbox();
		add(bg);
	}

	var rain:RainShader;
	override function createPost()
	{

		fg = new FlxSprite(0,0).loadGraphic(Paths.image("jeff-kill/treewip"));
		fg.antialiasing = ClientPrefs.globalAntialiasing;
		fg.scale.set(1.5, 1.5);
		fg.updateHitbox();
		fg.scrollFactor.set(1.1, 1.0);
		add(fg);

		if (ClientPrefs.data.shaders) {
			rain = new RainShader();
			rain.scale = FlxG.height / 200;
			rain.intensity = 0.1;

			var filter:ShaderFilter = new ShaderFilter(rain);
			PlayState.instance.camGameFilters.insert(PlayState.instance.camGameFilters.indexOf(cast(PlayState.instance.vignetteShader.shader, BitmapFilter)), filter);
			PlayState.instance.updateCameraFilters('camGame');
		}

		text = new FlxSprite(0,0);
		text.frames = Paths.getSparrowAtlas("jeff-kill/go_to_sleep");
		text.animation.addByPrefix("idle", "the-text instance 1", 24, true);
		text.animation.play("idle");
		text.antialiasing = ClientPrefs.globalAntialiasing;
		text.alpha = 0.0001;
		text.cameras = [PlayState.instance.camOther];
		text.scale.set(0.8, 0.8);
		text.updateHitbox();
		text.screenCenter();
		add(text);

		endText = new FlxSprite(0,0);
		endText.frames = Paths.getSparrowAtlas("jeff-kill/goodnight");
		endText.animation.addByPrefix("idle", "good-night-animated instance 1", 24, true);
		endText.animation.play("idle");
		endText.antialiasing = ClientPrefs.globalAntialiasing;
		endText.alpha = 0.0001;
		endText.cameras = [PlayState.instance.camOther];
		endText.scale.set(0.8, 0.8);
		endText.updateHitbox();
		endText.screenCenter();
		add(endText);

        if(ClientPrefs.data.shaders){
			@:privateAccess PlayState.instance.vignetteShader.extent = 1.5;
			@:privateAccess PlayState.instance.vignetteShader.darkness = 15.0;
		}
	}

	override function beatHit(){
		if(curBeat == 64){ //screen goes black
			PlayState.instance.camHUD.fade(0xFF000000, 0.0001, false, null, true);
			text.alpha = 1;
		}
		if(curBeat == 68){ //in black screen
			if(ClientPrefs.data.shaders){
				@:privateAccess PlayState.instance.vignetteShader.extent = 0.25;
				@:privateAccess PlayState.instance.vignetteShader.darkness = 23.0;
			}
		}
		if(curBeat == 72){ //screen goes back
			text.alpha = 0.0001;
			remove(text);
			PlayState.instance.camHUD.fade(0xFF000000, 0.0001, true, null, true);
		}
		if(curBeat == 466){ //in black screen
			if(ClientPrefs.data.shaders){
				@:privateAccess PlayState.instance.vignetteShader.extent = 2;
				@:privateAccess PlayState.instance.vignetteShader.darkness = 10.0;
			}
		}
	}

	override function stepHit(){
		if(curStep == 1866){
			FlxTween.tween(PlayState.instance.camHUD, {alpha: 0.0001}, Conductor.crochet / 1000 * 4, {ease: FlxEase.smoothStepInOut});
		}
		if(curStep == 1944){
			FlxTween.tween(endText, {alpha: 0.0001}, 1, {ease: FlxEase.smoothStepInOut});
		}
		if(curStep == 2026){
			FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 0.0001);
			PlayState.instance.camHUD.fade(0xFF000000, 0.0001, false, null, true);
			endText.alpha = 1;
		}
	}

	override function update(elapsed:Float){
		if(rain != null)
		{
			rain.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			rain.update(elapsed);
		}

		offsetX = Std.int(dad.getMidpoint().x + 200);
		offsetY = Std.int(dad.getMidpoint().y + 300);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 100);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);

		super.update(elapsed);
	}
}