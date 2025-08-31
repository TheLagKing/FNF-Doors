package states.storyrooms.roomTypes;

import shaders.HaltChromaticAberration;

class Figure extends BaseSMRoom {
	var figureChroma:HaltChromaticAberration;

	var video:DoorsVideoSprite;
	var camVideo:FlxCamera;

    override function create() { 
        drawFigureRoom();
    }

	private function drawFigureRoom(){
		var figoor = new FlxSprite(0, 0);

		if(door != 99){
			figoor.loadGraphic(Paths.image('story_mode_backgrounds/figure/Room49'));
		} else {
			figoor.loadGraphic(Paths.image('story_mode_backgrounds/figure100/Dark'));
			var figoorLight = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/figure100/Normal'));
			figoorLight.antialiasing = ClientPrefs.globalAntialiasing;
			figoorLight.alpha = 0.00001;
			add(figoorLight);
		}
		figoor.antialiasing = ClientPrefs.globalAntialiasing;
		add(figoor);

		if(door != 99){
			Paths.video('figuracutscene');

			var door = new StoryModeSpriteHoverable(850, 426, 'story_mode_backgrounds/figure/doorHitbox');
			door.antialiasing = ClientPrefs.globalAntialiasing;
			door.alpha = 0.00001;
			add(door);
			doors.push({
				doorNumber: 50,
				doorSpr: door,
				side: "right",
				isLocked: false,
				song: room.rightDoor.song
			});
			
			var txtDoorNumber1 = new FlxText(910, 373, 100, "", 36);
			txtDoorNumber1.text = Std.string(room.rightDoor.doorNumber);
			if(Std.parseInt(txtDoorNumber1.text) < 10){
				txtDoorNumber1.text = "0" + Std.string(room.rightDoor.doorNumber);
			}
			txtDoorNumber1.setFormat(FONT, 36, FlxColor.BLACK, CENTER);
			txtDoorNumber1.antialiasing = true;
			txtDoorNumber1.color = FlxColor.BLACK;
			add(txtDoorNumber1);

			camVideo = new FlxCamera();
			camVideo.bgColor.alpha = 0;
			FlxG.cameras.add(camVideo, false);

			video = new DoorsVideoSprite().preload(Paths.video('figuracutscene'), []);
			video.onReady.add(()->{
				video.setGraphicSize(FlxG.width);
				video.updateHitbox();
				video.screenCenter();
			});
			video.cameras = [camVideo];
			add(video);
		} else {
			var firstDoor = new StoryModeSpriteHoverable(733, 232, '');
			firstDoor = cast firstDoor.makeGraphic(453, 325, FlxColor.BLACK);
			firstDoor.antialiasing = ClientPrefs.globalAntialiasing;
			firstDoor.alpha = 0.00001;
			add(firstDoor);
			doors.push({
				doorNumber: 100,
				doorSpr: firstDoor,
				side: "left",
				isLocked: false,
				song: room.rightDoor.song
			});
			
			var secondDoor = new StoryModeSpriteHoverable(1215, 408, '');
			secondDoor = cast secondDoor.makeGraphic(33, 70, FlxColor.BLACK);
			secondDoor.antialiasing = ClientPrefs.globalAntialiasing;
			secondDoor.alpha = 0.00001;
			add(secondDoor);
			doors.push({
				doorNumber: 100,
				doorSpr: secondDoor,
				side: "right",
				isLocked: false,
				song: room.rightDoor.song
			});
		}
		
		figureChroma = new HaltChromaticAberration();
		figureChroma.k = 0.0;
		figureChroma.kcube = 0.0;
		figureChroma.offset = 0.0;
		add(figureChroma);

		game.addUniqueShaderToCam("camGame", figureChroma, 2);

		game.hasTransitionShader = true;
		FlxG.camera.zoom = 0.7;
	}

	override function onDoorOpen(selectedDoor:DoorAttributes){
		if(selectedDoor.doorNumber == 50) {
			new FlxTimer().start(5.55, function(tmr:FlxTimer){
				video.playVideo();
				MenuSongManager.crossfade("", 0, 120, true);
			});
		}
	}

	override function onDoorOpenPost(selectedDoor:DoorAttributes){ 
		FlxTween.tween(figureChroma, {offset: -1}, 10);
	}
}