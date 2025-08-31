package states.storyrooms.roomTypes;

import flixel.sound.filters.FlxSoundFilterType;
import flixel.sound.filters.FlxSoundFilter;
import flixel.math.FlxPoint;
import objects.items.Item;
import backend.storymode.InventoryManager;
import shaders.GlitchPosterize;
import shaders.SoftLight;
import flixel.effects.FlxFlicker;
import shaders.HaltChromaticAberration;
import openfl.display.BlendMode;
import flixel.FlxSubState;
import backend.metadata.StoryModeMetadata.NearSeekData;

class Normal extends BaseSMRoom {
	public var generateLong:Bool = false;

	var preRoom:FlxSpriteGroup;
	var regularRoom:FlxSpriteGroup;
	var nextRooms:Array<FlxSpriteGroup> = [];
	var nextRoomFunctions:Array<Array<Void->Void>> = [];

	var lightsOnArray:Array<Dynamic> = [];
	var lightsOffArray:Array<Dynamic> = [];
	var flickerState:Bool = true; //TRUE = LIGHTS ON ; FALSE = LIGHTS OFF
	var softlightShader:SoftLight;

	public var softDoors:Array<StoryModeSpriteHoverable> = [];
	public var softDoorsLocked:Array<Bool> = [];
	var softDoorArrows:Array<FlxSprite> = [];

	public function new(?genLong:Bool = false) {
		generateLong = genLong;
		super();
	}

	override function getDarkDoor(?side:String){
		var superDarkBG:FlxSprite;
		var guidingPoint = new FlxPoint(0, 0);
		if(generateLong && softDoors.length > 0){
			superDarkBG = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway3/darkRooms/${room.room.roomColor}${CoolUtil.capitalize(side)}'));
			superDarkBG.antialiasing = ClientPrefs.globalAntialiasing;
			switch(side){
				case "left": guidingPoint = new FlxPoint(460, 545);
				case "right": guidingPoint = new FlxPoint(1477, 569);
			}
		} else {
			var pos:FlxPoint = new FlxPoint(0, 0);
			for(door in doors){
				if(side == door.side){
					pos = new FlxPoint(door.doorSpr.x, door.doorSpr.y);
				}
			}
			superDarkBG = new FlxSprite(pos.x, pos.y).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/doors/darkDoor${CoolUtil.capitalize(side)}'));
			superDarkBG.antialiasing = ClientPrefs.globalAntialiasing;

			switch(side){
				case "left": guidingPoint = new FlxPoint(pos.x + 196, pos.y + 226);
				case "right": guidingPoint = new FlxPoint(pos.x + 29, pos.y + 226);
			}
		}

		return [superDarkBG, guidingPoint];
	}

    override function create() { 
		if(ClientPrefs.data.shaders){
			softlightShader = new SoftLight();
		}

		if(generateLong){
			preRoom = drawLong();
			add(preRoom);

			for(i in 0...2){
				nextRooms.push(drawRoom(i));
				//add(nextRooms[i]);
			}
		} else {
			regularRoom = drawRoom(0);
			add(regularRoom);

			for(f in nextRoomFunctions[0]){
				f();
			}
		}
    }
	
	private function drawLong(){
		var roomToGenerate:FlxSpriteGroup = new FlxSpriteGroup();

		var litBackground = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway3/lit/${room.room.roomColor}Room'));
		litBackground.antialiasing = ClientPrefs.globalAntialiasing;
		lightsOnArray.push(litBackground);
		roomToGenerate.add(litBackground);

		var darkBackground = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway3/dark/${room.room.roomColor}Room'));
		darkBackground.antialiasing = ClientPrefs.globalAntialiasing;
		lightsOffArray.push(darkBackground);
		roomToGenerate.add(darkBackground);
		
		//This stores : 1-2-3-4 for the eyes ; 5 for small cum crack ; 6 for big cum crack
		var seekInfo:Array<NearSeekData> = [];

		if(room.room.seekData != null){
			seekInfo = room.room.seekData;
		}

		var paintingSides:Array<String> = [];
		var windowSides:Array<String> = [];
		var furnitureSides:Array<String> = [];
		for(painting in room.paintings) painting.data.isWindow ? windowSides.push(painting.side) : paintingSides.push(painting.side); 
		for(fur in room.furniture) furnitureSides.push(fur.side);

		for(seek in seekInfo){
			//check if it ain't blocked
			for(s in seek.windowBlockedSides) if(windowSides.contains(s)) continue;
			for(s in seek.paintingBlockedSides) if(paintingSides.contains(s)) continue;
			for(s in seek.furnitureBlockedSides) if(furnitureSides.contains(s)) continue;

			if(seek.id < 2){
				var topLeftPoint = switch(seek.id){
					case 1: new FlxPoint(58, 0);
					default: 
						trace("Seek eyes has an unsupported value!");
						new FlxPoint(0,0);
				}
				var eye = new FlxSprite(topLeftPoint.x, topLeftPoint.y).loadGraphic(Paths.image(switch(seek.id){
					case 1: 'BigEye';
					default: 
						trace("Seek eyes has an unsupported value!");
						'';
				}));
				eye.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(eye);
			} else {
				trace("Seek eyes has an unsupported value!");
			}
		}

		//SPAWN PAINTINGS AND WINDOWS
		for(painting in room.paintings){
			var topLeftPoint = switch(painting.side){
				case "ML": 
					new FlxPoint(586, 289);
				case "MR":
					new FlxPoint(1134, 289);
				case "SL":
					if(painting.data.isWindow) new FlxPoint(-5, 150);
					else new FlxPoint(5, 90);
				case "SR":
					if(painting.data.isWindow) new FlxPoint(1545, 150);
					else new FlxPoint(1508, 90);
				default:
					trace("Painting/Window isn't on a supported side!");
					new FlxPoint(0,0);
			}

			if(painting.data.isWindow){
				var window = new FlxSprite(topLeftPoint.x, topLeftPoint.y).loadGraphic(Paths.image('story_mode_backgrounds/hallway3/window${painting.side}'));
				window.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(window);
			} else {
				var paintingSpr:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(topLeftPoint.x, topLeftPoint.y, "").loadGraphic(Paths.image('story_mode_backgrounds/hallway3/paint${painting.side}/' + painting.pattern));
				paintingSpr.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(paintingSpr);

				furniture.push({
					name: "painting",
					sprite: paintingSpr,
					side: painting.side,
					specificAttributes: Lang.getText(painting.pattern, 'story/paintings/${painting.side}')
				});
			}
		}

		for(furnitureData in room.furniture){
			var topLeftPoint = switch(furnitureData.name){
				case 'clock':
					if(furnitureData.side == "ML") new FlxPoint(484, 239);
					else if(furnitureData.side == "MR") new FlxPoint(1121, 239);
					else new FlxPoint(0,0);
				case 'drawer':
					if(furnitureData.side == "ML") new FlxPoint(437, 586);
					else if(furnitureData.side == "MR") new FlxPoint(1062, 586);
					else new FlxPoint(0,0);
				case 'closet':
					if(furnitureData.side == "SL") new FlxPoint(0, 0);
					else if(furnitureData.side == "SR") new FlxPoint(1508, 0);
					else new FlxPoint(0,0);
				default: 
					trace("furniture is an unsupported name.");
					new FlxPoint(0,0);
			}

			var litFurnitureSpr:Null<StoryModeSpriteHoverable> = null;
			var darkFurnitureSpr:Null<StoryModeSpriteHoverable> = null;
			var furnitureSpr:Null<StoryModeSpriteHoverable> = null;

			if(["ML", "MR"].contains(furnitureData.side)){
				litFurnitureSpr = new StoryModeSpriteHoverable(topLeftPoint.x,topLeftPoint.y,'story_mode_backgrounds/hallway3/lit/${furnitureData.name}${furnitureData.side.toLowerCase()}');
				litFurnitureSpr.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(litFurnitureSpr);
				lightsOnArray.push(litFurnitureSpr);
				
				darkFurnitureSpr = new StoryModeSpriteHoverable(topLeftPoint.x,topLeftPoint.y,'story_mode_backgrounds/hallway3/dark/${furnitureData.name}${furnitureData.side.toLowerCase()}');
				darkFurnitureSpr.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(darkFurnitureSpr);
				lightsOffArray.push(darkFurnitureSpr);
			} else {
				furnitureSpr = new StoryModeSpriteHoverable(topLeftPoint.x,topLeftPoint.y,'story_mode_backgrounds/hallway3/${furnitureData.name}${furnitureData.side.toLowerCase()}');
				furnitureSpr.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(furnitureSpr);
			}

			//specific attributes
			switch(furnitureData.name){
				case 'drawer':
					Paths.image('story_mode_backgrounds/hallway3/lit/${furnitureData.name}${furnitureData.side.toLowerCase()}Open');
					Paths.image('story_mode_backgrounds/hallway3/dark/${furnitureData.name}${furnitureData.side.toLowerCase()}Open');

					if(furnitureData.specificAttributes.isOpened){
						litFurnitureSpr.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/lit/${furnitureData.name}${furnitureData.side.toLowerCase()}Open'));
						darkFurnitureSpr.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/dark/${furnitureData.name}${furnitureData.side.toLowerCase()}Open'));
					} 
					furniture.push({
						name: "drawerLong",
						sprite: litFurnitureSpr,
						side: furnitureData.side,
						specificAttributes: furnitureData.specificAttributes
					});
				case 'closet':
					furniture.push({
						name: "closetLong",
						sprite: furnitureSpr,
						side: furnitureData.side,
						specificAttributes: furnitureData.specificAttributes
					});
			}
		}

		//SPAWN "DOOR" HITBOXES
		//hitbox 1 v1 : 138 x 664 ; 398 - 202
		//hitbox 2 v1 : 163 x 658 ; 1346 - 201
		var leftHitbox:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(398, 202, "").makeGraphic(163, 664, 0xFFA0A0FF);
		leftHitbox.alpha = 0.0000001;
		softDoors.push(leftHitbox);
		roomToGenerate.add(leftHitbox);

		var leftArrow:FlxSprite = new FlxSprite(468, 457).loadGraphic(Paths.image("story_mode_backgrounds/hallway3/leftArrow"));
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		roomToGenerate.add(leftArrow);
		softDoorArrows.push(leftArrow);
		FlxTween.tween(leftArrow, {x: leftArrow.x - 30}, 1.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		FlxTween.tween(leftArrow, {alpha: 0}, 4.0, {ease: FlxEase.sineInOut, startDelay: 8.0});
		
		var rightHitbox:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(1346, 201, "").makeGraphic(163, 658, 0xFFA0A0FF);
		rightHitbox.alpha = 0.0000001;
		softDoors.push(rightHitbox);
		roomToGenerate.add(rightHitbox);

		var rightArrow:FlxSprite = new FlxSprite(1409, 457).loadGraphic(Paths.image("story_mode_backgrounds/hallway3/rightArrow"));
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		roomToGenerate.add(rightArrow);
		softDoorArrows.push(rightArrow);
		FlxTween.tween(rightArrow, {x: rightArrow.x + 30}, 1.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		FlxTween.tween(rightArrow, {alpha: 0}, 4.0, {ease: FlxEase.sineInOut, startDelay: 8.0});

		softDoorsLocked = [false, false];

		for (l in lightsOnArray){
			l.visible = !room.room.isDark;
		}
		for (l in lightsOffArray){
			l.visible = room.room.isDark;
		}

		return roomToGenerate;
	}

	override function darkCreate() {
		if(!StoryMenuState.instance.isDark) return;

		StoryMenuState.instance.overrideDarkCreation = true;

		//if(StoryMenuState.instance.members.contains(StoryMenuState.instance.bigDarkness))
		//	StoryMenuState.instance.remove(StoryMenuState.instance.bigDarkness);
		//
		//if(StoryMenuState.instance.members.contains(StoryMenuState.instance.guidedLight))
		//	StoryMenuState.instance.remove(StoryMenuState.instance.guidedLight);
		//
		//if(StoryMenuState.instance.members.contains(StoryMenuState.instance.guidedLightDoor))
		//	StoryMenuState.instance.remove(StoryMenuState.instance.guidedLightDoor);
		
		if(StoryMenuState.instance.guidedLight != null) FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLight);
		if(StoryMenuState.instance.guidedLightDoor != null) FlxTween.cancelTweensOf(StoryMenuState.instance.guidedLightDoor);

		StoryMenuState.instance.bigDarkness = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
		StoryMenuState.instance.add(StoryMenuState.instance.bigDarkness);
		StoryMenuState.instance.bigDarkness.screenCenter();

		var randomDoorSide:String;
		var allDoorSides:Array<String> = [];
		if(softDoors.length > 0) {
			allDoorSides.push("Left");
			allDoorSides.push("Right");
		} else {
			for(door in doors){
				allDoorSides.push(door.side);
			}
		}

		randomDoorSide = FlxG.random.getObject(allDoorSides);
		
		if(softDoors.length > 0) {
			if(randomDoorSide == "Left") softDoorsLocked[1] = true;
			if(randomDoorSide == "Right") softDoorsLocked[0] = true;
		} 
		for(door in doors){
			if(randomDoorSide != door.side) {
				door.isDarkBlocked = true;
			}
		}

		for(fur in furniture){
			fur.isDarkBlocked = true;
		}

		var spr:Dynamic = getDarkDoor(randomDoorSide);
		if(!Std.isOfType(spr, Bool)){
			StoryMenuState.instance.guidedLightDoor = spr[0];
			StoryMenuState.instance.guidedLightDoor.alpha = 0;
			FlxTween.tween(StoryMenuState.instance.guidedLightDoor, {alpha: 1}, FlxG.random.float(4.0, 5.0), {ease: FlxEase.circOut});
			
			StoryMenuState.instance.guidedLight = new FlxSprite(
				spr[1].x - 500, 
				spr[1].y - 350
			).loadGraphic(Paths.image("guidingLight"));
			StoryMenuState.instance.guidedLight.alpha = 0;
			StoryMenuState.instance.guidedLight.antialiasing = ClientPrefs.globalAntialiasing;
			
			FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.6}, FlxG.random.float(4.0, 5.0), {ease: FlxEase.circOut, onComplete: function(twn){
				FlxTween.tween(StoryMenuState.instance.guidedLight, {alpha: 0.4}, 2.0, {ease: FlxEase.quadInOut, type: PINGPONG});
			}});

			StoryMenuState.instance.add(StoryMenuState.instance.guidedLightDoor);
			StoryMenuState.instance.add(StoryMenuState.instance.guidedLight);
		}
	}

	private function drawRoom(?i:Int = 0){
		var roomToGenerate:FlxSpriteGroup = new FlxSpriteGroup();
		if(nextRoomFunctions == null || nextRoomFunctions.length <= i){
			nextRoomFunctions.push([]);
		}

		var background = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/rooms/wall' + room.room.roomColor));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		roomToGenerate.add(background);

		var carpet = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/carpets/carpet' + room.room.roomColor));
		carpet.antialiasing = ClientPrefs.globalAntialiasing;
		roomToGenerate.add(carpet);

		var camada20 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada20'));
		camada20.blend = BlendMode.HARDLIGHT;
		camada20.antialiasing = ClientPrefs.globalAntialiasing;
		camada20.antialiasing = true;

		var camada21 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada21'));
		camada21.blend = BlendMode.NORMAL;
		camada21.antialiasing = ClientPrefs.globalAntialiasing;
		camada21.antialiasing = true;

		var camada22 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada22'));
		camada22.blend = BlendMode.NORMAL;
		camada22.antialiasing = ClientPrefs.globalAntialiasing;
		camada22.antialiasing = true;

		var camada51 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada51'));
		camada51.blend = BlendMode.OVERLAY;
		camada51.antialiasing = ClientPrefs.globalAntialiasing;

		var camada52 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada52'));
		camada52.blend = BlendMode.HARDLIGHT;
		camada52.antialiasing = ClientPrefs.globalAntialiasing;
		camada52.alpha = 0.37;
		camada52.antialiasing = true;
		
		lightsOnArray.push(camada22);
		lightsOnArray.push(camada52);
		lightsOnArray.push(camada20);
		lightsOnArray.push(camada21);

		var lightOff = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/lightOff'));
		lightOff.blend = BlendMode.NORMAL;
		lightOff.antialiasing = ClientPrefs.globalAntialiasing;
		lightsOffArray.push(lightOff);

		if(!room.room.isDark)
		{
			camada22.visible = true;
			camada52.visible = true;
			camada20.visible = true;
			camada21.visible = true;
			lightOff.visible = false;
			if(ClientPrefs.data.shaders){
				softlightShader.bitmapOverlay = camada51.pixels;
				game.addUniqueShaderToCam("camGame", softlightShader, 0);
			}
		}
		else
		{
			camada22.visible = false;
			camada52.visible = false;
			camada20.visible = false;
			camada21.visible = false;
			lightOff.visible = true;
			if(ClientPrefs.data.shaders){
				game.removeUniqueShaderFromCam("camGame", softlightShader);
			}
		}

		//This stores : 1-2-3-4 for the eyes ; 5 for small cum crack ; 6 for big cum crack
		var seekInfo:Array<NearSeekData> = [];

		if(room.room.seekData != null){
			if(generateLong) seekInfo = room.roomPostfixes[i].room.seekData;
			else seekInfo = room.room.seekData;
		}

		var paintingSides:Array<String> = [];
		var windowSides:Array<String> = [];
		var furnitureSides:Array<String> = [];
		if(generateLong){
			for(painting in room.roomPostfixes[i].paintings) painting.data.isWindow ? windowSides.push(painting.side) : paintingSides.push(painting.side); 
			for(fur in room.roomPostfixes[i].furniture) furnitureSides.push(fur.side);
		} else {
			for(painting in room.paintings) painting.data.isWindow ? windowSides.push(painting.side) : paintingSides.push(painting.side); 
			for(fur in room.furniture) furnitureSides.push(fur.side);
		}

		for(seek in seekInfo){
			//check if it ain't blocked
			for(s in seek.windowBlockedSides) if(windowSides.contains(s)) continue;
			for(s in seek.paintingBlockedSides) if(paintingSides.contains(s)) continue;
			for(s in seek.furnitureBlockedSides) if(furnitureSides.contains(s)) continue;

			if(seek.id < 5){
				var topLeftPoint = switch(seek.id){
					case 1: new FlxPoint(32, 197);
					case 2:	new FlxPoint(865, 0);
					case 3: new FlxPoint(1561, 284);
					case 4: new FlxPoint(1656, 454);
					default: 
						trace("Seek eyes has an unsupported value!");
						new FlxPoint(0,0);
				}
				var eye = new FlxSprite(topLeftPoint.x, topLeftPoint.y);
				eye.frames = Paths.getSparrowAtlas('story_mode_backgrounds/seek/eyes');
				eye.animation.addByPrefix('idle', switch(seek.id){
					case 1: 'Left/Eye Left';
					case 2:	'Up/Eye Up';
					case 3: 'Right 1/Eye Right 1';
					case 4: 'Right 2/Eye Right 2';
					default: 
						trace("Seek eyes has an unsupported value!");
						'';
				}, 24, true);
				eye.antialiasing = ClientPrefs.globalAntialiasing;
				eye.animation.play('idle', true, false);
				roomToGenerate.add(eye);
			} else if(seek.id == 5) {
				var seekCum = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/seek/seekRoom' + 'Less'));
				seekCum.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(seekCum);
			} else if(seek.id == 6) {
				var seekCumMore = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/seek/seekRoom' + 'More'));
				seekCumMore.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(seekCumMore);
			} else {
				trace("Seek eyes has an unsupported value!");
			}
		}

		//SPAWN PAINTINGS AND WINDOWS
		var paintArray = [];
		if(generateLong){
			paintArray = room.roomPostfixes[i].paintings;
		} else {
			paintArray = room.paintings;
		}
		for(painting in paintArray){
			var topLeftPoint = switch(painting.side){
				case "left": 
					if(painting.data.isWindow) new FlxPoint(0, 230);
					else new FlxPoint(98, 263);
				case "right":
					if(painting.data.isWindow) new FlxPoint(1555, 241);
					else new FlxPoint(1623, 264);
				default:
					trace("Painting/Window isn't on a supported side!");
					new FlxPoint(0,0);
			}

			if(painting.data.isWindow){
				var window = new FlxSprite(topLeftPoint.x, topLeftPoint.y).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/${painting.side}/window'));
				window.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(window);
			} else {
				var paintingSpr:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(topLeftPoint.x, topLeftPoint.y, "").loadGraphic(Paths.image('story_mode_backgrounds/hallway1/paintings/${painting.side}/' + painting.pattern));
				paintingSpr.antialiasing = ClientPrefs.globalAntialiasing;
				roomToGenerate.add(paintingSpr);

				nextRoomFunctions[i].push(function(){
					furniture.push({
						name: "painting",
						sprite: paintingSpr,
						side: painting.side,
						specificAttributes: Lang.getText(painting.pattern, 'story/paintings/${painting.side}')
					});
				});
			}
		}

		if ((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber <= door) {
			//yes dupe
			var firstDoor = new StoryModeSpriteHoverable(567, 301, 'story_mode_backgrounds/hallway1/doors/DoorLeftNoPanel');
			firstDoor.antialiasing = ClientPrefs.globalAntialiasing;

			var panelGroup = new FlxSpriteGroup(597, 351);

			var leftPanel = new FlxSprite(0, 0).loadGraphic(Paths.image("story_mode_backgrounds/hallway1/doors/DoorLeftPanel"));
			leftPanel.antialiasing = ClientPrefs.globalAntialiasing;
			panelGroup.add(leftPanel);

			var txtDoorNumber1 = new FlxText(29, 17, 107, "", 48);
			txtDoorNumber1.text = Std.string((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber);
			if(Std.parseInt(txtDoorNumber1.text) < 10 && Std.parseInt(txtDoorNumber1.text) > 0){
				txtDoorNumber1.text = "0" + Std.string((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber);
			}
			txtDoorNumber1.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
			txtDoorNumber1.antialiasing = ClientPrefs.globalAntialiasing;
			txtDoorNumber1.color = FlxColor.BLACK;
			panelGroup.add(txtDoorNumber1);

			roomToGenerate.add(firstDoor);
			roomToGenerate.add(panelGroup);

			if((generateLong ? room.roomPostfixes[i] : room).leftDoor.hasBeenOpenedOnce != null && (generateLong ? room.roomPostfixes[i] : room).leftDoor.hasBeenOpenedOnce == 1){
				var xOffs = FlxG.random.int(-40, 40, [-3, -2, -1, 0, 1, 2, 3]);
				FlxTween.tween(panelGroup, {y: 609}, 0.3, {ease: FlxEase.bounceOut, onComplete: function(twn){
					MenuSongManager.playSound("bf_sounds/Huh"+FlxG.random.int(1,2), 1.0);
				}});
				FlxTween.tween(panelGroup, {x: panelGroup.x + xOffs}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
				FlxTween.tween(panelGroup, {angle: panelGroup.angle - xOffs/4}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
			} else {
				nextRoomFunctions[i].push(function(){
					doors.push({
						doorNumber: (generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber,
						doorSpr: firstDoor,
						panelGroup: panelGroup,
						side: "left",
						isLocked: (generateLong ? room.roomPostfixes[i] : room).leftDoor.isLocked,
						song: (generateLong ? room.roomPostfixes[i] : room).leftDoor.song
					});
				});
			}
		} else {
			var firstDoor = new StoryModeSpriteHoverable(567, 301, 'story_mode_backgrounds/hallway1/doors/DoorLeft');
			firstDoor.antialiasing = ClientPrefs.globalAntialiasing;
			roomToGenerate.add(firstDoor);
			nextRoomFunctions[i].push(function(){
				doors.push({
					doorNumber: (generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber,
					doorSpr: firstDoor,
					side: "left",
					isLocked: (generateLong ? room.roomPostfixes[i] : room).leftDoor.isLocked,
					song: (generateLong ? room.roomPostfixes[i] : room).leftDoor.song
				});
			});

			var txtDoorNumber1 = new FlxText(firstDoor.x + 88, firstDoor.y + 67, 0, "", 48);
			txtDoorNumber1.text = Std.string((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber);
			if(Std.parseInt(txtDoorNumber1.text) < 10 && Std.parseInt(txtDoorNumber1.text) > 0){
				txtDoorNumber1.text = "0" + Std.string((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber);
			}
			txtDoorNumber1.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
			txtDoorNumber1.antialiasing = ClientPrefs.globalAntialiasing;
			txtDoorNumber1.color = FlxColor.BLACK;
			roomToGenerate.add(txtDoorNumber1);
		}

		if ((generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber <= door) {
			//yes dupe
			var secondDoor = new StoryModeSpriteHoverable(1129, 301, 'story_mode_backgrounds/hallway1/doors/DoorLeftNoPanel');
			secondDoor.antialiasing = ClientPrefs.globalAntialiasing;

			var panelGroup = new FlxSpriteGroup(1159, 351);

			var leftPanel = new FlxSprite(0, 0).loadGraphic(Paths.image("story_mode_backgrounds/hallway1/doors/DoorLeftPanel"));
			leftPanel.antialiasing = ClientPrefs.globalAntialiasing;
			panelGroup.add(leftPanel);

			var txtDoorNumber2 = new FlxText(29, 17, 107, "", 48);
			txtDoorNumber2.text = Std.string((generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber);
			if(Std.parseInt(txtDoorNumber2.text) < 10 && Std.parseInt(txtDoorNumber2.text) > 0){
				txtDoorNumber2.text = "0" + Std.string((generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber);
			}
			txtDoorNumber2.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
			txtDoorNumber2.antialiasing = ClientPrefs.globalAntialiasing;
			txtDoorNumber2.color = FlxColor.BLACK;
			panelGroup.add(txtDoorNumber2);

			roomToGenerate.add(secondDoor);
			roomToGenerate.add(panelGroup);

			if((generateLong ? room.roomPostfixes[i] : room).rightDoor.hasBeenOpenedOnce != null && 
				(generateLong ? room.roomPostfixes[i] : room).rightDoor.hasBeenOpenedOnce == 1){
				var xOffs = FlxG.random.int(-40, 40, [-3, -2, -1, 0, 1, 2, 3]);
				FlxTween.tween(panelGroup, {y: 609}, 0.3, {ease: FlxEase.bounceOut, onComplete: function(twn){
					MenuSongManager.playSound("bf_sounds/Huh"+FlxG.random.int(1,2), 1.0);
				}});
				FlxTween.tween(panelGroup, {x: panelGroup.x + xOffs}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
				FlxTween.tween(panelGroup, {angle: panelGroup.angle - xOffs/4}, 0.2, {ease: FlxEase.bounceOut, startDelay: 0.1});
			} else {
				nextRoomFunctions[i].push(function(){
					doors.push({
						doorNumber: (generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber,
						doorSpr: secondDoor,
						panelGroup: panelGroup,
						side: "right",
						isLocked: (generateLong ? room.roomPostfixes[i] : room).rightDoor.isLocked,
						song: (generateLong ? room.roomPostfixes[i] : room).rightDoor.song
					});
				});
			}
		} else {
			//no dupe
			var secondDoor = new StoryModeSpriteHoverable(1129, 301, "story_mode_backgrounds/hallway1/doors/DoorRight");
			secondDoor.antialiasing = ClientPrefs.globalAntialiasing;
			roomToGenerate.add(secondDoor);
			nextRoomFunctions[i].push(function(){
				doors.push({
					doorNumber: (generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber,
					doorSpr: secondDoor,
					side: "right",
					isLocked: (generateLong ? room.roomPostfixes[i] : room).rightDoor.isLocked,
					song: (generateLong ? room.roomPostfixes[i] : room).rightDoor.song
				});
			});

			var txtDoorNumber2 = new FlxText(secondDoor.x + 88, secondDoor.y + 67, 0, "", 48);
			txtDoorNumber2.text = Std.string((generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber);
			txtDoorNumber2.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
			if(Std.parseInt(txtDoorNumber2.text) < 10 && Std.parseInt(txtDoorNumber2.text) > 0){
				txtDoorNumber2.text = "0" + Std.string((generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber);
			}
			txtDoorNumber2.color = FlxColor.BLACK;
			txtDoorNumber2.antialiasing = ClientPrefs.globalAntialiasing;
	
			roomToGenerate.add(txtDoorNumber2);
		}

		//planks
		if((generateLong ? room.roomPostfixes[i] : room).leftDoor.isLocked || (generateLong ? room.roomPostfixes[i] : room).rightDoor.isLocked){
			var plank = new StoryModeSpriteHoverable(0,0,'story_mode_backgrounds/hallway1/doors/planks');
			plank.antialiasing = ClientPrefs.globalAntialiasing;
			if((generateLong ? room.roomPostfixes[i] : room).leftDoor.isLocked){
				plank.x = 533;
				plank.y = 285;
			}else{
				plank.x = 1097;
				plank.y = 285;
			}
			roomToGenerate.add(plank);
		}

		for(furnitureData in (generateLong ? room.roomPostfixes[i] : room).furniture){
			var topLeftPoint = switch(furnitureData.name){
				case 'table':
					if(furnitureData.side == "left") new FlxPoint(0, 571);
					else new FlxPoint(1396, 568);
				case 'drawer':
					if(furnitureData.side == "left") new FlxPoint(0, 593);
					else new FlxPoint(1250, 588);
				case 'closet':
					if(furnitureData.side == "left") new FlxPoint(0, 131);
					else new FlxPoint(1522, 143);
				default: 
					trace("furniture is an unsupported name.");
					new FlxPoint(0,0);
			}
			var furnitureSpr = new StoryModeSpriteHoverable(topLeftPoint.x,topLeftPoint.y,'story_mode_backgrounds/hallway1/${furnitureData.side}/${furnitureData.name}');
			furnitureSpr.antialiasing = ClientPrefs.globalAntialiasing;
			roomToGenerate.add(furnitureSpr);

			//specific attributes
			switch(furnitureData.name){
				case 'table':
					var gayPaper:FlxSprite = null;
					var gayBook:FlxSprite = null;

					if(furnitureData.specificAttributes.hasPaper){
						var topLeftPaperPoint = furnitureData.side == "left" ? new FlxPoint(237,581) : new FlxPoint(1520,580);
						gayPaper = new StoryModeSpriteHoverable(topLeftPaperPoint.x, topLeftPaperPoint.y, 'story_mode_backgrounds/hallway1/${furnitureData.side}/Paper');
						gayPaper.antialiasing = ClientPrefs.globalAntialiasing;
						roomToGenerate.add(gayPaper);
					}
					if(furnitureData.specificAttributes.hasBooks){
						var topLeftBookPoint = furnitureData.side == "left" ? new FlxPoint(40,576) : new FlxPoint(1702,572);
						gayBook = new FlxSprite(topLeftBookPoint.x, topLeftBookPoint.y).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/${furnitureData.side}/Books'));
						gayBook.antialiasing = ClientPrefs.globalAntialiasing;
						roomToGenerate.add(gayBook);
					}
					nextRoomFunctions[i].push(function(){
						furniture.push({
							name: "table",
							sprite: furnitureSpr,
							side: furnitureData.side,
							specificAttributes: {
								hasPaper: furnitureData.specificAttributes.hasPaper,
								paperModel:furnitureData.specificAttributes.paperModel,
								paperSpr: gayPaper,
								hasBooks: furnitureData.specificAttributes.hasBooks,
								booksModel: furnitureData.specificAttributes.booksModel,
								bookTopic: "",
								bookSpr: gayBook,
							}
						});
					});
				case 'drawer':
					Paths.image('story_mode_backgrounds/hallway1/${furnitureData.side}/OpenDrawer');
					if(furnitureData.specificAttributes.isOpened){
						furnitureSpr.loadGraphic(Paths.image('story_mode_backgrounds/hallway1/${furnitureData.side}/OpenDrawer'));
					} 
					nextRoomFunctions[i].push(function(){
						furniture.push({
							name: "drawer",
							sprite: furnitureSpr,
							side: furnitureData.side,
							specificAttributes: furnitureData.specificAttributes
						});
					});
				case 'closet':
					nextRoomFunctions[i].push(function(){
						furniture.push({
							name: "closet",
							sprite: furnitureSpr,
							side: furnitureData.side,
							specificAttributes: furnitureData.specificAttributes
						});
					});
			}
		}

		if ((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber == 52 || 
			(generateLong ? room.roomPostfixes[i] : room).rightDoor.doorNumber == 52){
			var sign:FlxSprite;

			if((generateLong ? room.roomPostfixes[i] : room).leftDoor.doorNumber == 52) sign = new FlxSprite(506,-7).loadGraphic(Paths.image('JeffShop Sign'));
			else sign = new FlxSprite(1066,-7).loadGraphic(Paths.image('JeffShop Sign'));
	
			sign.setGraphicSize(352, 373);
			sign.updateHitbox();
			sign.antialiasing = ClientPrefs.globalAntialiasing;

			if(DoorsUtil.curRun.rooms[52 - DoorsUtil.curRun.initialDoor].room.bossType == "glitched"){
				glitchedShader = new GlitchPosterize();
				glitchedShader.amount = 0.1;
				add(glitchedShader);
				sign.shader = glitchedShader.shader;
			}

			roomToGenerate.add(sign);
		}
		
		roomToGenerate.add(camada22);
		roomToGenerate.add(camada52);
		roomToGenerate.add(camada20);
		roomToGenerate.add(camada21);
		roomToGenerate.add(lightOff);

		return roomToGenerate;
	}
	public var glitchedShader:GlitchPosterize;

	public function flicker(duration:Float, endWithLight:Bool = true){
		if(DoorsUtil.modifierActive(4)) return;

		var stupidFuckingObjectThing = new FlxSprite(-100, -100).makeGraphic(1, 1, FlxColor.BLACK);

		var localDuration = duration;
		flickerState = true;

		var theOtherSilly:Float = FlxG.random.float(0.04, 0.07);
		FlxFlicker.flicker(stupidFuckingObjectThing, localDuration, theOtherSilly, false, true, function(fuck){
			if(endWithLight) {
				for (l in lightsOnArray){
					l.visible = true;
				}
				if(ClientPrefs.data.shaders){
					var camada51 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada51'));
					camada51.blend = BlendMode.OVERLAY;
					camada51.antialiasing = ClientPrefs.globalAntialiasing;
	
					softlightShader.bitmapOverlay = camada51.pixels;
					game.addUniqueShaderToCam("camGame", softlightShader, 0);
				}
				for (l in lightsOffArray){
					l.visible = false;
				}
			} else {
				for (l in lightsOnArray){
					l.visible = false;
				}
				for (l in lightsOffArray){
					l.visible = true;
				}
				if(ClientPrefs.data.shaders){
					game.removeUniqueShaderFromCam("camGame", softlightShader);
				}
			}
		}, function(flc){
			if(flickerState){
				for (l in lightsOnArray){
					l.visible = false;
				}
				for (l in lightsOffArray){
					l.visible = true;
				}
				if(ClientPrefs.data.shaders){
					game.removeUniqueShaderFromCam("camGame", softlightShader);
				}
			} else {
				for (l in lightsOnArray){
					l.visible = true;
				}
				if(ClientPrefs.data.shaders){
					var camada51 = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/light/camada51'));
					camada51.blend = BlendMode.OVERLAY;
					camada51.antialiasing = ClientPrefs.globalAntialiasing;

					softlightShader.bitmapOverlay = camada51.pixels;
					game.addUniqueShaderToCam("camGame", softlightShader, 0);
				}
	
				for (l in lightsOffArray){
					l.visible = false;
				}
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
			case 'drawer' | 'drawerLong':
				drawerShit(furSprite, furName, side, specificAttributes, elapsed);
			case 'table':
				if(specificAttributes.paperSpr != null){
					specificAttributes.paperSpr.checkOverlap(camGame);
					if(specificAttributes.paperSpr.isHovered){
						if(FlxG.mouse.justPressed){
							StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
								StoryMenuState.instance.persistentUpdate = false;
								StoryMenuState.instance.openSubState(new PaperSubState(specificAttributes.paperModel));
							});
						}
						StoryMenuState.instance.lookingIcon = true;
					}
				}
				if(specificAttributes.bookSpr != null){
					specificAttributes.bookSpr.checkOverlap(camGame);
					if(specificAttributes.bookSpr.isHovered){
						if(FlxG.mouse.justPressed){
							StoryMenuState.instance.updateDescription(StringTools.replace(Lang.getText("books", "story/interactions"), "{0}", specificAttributes.bookTopic));
						}
						StoryMenuState.instance.lookingIcon = true;
					}
				}
			case 'closet' | 'closetLong':
				if(furSprite.isHovered && FlxG.mouse.justPressed){
					closetShit(furSprite, furName, side, specificAttributes, elapsed);
				}
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

			if(!generateLong) return;

			for(j=>r in DoorsUtil.curRun.currentRoom.roomPostfixes){
				for(i=>fur in r.furniture){
					if(fur.side == side && fur.name == furName){
						DoorsUtil.curRun.currentRoom.roomPostfixes[j].furniture[i].specificAttributes = {
							hasJack: false
						};
					}
				}
			}
			StoryMenuState.instance.saveData();
		}


		if(specificAttributes.hasJack){
			StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
				StoryMenuState.instance.saveData();
	
				CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
				PlayState.isStoryMode = true;
	
				PlayState.storyDifficulty = StoryMenuState.instance.curDifficulty;
				PlayState.targetDoor = door;
				var replacement = DoorsUtil.curRun.getReplacementSong(specificAttributes.jackSong, door, "jack");
				if(replacement == "None"){
					return;
				}
	
				StoryMenuState.instance.selectedWeek = true;
				PlayState.storyPlaylist = [replacement];
				
				var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), StoryMenuState.instance.curDifficulty);
	
				var songSelectedName = PlayState.storyPlaylist[0].toLowerCase();
				if(Song.checkChartExists(poop, songSelectedName)){
					PlayState.SONG = Song.loadFromJson(poop, songSelectedName);
				}
				else{
					PlayState.SONG = Song.loadFromJson(songSelectedName, songSelectedName);
				}
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		} else {
			StoryMenuState.instance.theMouse.startLongAction(0.3, function(){
				if(!isInCloset) enterCloset(furName);
				else leaveCloset();
			});
		}

		emptyCloset();
	}

	function drawerShit(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		function emptyDrawer(?open:Bool = true){
			for(i=>fur in DoorsUtil.curRun.currentRoom.furniture){
				if(fur.side == side && fur.name.replace("Long", "") == furName.replace("Long", "")){
					DoorsUtil.curRun.currentRoom.furniture[i].specificAttributes = {
						hasTimothy: false,
						hasItem: false,
						howMuchMoney: 0,
						isOpened: open
					};
				}
			}

			for(i=>fur in furniture){
				if(fur.side == side && fur.name.replace("Long", "") == furName.replace("Long", "")){
					furniture[i].specificAttributes = {
						hasTimothy: false,
						hasItem: false,
						howMuchMoney: 0,
						isOpened: open
					};
				}
			}
			

			if(!generateLong) return;

			for(j=>r in DoorsUtil.curRun.currentRoom.roomPostfixes){
				for(i=>fur in r.furniture){
					if(fur.side == side && fur.name == furName){
						DoorsUtil.curRun.currentRoom.roomPostfixes[j].furniture[i].specificAttributes = {
							hasTimothy: false,
							hasItem: false,
							howMuchMoney: 0,
							isOpened: open
						};
					}
				}
			}

			StoryMenuState.instance.saveData();
		}

		if(furSprite.isHovered){
			if(FlxG.mouse.justPressed){
				StoryMenuState.instance.theMouse.startLongAction(1.5, function(){
					for(i=>fur in StoryMenuState.instance.furniture){
						if(fur.side == side && fur.name == furName && fur.specificAttributes.isOpened){
							if(furName == "drawer"){
								furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway1/${side}/drawer'));
							} else {
								if(room.room.isDark){
									furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/dark/${furName.replace("Long", "")}${side.toLowerCase()}'));
								} else {
									furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/lit/${furName.replace("Long", "")}${side.toLowerCase()}'));
								}
							}
							MenuSongManager.playSound("DrawerOpen",1.0);
							emptyDrawer(false);
							return;
						}
					}
					
					if(furName == "drawer"){
						furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway1/${side}/OpenDrawer'));
					} else {
						if(room.room.isDark){
							furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/dark/${furName.replace("Long", "")}${side.toLowerCase()}Open'));
						} else {
							furSprite.loadGraphic(Paths.image('story_mode_backgrounds/hallway3/lit/${furName.replace("Long", "")}${side.toLowerCase()}Open'));
						}
					}

					MenuSongManager.playSound("DrawerOpen",1.0);

					if(specificAttributes.hasItem){
						var itemChosenStr:String = specificAttributes.theItem;
						var theActualItem:Item = InventoryManager.fromItemIDtoItem(itemChosenStr);

						switch(itemChosenStr){
							case "lighter":
								theActualItem.itemData.durabilityRemaining = FlxG.random.float(10, 25);
							case "flashlight" | "candle":
								theActualItem.itemData.durabilityRemaining = FlxG.random.float(20, 40);
						}

						var result = DoorsUtil.curRun.curInventory.addItem(theActualItem);
						if(result){
							StoryMenuState.instance.persistentUpdate = false;
							StoryMenuState.instance.openSubState(new ItemGetSubState(theActualItem));
						}
						emptyDrawer(true);
						return;
					} else if (specificAttributes.hasTimothy){
						emptyDrawer(true);

						if(room.room.isDark) {
							var darkAmnt = FlxG.random.getObject([10, 20, 50]);
							add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.80, darkAmnt, StoryMenuState.instance.moneyIndicator, false, false, camHUD));
							add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.88, Math.floor(darkAmnt/25), StoryMenuState.instance.knobIndicator, true, true, camHUD));
						}

						CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
						PlayState.isStoryMode = true;

						PlayState.storyDifficulty = StoryMenuState.instance.curDifficulty;
						PlayState.targetDoor = door;

						var replacement = DoorsUtil.curRun.getReplacementSong(specificAttributes.timSong, door, "timothy");

						if(replacement == "None"){
							return;
						}
						StoryMenuState.instance.selectedWeek = true;
						PlayState.storyPlaylist = [replacement];
						
						var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), StoryMenuState.instance.curDifficulty);

						var songSelectedName = PlayState.storyPlaylist[0].toLowerCase();
						if(Song.checkChartExists(poop, songSelectedName)){
							PlayState.SONG = Song.loadFromJson(poop, songSelectedName);
						}
						else{
							PlayState.SONG = Song.loadFromJson(songSelectedName, songSelectedName);
						}
						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;
						
						LoadingState.loadAndSwitchState(new PlayState(), true);
						return;
					} else if (specificAttributes.howMuchMoney > 0){
						add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.80, specificAttributes.howMuchMoney, StoryMenuState.instance.moneyIndicator, false, false, camHUD));
						add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.88, Math.floor(specificAttributes.howMuchMoney/25), StoryMenuState.instance.knobIndicator, true, true, camHUD));
					
						emptyDrawer(true);
						return;
					} else {
						emptyDrawer(true);
					}
				});
			}
		}
	}

	override function update(elapsed){
		if(generateLong){
			//handle softDoors
			if(softDoorsLocked != null) {
				for(i=>softDoor in softDoors){
					softDoor.checkOverlap(camGame);
					if(!StoryMenuState.instance.entityComing){
						if(softDoor.isHovered && FlxG.mouse.justPressed && !softDoorsLocked[i]){
							StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
								activateNextRoom(i+1);
							});
						} else if (softDoorsLocked[i] && FlxG.mouse.justPressed && softDoor.isHovered){
							StoryMenuState.instance.updateDescription(Lang.getText("darkSight", "story/interactions"));
						}
					}


					if(softDoor.justHovered){
						/*for(j in 0...softDoorArrows.length){
							FlxTween.cancelTweensOf(softDoorArrows[i]);
							if(i == j)
								FlxTween.tween(softDoorArrows[i], {alpha: 1}, 0.6, {ease: FlxEase.circInOut});
							else
								FlxTween.tween(softDoorArrows[j], {alpha: 0}, 0.6, {ease: FlxEase.circInOut});
						}*/
					}
				}
			}
		}

		if(isInCloset && FlxG.mouse.justPressed) {
			StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
				leaveCloset();
			});
		}

		super.update(elapsed);
	}

	//1 is left, 2 is right
	function activateNextRoom(side:Int){
		if(!generateLong) return;

		var transitionSpr = new BGSprite("transitions/trans", 0, 0, 0, 0, ["TransitionIn_"], false);
		transitionSpr.animation.addByPrefix("out", "TransitionIn_", 24, false);
		transitionSpr.cameras = [camHUD];
		transitionSpr.scale.set(1280/1920, 1280/1920);
		transitionSpr.updateHitbox();
		transitionSpr.screenCenter();
		transitionSpr.visible = true;
		add(transitionSpr);

		transitionSpr.animation.play("out",true, false, 0);
		transitionSpr.flipX = (side == 1 ? true : false);
		new FlxTimer().start(0.35, function(tmr:FlxTimer) {
			transitionSpr.animation.play("out",true, true, 0);
			transitionSpr.flipX = (side == 1 ? false : true);

			//also spawn the room you chose, and activate it's properties
			StoryMenuState.instance.furniture = [];
			StoryMenuState.instance.doors = [];
			softDoors = [];

			add(nextRooms[side-1]);

			for(f in nextRoomFunctions[side-1]){
				f();
			}

			darkCreate();

			new FlxTimer().start(0.35, function(tmr:FlxTimer) {
				transitionSpr.visible = false;
				darkCreatePost();
			});
		});
	}

	function enterCloset(closetName:String) {
		isInCloset = true;
		StoryMenuState.instance.inSubState = true;

		switch(closetName.toLowerCase()){
			case "closet":
				StoryMenuState.instance.closetForeground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/hallway1/closet/ClosetDoors"));
				StoryMenuState.instance.closetForeground.antialiasing = ClientPrefs.globalAntialiasing;
		
				StoryMenuState.instance.closetBackground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/hallway1/closet/" + room.room.roomColor + "BG"));
				StoryMenuState.instance.closetBackground.antialiasing = ClientPrefs.globalAntialiasing;
				StoryMenuState.instance.closetBackground.color = 0xFFc9c9c9;
			case "closetlong":
				StoryMenuState.instance.closetForeground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/hallway3/closet/ClosetDoors"));
				StoryMenuState.instance.closetForeground.antialiasing = ClientPrefs.globalAntialiasing;
		
				StoryMenuState.instance.closetBackground = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/hallway3/closet/" + room.room.roomColor + "BG"));
				StoryMenuState.instance.closetBackground.antialiasing = ClientPrefs.globalAntialiasing;
				StoryMenuState.instance.closetBackground.color = 0xFFc9c9c9;
		}


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