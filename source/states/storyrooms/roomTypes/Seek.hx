package states.storyrooms.roomTypes;

import shaders.HaltChromaticAberration;

class Seek extends BaseSMRoom {
	var seekChroma:HaltChromaticAberration;
    override function create() { 
        drawSeekRoom(room.rightDoor.doorNumber == 30);
    }

	private function drawSeekRoom(?first:Bool = true){
		var seekbg = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/rooms/wallred'));
		seekbg.antialiasing = ClientPrefs.globalAntialiasing;
		
		var carpet = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/hallway1/carpets/carpetred'));
		carpet.antialiasing = ClientPrefs.globalAntialiasing;

		var door = new StoryModeSpriteHoverable(848, 300, 'story_mode_backgrounds/hallway1/doors/DoorRight');
		door.antialiasing = ClientPrefs.globalAntialiasing;
        doors.push({
            doorNumber: room.rightDoor.doorNumber,
            doorSpr: door,
            side: "right",
            isLocked: false,
            song: room.rightDoor.song
        });

		var txtDoorNumber1 = new FlxText(door.x + 88, door.y + 67, 0, "", 48);
		txtDoorNumber1.text = Std.string(room.rightDoor.doorNumber);
		txtDoorNumber1.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
		txtDoorNumber1.antialiasing = true;
		txtDoorNumber1.color = FlxColor.BLACK;

		var seekCum = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/seek/seekRoom' + (first ? 'Less':'More')));
		seekCum.antialiasing = ClientPrefs.globalAntialiasing;

		var eyeLeft = new FlxSprite(32, 197);
		eyeLeft.frames = Paths.getSparrowAtlas('story_mode_backgrounds/seek/eyes');
		eyeLeft.animation.addByPrefix('idle', 'Left/Eye Left', 24, true);
		eyeLeft.antialiasing = ClientPrefs.globalAntialiasing;
		eyeLeft.animation.play('idle', true, false);

		var eyeUp = new FlxSprite(865, 0);
		eyeUp.frames = Paths.getSparrowAtlas('story_mode_backgrounds/seek/eyes');
		eyeUp.animation.addByPrefix('idle', 'Up/Eye Up', 24, true);
		eyeUp.antialiasing = ClientPrefs.globalAntialiasing;
		eyeUp.animation.play('idle', true, false);

		var eyeRight1 = new FlxSprite(1561, 284);
		eyeRight1.frames = Paths.getSparrowAtlas('story_mode_backgrounds/seek/eyes');
		eyeRight1.animation.addByPrefix('idle', 'Right 1/Eye Right 1', 24, true);
		eyeRight1.antialiasing = ClientPrefs.globalAntialiasing;
		eyeRight1.animation.play('idle', true, false);

		var eyeRight2 = new FlxSprite(1656, 454);
		eyeRight2.frames = Paths.getSparrowAtlas('story_mode_backgrounds/seek/eyes');
		eyeRight2.animation.addByPrefix('idle', 'Right 2/Eye Right 2', 24, true);
		eyeRight2.antialiasing = ClientPrefs.globalAntialiasing;
		eyeRight2.animation.play('idle', true, false);

		add(seekbg);
		add(carpet);
		add(eyeLeft);
		add(eyeUp);
		add(eyeRight1);
		add(eyeRight2);
		add(door);
		//add(txtDoorNumber1);
		add(seekCum);

		seekChroma = new HaltChromaticAberration();
		seekChroma.k = 0.0;
		seekChroma.kcube = 0.0;
		seekChroma.offset = 0.0;
		add(seekChroma);
		game.addUniqueShaderToCam("camGame", seekChroma, 2);
		
		game.hasTransitionShader = true;
	}

	override function onDoorOpenPost(selectedDoor:DoorAttributes){ 
		FlxTween.tween(seekChroma, {offset: -1}, 10);
	}
}