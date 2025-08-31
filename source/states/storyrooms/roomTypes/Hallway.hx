package states.storyrooms.roomTypes;

import shaders.SoftLight;
import shaders.GlitchPosterize;
import flixel.math.FlxPoint;
import flixel.effects.FlxFlicker;

class Hallway extends BaseSMRoom {
	var lightsOnArray:Array<Dynamic> = [];
	var lightsOffArray:Array<Dynamic> = [];
	var flickerState:Bool = true; //TRUE = LIGHTS ON ; FALSE = LIGHTS OFF

	override function getDarkDoor(?side:String){
		var superDarkBG = new FlxSprite(0, 0).loadGraphic(Paths.image("story_mode_backgrounds/hallway2/superDarkBG"));
		superDarkBG.antialiasing = ClientPrefs.globalAntialiasing;

		var guidingPoint = new FlxPoint(1053, 522);

		return [superDarkBG, guidingPoint];
	}

    override function create() { 
        drawRoom();
    }

	private function drawRoom(){
		var clickablThings = [];

		Paths.image("story_mode_backgrounds/hallway2/superDarkBG");

		var background = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway2/bg-'+room.room.roomColor));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

		lightsOnArray.push(background);
		lightsOffArray.push(background);
		
		var darkShading = new FlxSprite(0, 0).makeSolid(1920, 1080, 0xFF000000);
		darkShading.alpha = 0.4;
		darkShading.antialiasing = ClientPrefs.globalAntialiasing;
		lightsOffArray.push(darkShading);

		if(!room.room.isDark) darkShading.visible = false;
		else darkShading.visible = true;

		//SPAWN PAINTINGS AND WINDOWS
		for(painting in room.paintings){
			var topLeftPoint = switch(painting.side){
				case "left": 
					if(painting.data.isWindow) new FlxPoint(0,0);
					else new FlxPoint(325,16);
				case "right":
					if(painting.data.isWindow) new FlxPoint(0,0);
					else new FlxPoint(1340,15);
				default:
					trace("Painting isn't on a supported side!");
					new FlxPoint(0,0);
			}

			var paintingSpr:StoryModeSpriteHoverable = 
				cast new StoryModeSpriteHoverable(topLeftPoint.x, topLeftPoint.y, "")
				.loadGraphic(Paths.image('story_mode_backgrounds/hallway2/${painting.side}/${painting.pattern}'));
			paintingSpr.antialiasing = ClientPrefs.globalAntialiasing;
			add(paintingSpr);

			furniture.push({
				name: "painting",
				sprite: paintingSpr,
				side: painting.side,
				specificAttributes: Lang.getText(painting.pattern, 'story/paintings/${painting.side}')
			});
		}

		var firstDoor = new StoryModeSpriteHoverable(840, 276, 'story_mode_backgrounds/hallway2/noDoor');
		add(firstDoor);
		doors.push({
			doorNumber: room.leftDoor.doorNumber,
			doorSpr: firstDoor,
			side: "left",
			isLocked: false,
			song: room.leftDoor.doorNumber == 52 ? "None" : room.leftDoor.song
		});

		var txtDoorNumber1 = new FlxText(firstDoor.x + 95, firstDoor.y + 72, 0, "", 48);
		txtDoorNumber1.text = Std.string(room.leftDoor.doorNumber);
		if(Std.parseInt(txtDoorNumber1.text) < 10 && Std.parseInt(txtDoorNumber1.text) > 0){
			txtDoorNumber1.text = "0" + Std.string(room.leftDoor.doorNumber);
		}
		txtDoorNumber1.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
		txtDoorNumber1.antialiasing = ClientPrefs.globalAntialiasing;
		txtDoorNumber1.color = FlxColor.BLACK;
		add(txtDoorNumber1);

		if (room.leftDoor.doorNumber == 52){
			var sign:FlxSprite;

			sign = new FlxSprite(811,-50).loadGraphic(Paths.image('JeffShop Sign'));
			sign.antialiasing = ClientPrefs.globalAntialiasing;

			trace(DoorsUtil.curRun.rooms[52 - DoorsUtil.curRun.initialDoor].room.bossType);
			if(DoorsUtil.curRun.rooms[52 - DoorsUtil.curRun.initialDoor].room.bossType == "glitched"){
				glitchedShader = new GlitchPosterize();
				glitchedShader.amount = 0.4;
				add(glitchedShader);
				sign.shader = glitchedShader.shader;

				MenuSongManager.changeSongVolume(0.3, 0.2);
				MenuSongManager.playSound("glitched52", 1, function(){
					MenuSongManager.changeSongVolume(1, 1);
				});
			} else {
				MenuSongManager.changeSongVolume(0.3, 0.2);
				MenuSongManager.playSound("jeff52", 1, function(){
					MenuSongManager.changeSongVolume(1, 1);
				});
			}

			sign.y -= sign.height;
			FlxTween.tween(sign, {y: sign.y + sign.height}, 3, {ease: FlxEase.cubeOut});

			add(sign);
		}
		
		add(darkShading);

		var foreground = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway2/fg'));
		foreground.antialiasing = ClientPrefs.globalAntialiasing;
		add(foreground);
		lightsOnArray.push(foreground);

		return clickablThings;
	}

	var glitchedShader:GlitchPosterize;
	override function update(elapsed:Float) {
        if(glitchedShader != null) glitchedShader.update(elapsed);
		super.update(elapsed);
	}

	private function flicker(duration:Float){

		if(DoorsUtil.modifierActive(4)) return;

		var stupidFuckingObjectThing = new FlxSprite(-100, -100).makeGraphic(1, 1, FlxColor.BLACK);

		var localDuration = duration;
		flickerState = true;

		var theSilly:Float = FlxG.random.float(0.1, 0.3);
		var theOtherSilly:Float = FlxG.random.float(0.04, 0.07);
		FlxFlicker.flicker(stupidFuckingObjectThing, localDuration, theOtherSilly, true, true, function(fuck){
			for (l in lightsOffArray){
				l.visible = false;
			}
			for (l in lightsOnArray){
				l.visible = true;
			}
		}, function(flc){
			if(flickerState){
				for (l in lightsOnArray) l.visible = false;
				for (l in lightsOffArray) l.visible = true;
			} else {
				for (l in lightsOffArray) l.visible = false;
				for (l in lightsOnArray) l.visible = true;
			}
			flickerState = !flickerState;
		});
	}

	var HALTFLICKERDURATION:Float = FlxG.random.float(3.1, 4.3);
	var RUSHFLICKERDURATION:Float = FlxG.random.float(1.0, 1.6);
	var flickerSelector:Bool = FlxG.random.bool(15);
	var flickerDurationSelector:Float = FlxG.random.float(0.2, 0.4);
	override function onAmbiance(justEntered:Bool){
		if(justEntered){
			if(room.room.isDark){
				MenuSongManager.playSound("AmbienceDark", 0.8);
				return;
			} else {
				if(DoorsUtil.modifierActive(5)) flickerSelector = FlxG.random.bool(60);
				if(flickerSelector){
					flicker(flickerDurationSelector);
					return;
				}
			}
		}
	}

	override function onHandleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		switch(furName){
			case "painting":
				if(furSprite.isHovered){
					if(FlxG.mouse.justPressed){
						StoryMenuState.instance.updateDescription(specificAttributes);
					}
				}
		}
	}
}