package states.stages;

import flixel.effects.FlxFlicker;
import flixel.math.FlxAngle;
import flxanimate.FlxAnimate;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class ScreechGreenhouse extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [];
		theMap = [
			"images" => ["screechBG_greenhouse/bg", "screechBG_greenhouse/bg_lightning", 
						"screechBG_greenhouse/tree", "screechBG_greenhouse/vignette"]
		];

		return theMap;
	}
	
	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [bg, bgthunder],
			"foreground" => [shade, fullWhite],
			"special" => [[tree, 0.4]]
		];

		return map;
	}

	var bg:FlxSprite;
	var bgthunder:FlxSprite;
	var tree:FlxSprite;
	var shade:FlxSprite;
	var fullWhite:FlxSprite;

	//save the positions for screech because he's a little bitch
	var dadX:Float;
	var dadY:Float;
	var floatTime:Float;
	var wantedXPos:Float;
	var wantedYPos:Float;
	var amplitude:Float = 20.0;
    var frequency:Float = 2.0;
    var angularSpeed:Float = 1.0;

	override function create()
	{
		game.isGreenhouseStage = true;

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("screechBG_greenhouse/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		bgthunder = new FlxSprite(0, 0).loadGraphic(Paths.image("screechBG_greenhouse/bg_lightning"));
		bgthunder.antialiasing = ClientPrefs.globalAntialiasing;
		bgthunder.alpha = 0.0001;
		add(bgthunder);
	}
	
	override function createPost()
	{
		tree = new FlxSprite(0, 0).loadGraphic(Paths.image("screechBG_greenhouse/tree"));
		tree.antialiasing = ClientPrefs.globalAntialiasing;
		add(tree);

		shade = new FlxSprite(0, 0).loadGraphic(Paths.image("screechBG_greenhouse/vignette"));
		shade.antialiasing = ClientPrefs.globalAntialiasing;
		add(shade);

		fullWhite = new FlxSprite(0, 0).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.WHITE);
		fullWhite.alpha = 0.00001;
		add(fullWhite);

		if(boyfriend.curCharacter == "bf_screech")
			PlayState.instance.triggerEventNote("Change Character", "BF", "bf", 0.0);
		
		dad.color = 0xff6c6c6c;
		boyfriend.color = 0xff5c5c5c;

		comboPosition = [880, 638]; //average of the two characters
		comboPosition[0] += 100;
		comboPosition[1] -= 300;

		if(dad.curCharacter == "screech"){
			dadX = dadGroup.x;
			dadY = dadGroup.y;
		}
	}

	var thunderCooldown:Float = 0;
	var doCosShit = true;
	override function update(elapsed:Float){
		if(dad.curCharacter == "screech" && doCosShit){
			floatTime += elapsed;
			wantedXPos = Math.cos(angularSpeed * 1.4 * floatTime) * (amplitude * Math.sin(frequency * floatTime)) + dadX;
			wantedYPos = Math.sin(angularSpeed * 1.2 * floatTime) * (amplitude * Math.sin(frequency * floatTime)) + dadY;
			dadGroup.x = FlxMath.lerp(dadGroup.x, wantedXPos, CoolUtil.boundTo(elapsed * 8, 0, 1));
			dadGroup.y = FlxMath.lerp(dadGroup.y, wantedYPos, CoolUtil.boundTo(elapsed * 8, 0, 1));
		}

		offsetX = Std.int(dad.getMidpoint().x + 500);
		offsetY = Std.int(boyfriend.getMidpoint().y + 30);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 200);
		bfoffsetY = Std.int(boyfriend.getMidpoint().y - 180);

		thunderCooldown -= elapsed;
	}

	override function stepHit()
		{
			if(FlxG.random.bool(10) && thunderCooldown <= 0){
				thunderCooldown = FlxG.random.float(8, 24);
				thunder();
			}
		}

	function thunder(){
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
		
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		shade.alpha = 0;
		bgthunder.alpha = 1;
		fullWhite.alpha = 0.1;
		FlxTween.tween(shade, {alpha: 1}, 3, {ease: FlxEase.expoOut});
		FlxTween.tween(bgthunder, {alpha: 0}, 3, {ease: FlxEase.expoOut});
		FlxTween.tween(fullWhite, {alpha: 0}, 3, {ease: FlxEase.expoOut});
		if(dad.alpha >= 0.9) FlxTween.color(dad, 3.0, 0xFFFFFFFF, 0xFF6c6c6c, {ease: FlxEase.expoOut});
	}

    var hitSprite:FlxSprite;
	private function spawnScreechHitAnimation(){
		doCosShit = false;
		FlxTween.cancelTweensOf(dad);
		hitSprite = new FlxSprite(dad.x - 430, dad.y - 310);
		hitSprite.antialiasing = ClientPrefs.globalAntialiasing;
		hitSprite.frames = Paths.getSparrowAtlas("characters/screech_hit");
		hitSprite.scale.set(0.56, 0.56);
		hitSprite.updateHitbox();
		hitSprite.animation.addByPrefix("hit", "screech_hit", 11, false);
		hitSprite.animation.play("hit");
		add(hitSprite);
		hitSprite.color = 0xff616161;
		if(thrownMic != null) {
			remove(thrownMic);
			add(thrownMic);
		}
		FlxTween.tween(boyfriend, {x: boyfriend.x + 1}, 0.1, {onComplete:function(twn){
			dad.alpha = 0.0001;
			boyfriend.x -= 1;
		}});
		hitSprite.animation.finishCallback = function(animName){
			hitSprite.alpha = 0.0001;
		}
	}

    var psstSprite:FlxSprite;
	private function spawnScreechPsstAnimation(){
		doCosShit = false;
		FlxTween.cancelTweensOf(dad);
		dad.alpha = 0.0001;
		psstSprite = new FlxSprite(dad.x - 64, dad.y - 64);
		psstSprite.antialiasing = ClientPrefs.globalAntialiasing;
		psstSprite.frames = Paths.getSparrowAtlas("characters/screech_psst");
		psstSprite.scale.set(0.56, 0.56);
		psstSprite.updateHitbox();
		psstSprite.animation.addByPrefix("psst", "psst_", 11, false);
		psstSprite.animation.play("psst");
		add(psstSprite);
		psstSprite.color = 0xff6c6c6c;
		psstSprite.animation.finishCallback = function(animName){
			psstSprite.alpha = 0.0001;
			dad.alpha = 1;
			dad.playAnim('idle', true);
		}
	}

    var bfMicThrow:FlxAnimate;
	private function spawnBfMicThrowAnim(){
		FlxTween.cancelTweensOf(boyfriend);
		boyfriend.alpha = 0.0001;
		var bfPath:String = switch(boyfriend.curCharacter) {
			case "bf_screech": "micthrowbf-screech";
			default: "micthrowbf";
		};
		bfMicThrow = new FlxAnimate(boyfriend.x, boyfriend.y);
		Paths.loadAnimateAtlas(bfMicThrow, 'characters/boyfriend/${bfPath}');
		bfMicThrow.antialiasing = ClientPrefs.globalAntialiasing;
		bfMicThrow.scale.set(1.2, 1.2);
		bfMicThrow.updateHitbox();
		bfMicThrow.anim.addBySymbol("throw", "mic-throw", 24, false);
		bfMicThrow.anim.play("throw", true, false);
		add(bfMicThrow);
		bfMicThrow.color = 0xff5c5c5c;
		switch(bfPath) {
			case "micthrowbf-screech": bfMicThrow.color = 0xffffffff;
			default: bfMicThrow.color = 0xffacacac;
		}
		bfMicThrow.anim.onComplete = function(){
			bfMicThrow.alpha = 0.0001;
			boyfriend.alpha = 1;
			boyfriend.playAnim('idle', true);
		}
	}

	
    var thrownMic:FlxSprite;
	private function bfThrowMic() {
		thrownMic = new FlxSprite(boyfriend.x, boyfriend.y);
		thrownMic.loadGraphic(Paths.image("microphone", "shared"));
		thrownMic.antialiasing = ClientPrefs.globalAntialiasing;
		thrownMic.scale.set(1.2, 1.2);
		thrownMic.updateHitbox();
		thrownMic.alpha = 1;
		add(thrownMic);

		var startX = boyfriend.x - 50;
		var startY = boyfriend.y + 160;
		thrownMic.setPosition(startX, startY);

		doCosShit = false;
		var dadXCenterPoint = dad.x + dad.width/2 + 188;
		var dadYCenterPoint = dad.y + dad.height/2 + 152;
		var angle = FlxAngle.angleBetween(boyfriend, dad, true);
		thrownMic.angle = angle + 20;

		FlxTween.tween(thrownMic, {x: dadXCenterPoint, y: dadYCenterPoint}, 0.2, {onComplete: function(twn){
			FlxFlicker.flicker(thrownMic, 0.75, 0.05, false, true);
			FlxTween.tween(thrownMic, {angle: thrownMic.angle + 360}, 0.15, {type: LOOPING});
			FlxTween.cubicMotion(
				thrownMic,
				(dadXCenterPoint), (dadYCenterPoint),
				(dadXCenterPoint) + 125, (dadYCenterPoint) - 100,
				(dadXCenterPoint) + 375, (dadYCenterPoint) - 100,
				(dadXCenterPoint) + 500, (dadYCenterPoint) + 300,
				0.75,
				{
					onComplete: function(twn:FlxTween) {
						FlxTween.tween(thrownMic, {alpha: 0}, 0.3, {
							onComplete: function(twn:FlxTween) {
								remove(thrownMic);
							}
						});
					}
				}
			);
		}});
	}

	
    var handleSpawnAnimationThruEvent:Bool = false;
    override function eventPushed(event:objects.Note.EventNote){
        switch(event.event){
            case "screechHit":
				Paths.getSparrowAtlas("characters/screech_hit");
            case "screechPsst":
				Paths.getSparrowAtlas("characters/screech_psst");
			case "bfThrowMic":
				Paths.image("microphone", "shared");
			case "bfStartThrowMic":
				Paths.image("characters/boyfriend/micthrowbf/spritemap1", "shared");
				Paths.image("characters/boyfriend/micthrowbf-screech/spritemap1", "shared");
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName){
				case "screechHit":
					spawnScreechHitAnimation();
				case "screechPsst":
					spawnScreechPsstAnimation();
				case "bfThrowMic":
					bfThrowMic();
				case "bfStartThrowMic":
					spawnBfMicThrowAnim();
			}
		}
}