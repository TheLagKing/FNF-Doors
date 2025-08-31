package states.stages;

import backend.BaseStage;
import backend.BaseStage.Countdown;

class Glitch extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["glitch/back", "glitch/front", "glitch/chandelier",
						"glitch/shading", "characters/glitch/GlitchHands",
						"characters/glitch/GlitchHandsGlitched"]
		];

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [back, glitchHands, glitchHandsGlitched],
			"foreground" => [shading, chandelier],
			"special" => [[front, 0.6]]
		];

		return map;
	}


	var front:FlxSprite;
	var chandelier:FlxSprite;
	var shading:FlxSprite;
	var back:FlxSprite;

	var glitchHands:FlxSprite;
	var glitchHandsGlitched:FlxSprite;

	override function create()
	{
		back = new FlxSprite(0, 0).loadGraphic(Paths.image("glitch/back"));
		back.antialiasing = ClientPrefs.globalAntialiasing;
		back.scale.set(1.6, 1.6);
		back.updateHitbox();
		add(back);

		front = new FlxSprite(0, 0).loadGraphic(Paths.image("glitch/front"));
		front.antialiasing = ClientPrefs.globalAntialiasing;
		front.scale.set(1.6, 1.6);
		front.updateHitbox();

		chandelier = new FlxSprite(871*1.6, 0).loadGraphic(Paths.image("glitch/chandelier"));
		chandelier.antialiasing = ClientPrefs.globalAntialiasing;
		chandelier.scale.set(1.6, 1.6);
		chandelier.updateHitbox();

		shading = new FlxSprite(0, 0).loadGraphic(Paths.image("glitch/shading"));
		shading.antialiasing = ClientPrefs.globalAntialiasing;
		shading.scale.set(1.6, 1.6);
		shading.updateHitbox();

		glitchHands = new FlxSprite(1400, 800);
		glitchHands.frames = Paths.getSparrowAtlas("characters/glitch/GlitchHands");
		glitchHands.animation.addByPrefix("idle", "Idle Hands", 24, true);
		glitchHands.alpha = 0.00001;
		glitchHands.animation.play("idle");
		
		glitchHandsGlitched = new FlxSprite(1400, 800);
		glitchHandsGlitched.frames = Paths.getSparrowAtlas("characters/glitch/GlitchHandsGlitched");
		glitchHandsGlitched.animation.addByPrefix("idle", "Idle Hands", 24, true);
		glitchHandsGlitched.alpha = 0.00001;
		glitchHandsGlitched.animation.play("idle");
	}
	
	override function createPost()
	{
		addBehindBF(front);
		addBehindBF(glitchHands);
		addBehindBF(glitchHandsGlitched);
		addBehindDad(chandelier);
		add(shading);

		comboPosition = [1603, 1100];
		comboPosition[0] -= 600;
		comboPosition[1] -= 400;
	}

	override function update(elapsed){
		offsetX = Std.int(dad.getMidpoint().x - 50);
		offsetY = Std.int(dad.getMidpoint().y - 0);
		bfoffsetX = Std.int(dad.getMidpoint().x - 310);
		bfoffsetY = Std.int(dad.getMidpoint().y + 200);
		handleAnimation();
	}

	private function handleAnimation(){
		if(PlayState.instance.dad.animation.curAnim.name == "idle"){
			if(PlayState.instance.dad.curCharacter.contains("-alt")){
				glitchHandsGlitched.alpha = 1;
				glitchHandsGlitched.animation.play("idle", true, false, PlayState.instance.dad.animation.curAnim.curFrame);
			} else {
				glitchHands.alpha = 1;
				glitchHands.animation.play("idle", true, false, PlayState.instance.dad.animation.curAnim.curFrame);
			}
		} else {
			glitchHands.alpha = 0.00001;
			glitchHandsGlitched.alpha = 0.00001;
		}
	}
}