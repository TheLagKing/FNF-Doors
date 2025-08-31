package states.stages;

import sys.FileSystem;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class Boykisser extends BaseStage
{
	var catGroup:FlxTypedSpriteGroup<BoykisserCat>;

	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["boykisser/closePopup","boykisser/divider","boykisser/farPopup",
						"boykisser/nekoDarkShading","boykisser/nekoSideWall","boykisser/nekoSideFloor",
						"boykisser/seekSide"]
		];

		for(file in FileSystem.readDirectory(Paths.getSharedPath("images/boykisser/cats"))){
			var tempArr = theMap.get("images");
			tempArr.push('boykisser/cats/${file.replace(".png", "")}');
			theMap.set("images", tempArr);
		}

		return theMap;
	}

	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [seekSide, divider, nekoSideFloor,
				nekoSideWall, nekoClosePopup, nekoFarPopup, nekoDarkShading],
			"foreground" => [],
			"special" => [[]]
		];

		return map;
	}

	var seekSide:FlxSprite;
	var divider:FlxSprite;
	var nekoSideFloor:FlxSprite;
	var nekoSideWall:FlxSprite;
	var nekoClosePopup:FlxSprite;
	var nekoFarPopup:FlxSprite;
	var nekoDarkShading:FlxSprite;

	override function create()
	{
		var rain = new Rain(-300, -300, 2702, 1174, [0xFF222057, 0xFF000000]);
		rain.rainSpeed = 1;
		rain.rainAngle = 10;
		add(rain);
		
		nekoSideWall = new FlxSprite(576*1.5, -22*1.5).loadGraphic(Paths.image("boykisser/nekoSideWall"));
		nekoSideWall.scale.set(1920/1280, 1920/1280);
		nekoSideWall.updateHitbox();
		nekoSideWall.antialiasing = ClientPrefs.globalAntialiasing;
		add(nekoSideWall);

		nekoFarPopup = new FlxSprite(658*1.5, -64*1.5).loadGraphic(Paths.image("boykisser/farPopup"));
		nekoFarPopup.scale.set(1920/1280, 1920/1280);
		nekoFarPopup.updateHitbox();
		nekoFarPopup.antialiasing = ClientPrefs.globalAntialiasing;
		FlxTween.tween(nekoFarPopup, {y: nekoFarPopup.y + 10}, 5, {ease: FlxEase.smoothStepInOut, type:PINGPONG});
		add(nekoFarPopup);

		nekoClosePopup = new FlxSprite(524*1.5, -64*1.5).loadGraphic(Paths.image("boykisser/closePopup"));
		nekoClosePopup.scale.set(1920/1280, 1920/1280);
		nekoClosePopup.updateHitbox();
		nekoClosePopup.antialiasing = ClientPrefs.globalAntialiasing;
		FlxTween.tween(nekoClosePopup, {y: nekoClosePopup.y + 12}, 5, {ease: FlxEase.smoothStepInOut, type:PINGPONG});
		add(nekoClosePopup);

		nekoSideFloor = new FlxSprite(452*1.5, 449*1.5).loadGraphic(Paths.image("boykisser/nekoSideFloor"));
		nekoSideFloor.scale.set(1920/1280, 1920/1280);
		nekoSideFloor.updateHitbox();
		nekoSideFloor.antialiasing = ClientPrefs.globalAntialiasing;
		add(nekoSideFloor);

		seekSide = new FlxSprite().loadGraphic(Paths.image("boykisser/seekSide"));
		seekSide.scale.set(1920/1280, 1920/1280);
		seekSide.updateHitbox();
		seekSide.antialiasing = ClientPrefs.globalAntialiasing;
		add(seekSide);

		divider = new FlxSprite(500*1.5, -12*1.5);
		divider.frames = Paths.getSparrowAtlas("boykisser/divider");
		divider.animation.addByPrefix("idle", "divider", 24, true);
		divider.animation.play("idle");
		divider.scale.set(1920/1280, 1920/1280);
		divider.updateHitbox();
		divider.antialiasing = ClientPrefs.globalAntialiasing;
		add(divider);

		add(catGroup = new FlxTypedSpriteGroup<BoykisserCat>(20));
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 350);
		offsetY = Std.int(dad.getMidpoint().y + 60);
		bfoffsetX = Std.int(boyfriend.getMidpoint().x - 350);
		bfoffsetY = Std.int(dad.getMidpoint().y + 60);
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float){
		switch(eventName){
			case "boykisserCat":
				catGroup.add(catGroup.recycle(BoykisserCat.new));
		}
	}
}

class BoykisserCat extends FlxSprite
{
	var availableCars:Array<String> = [];

	public function new()
	{
		for(file in FileSystem.readDirectory(Paths.getSharedPath("images/boykisser/cats"))){
			availableCars.push(file.replace(".png", ""));
		}

		super(0, 0);
		scrollFactor.set(0, 0);
		kill();
	}
	
	override function revive()
	{
		loadGraphic(Paths.image('boykisser/cats/${FlxG.random.getObject(availableCars)}'));
		updateHitbox();
		alpha = 1;
		x = 600 + (FlxG.random.int(Math.round(-(width/2)), Math.round(FlxG.width - width)));
		y = 720;
		scrollFactor.set(0, 0);
		super.revive();
	}
	
	override function update(elapsed:Float)
	{
		y = FlxMath.lerp(y, -(this.height), CoolUtil.boundTo(elapsed, 0, 1));
		alpha -= (0.25 * elapsed);
		if (y < -(this.height) || alpha < 0.01)
			kill();
		super.update(elapsed);
	}
}