package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;
import shaders.HeatwaveShader;
import openfl.filters.ShaderFilter;

class Figure100 extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["figure100/bg", "figure100/fg", "figure100/bg-fire", "figure100/fg-fire",
		"figure100/fire1/fire", "figure100/fire2/fire", "figure100/fire3/fire"]
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

	var fire1:FlxSprite;
	var fire2:FlxSprite;
	var fire3:FlxSprite;

	var fireShader:HeatwaveShader;
	var fireFilter:ShaderFilter;

	override function create()
	{
		stageback = new BGSprite('figure100/bg', -750, -140, 1, 1);
		add(stageback);

		if(ClientPrefs.data.shaders){
			fireShader = new HeatwaveShader();
			add(fireShader);
			fireFilter = new ShaderFilter(fireShader.shader);
		}

		fire2 = new FlxSprite();
		fire2.frames = Paths.getSparrowAtlas("figure100/fire2/fire");
		fire2.scale.set(0.434, 0.434);
		fire2.updateHitbox();
		fire2.setPosition(58-750, 393-140);
		fire2.antialiasing = ClientPrefs.globalAntialiasing;
		fire2.animation.addByPrefix("idle", "fire", 8, true);
		fire2.animation.play("idle");
		fire2.alpha = 0.0001;
		add(fire2);

		PlayState.instance.addCharacterToList("figure100-fire", 1);
		PlayState.instance.addCharacterToList("door100bf-fire", 0);
	}
	
	override function createPost()
	{
		stagefront = new BGSprite('figure100/fg', -750, -140, 1, 1);
		add(stagefront);

		fire1 = new FlxSprite();
		fire1.frames = Paths.getSparrowAtlas("figure100/fire1/fire");
		fire1.scale.set(0.446, 0.446);
		fire1.updateHitbox();
		fire1.setPosition(115-750, 424-140);
		fire1.antialiasing = ClientPrefs.globalAntialiasing;
		fire1.animation.addByPrefix("idle", "fire", 8, true);
		fire1.animation.play("idle");
		fire1.alpha = 0.0001;
		add(fire1);

		fire3 = new FlxSprite();
		fire3.frames = Paths.getSparrowAtlas("figure100/fire3/fire");
		fire3.scale.set(0.433, 0.433);
		fire3.updateHitbox();
		fire3.setPosition(209-750, 500-140);
		fire3.antialiasing = ClientPrefs.globalAntialiasing;
		fire3.animation.addByPrefix("idle", "fire", 8, true);
		fire3.animation.play("idle");
		fire3.alpha = 0.0001;
		add(fire3);

		comboPosition = [635, 657];
		comboPosition[0] += 100;
		comboPosition[1] -= 400;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 250);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 200);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 100);
	}

	function switchToFire() {
		stageback.loadGraphic(Paths.image("figure100/bg-fire"));
		stagefront.loadGraphic(Paths.image("figure100/fg-fire"));
		if(ClientPrefs.data.shaders){
			PlayState.instance.camGameFilters.push(fireFilter);
			PlayState.instance.updateCameraFilters("camGame");
		}
		PlayState.instance.triggerEventNote("Change Character", "dad", "figure100-fire", 0.0);
		PlayState.instance.triggerEventNote("Change Character", "bf", "door100bf-fire", 0.0);
		fire1.alpha = 1;
		fire2.alpha = 1;
		fire3.alpha = 1;
	}

	override function beatHit() {
		switch(PlayState.SONG.song){
			case "hyperacusis":
				if(curBeat == 799){
					switchToFire();
				}
			case "imperceptible":
				if(curBeat == 368){
					switchToFire();
				}
		}
	}
}