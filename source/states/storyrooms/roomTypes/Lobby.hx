package states.storyrooms.roomTypes;

import states.MainMenuState.InteractibleMenuItem;
import openfl.display.BlendMode;

class Lobby extends BaseSMRoom {
    var bobsBookOutline:StoryModeSpriteHoverable;
    override function create() { 
        drawLobby();
		makeVideo();
    }

	var boombox:InteractibleMenuItem;
	private function drawLobby(){
		Paths.image("bobsBook/blank");
        for(i in 1...13){
            Paths.image("bobsBook/leftpage/page" + i);
        }

		var lobby = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/lobby/Lobby'));
		lobby.antialiasing = ClientPrefs.globalAntialiasing;

		var carpet = new FlxSprite(470, 705).loadGraphic(Paths.image('story_mode_backgrounds/lobby/carpet'));
		carpet.antialiasing = ClientPrefs.globalAntialiasing;

		var insideLight = new StoryModeSpriteHoverable(101, 387, 'story_mode_backgrounds/lobby/insideLight', 'light');
		insideLight.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(insideLight);

		var insidePlank = new StoryModeSpriteHoverable(196, 348, 'story_mode_backgrounds/lobby/insidePlank', 'dust');
		insidePlank.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(insidePlank);

		var insideShading = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/lobby/insideShading'));
		insideShading.antialiasing = true;
		insideShading.alpha = 0.8;
		insideShading.blend = BlendMode.HARDLIGHT;

		var booth = new FlxSprite(0, 130).loadGraphic(Paths.image('story_mode_backgrounds/lobby/booth'));
		booth.antialiasing = ClientPrefs.globalAntialiasing;

		var insideBell = new StoryModeSpriteHoverable(422, 579, 'story_mode_backgrounds/lobby/insideBell', 'bell');
		insideBell.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(insideBell);
        furniture.push({
            name: "bell",
            sprite: insideBell,
            side: "any",
            specificAttributes: null
        });

		var pillar = new FlxSprite(675, 181).loadGraphic(Paths.image('story_mode_backgrounds/lobby/pillar'));
		pillar.antialiasing = ClientPrefs.globalAntialiasing;
		
		var painting = new StoryModeSpriteHoverable(833, 268, 'story_mode_backgrounds/lobby/painting', 'painting');
		painting.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(painting);

		var assZone = new StoryModeSpriteHoverable(632, 441, 'story_mode_backgrounds/lobby/assZone', 'dust');
		assZone.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(assZone);
		
		var bobsBook = new StoryModeSpriteHoverable(726, 656, 'story_mode_backgrounds/lobby/bobsBook');
		bobsBook.antialiasing = ClientPrefs.globalAntialiasing;
        furniture.push({
            name: "bobsBook",
            sprite: bobsBook,
            side: "any",
            specificAttributes: null
        });

		bobsBookOutline = new StoryModeSpriteHoverable(726, 656, 'story_mode_backgrounds/lobby/bobsBookOutline');
		bobsBookOutline.antialiasing = ClientPrefs.globalAntialiasing;
		bobsBookOutline.alpha = 0.00001;

		var chandelier = new StoryModeSpriteHoverable(1019, 50, 'story_mode_backgrounds/lobby/chandelier', 'light');
		chandelier.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(chandelier);

		var plant1 = new StoryModeSpriteHoverable(558, 473, 'story_mode_backgrounds/lobby/plant1', 'tree');
		plant1.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(plant1);

		var plant2 = new StoryModeSpriteHoverable(997, 455, 'story_mode_backgrounds/lobby/plant2', 'tree');
		plant2.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(plant2);

		var plant3 = new StoryModeSpriteHoverable(1425, 455, 'story_mode_backgrounds/lobby/plant3', 'tree');
		plant3.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(plant3);

		var yosibu = new StoryModeSpriteHoverable(1585, 172, 'story_mode_backgrounds/lobby/chad', 'gold');
		yosibu.antialiasing = ClientPrefs.globalAntialiasing;
		StoryMenuState.instance.clickableThings.push(yosibu);
		
		var randomBag = new FlxSprite(0, 799).loadGraphic(Paths.image('story_mode_backgrounds/lobby/randomBag'));
		randomBag.antialiasing = ClientPrefs.globalAntialiasing;
		
		var couch = new FlxSprite(1684, 453).loadGraphic(Paths.image('story_mode_backgrounds/lobby/couch'));
		couch.antialiasing = ClientPrefs.globalAntialiasing;
		
		var outsideShading = new FlxSprite(0, 0).loadGraphic(Paths.image('story_mode_backgrounds/lobby/outsideShading'));
		outsideShading.antialiasing = true;
		outsideShading.alpha = 0.8;
		outsideShading.blend = BlendMode.HARDLIGHT;

		var globalShading = new FlxSprite(0, 0).loadGraphic(Paths.image("story_mode_backgrounds/lobby/globalShading"));
		globalShading.antialiasing = true;
		globalShading.blend = BlendMode.MULTIPLY;
	
		var door = new StoryModeSpriteHoverable(1166, 281, 'story_mode_backgrounds/hallway1/doors/DoorRight');
		door.antialiasing = ClientPrefs.globalAntialiasing;
        doors.push({
            doorNumber: 1,
            doorSpr: door,
            side: "right",
            isLocked: false,
            song: "None"
        });

		// door 1 1166 281 1280 384

		var txtDoorNumber1 = new FlxText(door.x + 88, door.y + 67, 0, "", 48);
		txtDoorNumber1.text = Std.string(1);
		if(Std.parseInt(txtDoorNumber1.text) < 10){
			txtDoorNumber1.text = "0" + Std.string(1);
		}
		txtDoorNumber1.setFormat(FONT, 48, FlxColor.BLACK, CENTER);
		txtDoorNumber1.antialiasing = true;
		txtDoorNumber1.color = FlxColor.BLACK;

		boombox = new InteractibleMenuItem(145, 677, 'story_mode_backgrounds/lobby/boombox');
		boombox.onClick = function(){
			if(DoorsUtil.curRun.runEncounters.contains("guidance")) {
				StoryMenuState.instance.updateDescription(Lang.getText("guidancePlayed", "story/interactions"));
				return;
			}
			
			StoryMenuState.instance.saveData();

			PlayState.isStoryMode = true;

			StoryMenuState.instance.selectedWeek = true;

			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
			
			PlayState.storyDifficulty = StoryMenuState.instance.curDifficulty;
			PlayState.targetDoor = 0;
			PlayState.storyPlaylist = ["guidance"];

			var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), StoryMenuState.instance.curDifficulty);
			var songSelectedName = PlayState.storyPlaylist[0].toLowerCase();
			
			if(Song.checkChartExists(poop, songSelectedName)) {
				PlayState.SONG = Song.loadFromJson(poop, songSelectedName);
			}
			else{
				PlayState.SONG = Song.loadFromJson(songSelectedName, songSelectedName);
			}
			
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			
			LoadingState.loadAndSwitchState(new PlayState(), true);
		}

		add(lobby);
		add(carpet);
		add(insideLight);
		add(insidePlank);
		add(insideShading);
		add(booth);
		add(insideBell);
		add(pillar);
		add(painting);
		add(assZone);
		add(bobsBook);
		add(bobsBookOutline);
		add(chandelier);
		add(plant1);
		add(plant2);
		add(plant3);
		add(yosibu);
		add(randomBag);
		add(couch);
		add(door);
		add(txtDoorNumber1);
		add(outsideShading);
		add(globalShading);
		add(boombox);
	}

	var video:DoorsVideo;
	function makeVideo() {
		var camVideo = new FlxCamera();
		camVideo.bgColor.alpha = 0;
		FlxG.cameras.add(camVideo, false);

		video = new DoorsVideo(Paths.video('lobby_cutscene'), true, true, false);
		video.cameras = [camVideo];
		add(video);
	}

	override function onDoorOpen(selectedDoor:DoorAttributes){
		StoryMenuState.instance.camHUD.fade(FlxColor.BLACK, 1.4, false);
		new FlxTimer().start(1.4, function(tmr:FlxTimer){
			video.play();
			MenuSongManager.changeSongVolume(0, 1);
		});
		new FlxTimer().start(29.4, function(tmr:FlxTimer){
			video.play();
			MenuSongManager.changeSongVolume(1, 1);
		});
	}

    override function update(elapsed:Float) { 
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 8, 0, 1);
        bobsBookOutline.alpha = FlxMath.lerp(bobsBookOutline.alpha, 0.0001, lerpVal/4);
    }
    
    override function beatHit(curBeat:Int) { 
		boombox.onBeatHit(curBeat);
        if(curBeat % 4 == 0) {
            bobsBookOutline.alpha = 0.4;
        }
    }

    override function onHandleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		switch(furName){
			case "bobsBook":
				if(furSprite.isHovered){
					if(furSprite.justHovered){
						furSprite.loadGraphic(Paths.image("story_mode_backgrounds/lobby/bobsBookOutline"));
					}
					if(FlxG.mouse.justPressed){
						StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
							StoryMenuState.instance.persistentUpdate = false;
							StoryMenuState.instance.openSubState(new BobsBookSubState());
						});
					}
				} else if (furSprite.justStoppedHovering){
					furSprite.loadGraphic(Paths.image("story_mode_backgrounds/lobby/bobsBook"));
				} 
			case "bell":
				if(furSprite.isHovered){
					if(FlxG.mouse.justPressed){
						AwardsManager.anyoneHome = true;
					}
				}
		}
    }
}