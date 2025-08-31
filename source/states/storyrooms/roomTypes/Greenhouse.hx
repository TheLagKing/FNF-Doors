package states.storyrooms.roomTypes;

import flixel.math.FlxPoint;

class Greenhouse extends BaseSMRoom {
    override function create() { 
        drawGreenhouse();
    }

	override function getDarkDoor(?side:String){
		var pos:FlxPoint = new FlxPoint(0, 0);
		for(door in doors){
			if(side == door.side){
				pos = new FlxPoint(door.doorSpr.x, door.doorSpr.y);
			}
		}
		var superDarkBG = new FlxSprite(pos.x, pos.y).loadGraphic(Paths.image('story_mode_backgrounds/greenhouse/darkDoor'));
		superDarkBG.antialiasing = ClientPrefs.globalAntialiasing;

		var guidingPoint = new FlxPoint(pos.x + 13, pos.y + 94);

		return [superDarkBG, guidingPoint];
	}

	private function drawGreenhouse(){
		var background = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/greenhouse/BG'));
		background.antialiasing = ClientPrefs.globalAntialiasing;

		var door = new StoryModeSpriteHoverable(912, 543, 'story_mode_backgrounds/greenhouse/Door');
		door.antialiasing = ClientPrefs.globalAntialiasing;
        doors.push({
            doorNumber: DoorsUtil.curRun.curDoor + 1,
            doorSpr: door,
            side: "right",
            isLocked: false,
            song: DoorsUtil.curRun.curDoor != 99 ? room.rightDoor.song : "None"
        });

		add(background);
		add(door);

		for(fur in room.furniture){
			var topLeftPoint:FlxPoint = switch(fur.side){
				case "FL": 
					if(fur.name == "Closet") new FlxPoint(148, 401);
					else new FlxPoint(244, 585);
				case "BL":
					if(fur.name == "Closet") new FlxPoint(713, 539);
					else if (fur.name == "Vines") new FlxPoint(672, 590);
					else new FlxPoint(673, 597);
				case "BR": 
					if(fur.name == "Closet") new FlxPoint(1108, 539);
					else if (fur.name == "Vines") new FlxPoint(1044, 591);
					else new FlxPoint(1050, 598);
				case "FR":
					if(fur.name == "Closet") new FlxPoint(1539, 408);
					else new FlxPoint(1426, 590);
				default:
					trace("Furniture isn't on a supported side!");
					new FlxPoint(0,0);
			}
			
			var furnitureSpr = new StoryModeSpriteHoverable(topLeftPoint.x, topLeftPoint.y, 'story_mode_backgrounds/greenhouse/${fur.side}-${fur.name}');
			furnitureSpr.antialiasing = ClientPrefs.globalAntialiasing;
			add(furnitureSpr);

			switch(fur.name.toLowerCase()){
				case "closet":

					if([for (x in room.entitiesInRoom) x.name].contains("rush")){
						var guidingLightSpr = new FlxSprite(
							topLeftPoint.x - 500 + furnitureSpr.width/2, 
							topLeftPoint.y - 375 + furnitureSpr.height/2
							).loadGraphic(Paths.image("guidingLight"));
						add(guidingLightSpr);
						FlxTween.tween(guidingLightSpr, {alpha: 0.5}, FlxG.random.float(0.8, 1.2), {ease: FlxEase.sineInOut, startDelay: FlxG.random.float(0.3, 0.6), type: PINGPONG});
					}

					furniture.push({
						name: "closet",
						sprite: furnitureSpr,
						side: fur.side,
						specificAttributes: fur.specificAttributes
					});
			}
		}

		// Add a semi-transparent black overlay to darken the room
		var darkOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0x36000000);
		darkOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(darkOverlay);
	}

	override function onHandleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		switch(furName.toLowerCase()){
			case 'closet':
				if(furSprite.isHovered && FlxG.mouse.justPressed){
					closetShit(furSprite, furName, side, specificAttributes, elapsed);
				}
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);
		

		if(isInCloset && FlxG.mouse.justPressed) {
			StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
				leaveCloset();
			});
		}
	}

	var isInCloset:Bool = false;
	function closetShit(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		function emptyCloset(){
			for(i=>fur in DoorsUtil.curRun.currentRoom.furniture){
				if(fur.side == side && fur.name == furName){
					DoorsUtil.curRun.currentRoom.furniture[i].specificAttributes = {
						hasJack: false
					};
				}
			}

			for(i=>fur in furniture){
				if(fur.side == side && fur.name.replace("Long", "") == furName.replace("Long", "")){
					furniture[i].specificAttributes = {
						hasJack: false
					};
				}
			}
			StoryMenuState.instance.saveData();
		}

		StoryMenuState.instance.theMouse.startLongAction(0.3, function(){
			if(!isInCloset) enterCloset(furName);
			else leaveCloset();
		});

		emptyCloset();
	}

	function enterCloset(closetName:String) {
		isInCloset = true;
		StoryMenuState.instance.inSubState = true;

		StoryMenuState.instance.closetForeground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/greenhouse/closet/ClosetDoors"));
		StoryMenuState.instance.closetForeground.antialiasing = ClientPrefs.globalAntialiasing;

		StoryMenuState.instance.closetBackground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/greenhouse/closet/BG"));
		StoryMenuState.instance.closetBackground.antialiasing = ClientPrefs.globalAntialiasing;

		var transitionSpr = new BGSprite("transitions/trans", 0, 0, 0, 0, ["TransitionIn_"], false);
		transitionSpr.animation.addByPrefix("out", "TransitionIn_", 72, false);
		transitionSpr.cameras = [camHUD];
		transitionSpr.scale.set(1280/1920, 1280/1920);
		transitionSpr.updateHitbox();
		transitionSpr.screenCenter();
		transitionSpr.visible = true;
		add(transitionSpr);

		MenuSongManager.playSound("ClosetOpen", 1.0);
		transitionSpr.animation.play("out",true, false, 0);
		transitionSpr.flipX = false;
		new FlxTimer().start(0.35/3, function(tmr:FlxTimer) {

			StoryMenuState.instance.entitiesFunc(function(entity:BaseSMMechanic) {
				entity.onClosetEnter();
			});

			transitionSpr.animation.play("out",true, true, 0);
			transitionSpr.flipX = true;
			StoryMenuState.instance.add(StoryMenuState.instance.closetBackground);
			StoryMenuState.instance.add(StoryMenuState.instance.closetForeground);
		});
	}

	function leaveCloset() {
		isInCloset = false;
		StoryMenuState.instance.inSubState = false;

		var transitionSpr = new BGSprite("transitions/trans", 0, 0, 0, 0, ["TransitionIn_"], false);
		transitionSpr.animation.addByPrefix("out", "TransitionIn_", 72, false);
		transitionSpr.cameras = [camHUD];
		transitionSpr.scale.set(1280/1920, 1280/1920);
		transitionSpr.updateHitbox();
		transitionSpr.screenCenter();
		transitionSpr.visible = true;
		add(transitionSpr);

		MenuSongManager.playSound("ClosetClose", 1.0);
		transitionSpr.animation.play("out",true, false, 0);
		transitionSpr.flipX = true;
		new FlxTimer().start(0.35/3, function(tmr:FlxTimer) {

			StoryMenuState.instance.entitiesFunc(function(entity:BaseSMMechanic) {
				entity.onClosetLeave();
			});

			transitionSpr.animation.play("out",true, true, 0);
			transitionSpr.flipX = false;

			StoryMenuState.instance.remove(StoryMenuState.instance.closetBackground);
			StoryMenuState.instance.remove(StoryMenuState.instance.closetForeground);
		});
	}
}