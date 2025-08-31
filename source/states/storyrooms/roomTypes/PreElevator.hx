package states.storyrooms.roomTypes;

import flixel.math.FlxRect;
import states.MainMenuState.InteractibleMenuItem;
import flixel.FlxSubState;
import sys.FileSystem;

class PreElevator extends BaseSMRoom {
	// UI Elements
	private var bobsBookOutline:StoryModeSpriteHoverable;
	private var lobby:FlxSprite;
	private var iron1:FlxSprite;
	private var iron2:FlxSprite;
	private var gold:FlxSprite;
	private var button:InteractibleMenuItem;
	private var bg:InteractibleMenuItem;

	//Title Card
	private var titleCard:FlxSprite;
	
	// State management
	private var nextSub:String = "explanation";
	private var clickedOnButton:Bool = false;
	private var curTimer:FlxTimer;
	private var lock = new sys.thread.Lock();
	private var mustShake:Bool = true;

	override function create() { 
		StoryMenuState.instance.canUseShowStats = false;
		preloadLobby();
		drawElevator();
		startElevatorShake();
	}
	
	private function startElevatorShake():Void {
		camGame.shake(0.003, 3600, null, true, Y);
	}

	private function preloadLobby():Void {
		var allFiles = FileSystem.readDirectory("assets/images/story_mode_backgrounds/lobby/");
		for(file in allFiles) {
			var splitFile = file.split(".");
			if(splitFile[1] == "png") {
				Paths.image('story_mode_backgrounds/lobby/${splitFile[0]}');
			}
		}
		
		Paths.image("bobsBook/blank");
		for(i in 1...13) {
			Paths.image("bobsBook/leftpage/page" + i);
		}
	}

	private function drawElevator():Void {
		setupLobby();
		setupGates();
		setupBackground();
		setupButton();
		setupTitleCard();
	}
	
	private function setupBackground():Void {
		bg = new InteractibleMenuItem(0, 0, 'story_mode_backgrounds/pre/bg', FlxRect.get(722, 180, 476, 791));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.isBlocked = function() {
			return nextSub != "leave";
		};
		bg.onJustHovered = function() {};
		bg.onJustUnhover = function() {};
		add(bg);
	}
	
	private function setupGates():Void {
		iron1 = new FlxSprite(728, 178).loadGraphic(Paths.image('story_mode_backgrounds/pre/IronGate1'));
		iron1.antialiasing = ClientPrefs.globalAntialiasing;
		
		iron2 = new FlxSprite(957, 178).loadGraphic(Paths.image('story_mode_backgrounds/pre/IronGate2'));
		iron2.antialiasing = ClientPrefs.globalAntialiasing;
		
		gold = new FlxSprite(728, 182).loadGraphic(Paths.image('story_mode_backgrounds/pre/GoldGate'));
		gold.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(iron1);
		add(iron2);
		add(gold);
	}
	
	private function setupButton():Void {
		button = new InteractibleMenuItem(1293, 435, 'story_mode_backgrounds/pre/button');
		button.antialiasing = ClientPrefs.globalAntialiasing;
		button.isBlocked = function() {
			return nextSub != "leave";
		};
		button.onJustHovered = function() {};
		button.onJustUnhover = function() {};
		add(button);
	}
	
	private function setupLobby():Void {
		lobby = new FlxSprite(350, 0).loadGraphic(Paths.image('startingpoint/LobbyBG'));
		lobby.scale.set(0.8, 0.8);
		lobby.antialiasing = ClientPrefs.globalAntialiasing;
		add(lobby);
	}

	private function setupTitleCard():Void {
		titleCard = new FlxSprite(0,0).loadGraphic(Paths.image("titlecards/f1"));
		titleCard.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		titleCard.alpha = 0;
		titleCard.screenCenter();
		titleCard.antialiasing = ClientPrefs.globalAntialiasing;
	}

	function endTheElevatorSequence(theReturn:Void->Void):Void {
		if(StoryMenuState.instance.selectedWeek) return;
		FlxG.sound.play(Paths.sound('dingding'), 1);
		camGame.shake(0.003, 0.3, function() {}, true);
		
		// Animate gold gate
		FlxTween.tween(gold, {y: gold.y - 800}, 1.5, {
			ease: FlxEase.quintInOut, 
			onComplete: function(twn) {
				gold.visible = false;
			}
		});
		
		// Animate iron gates
		new FlxTimer().start(1.3, function(tmr) {
			FlxTween.tween(iron1, {x: iron1.x - 300}, 1.5, {
				ease: FlxEase.quintInOut, 
				onComplete: function(twn) {
					iron1.visible = false;
				}
			});
			
			FlxTween.tween(iron2, {x: iron2.x + 300}, 1.5, {
				ease: FlxEase.quintInOut, 
				onComplete: function(twn) {
					iron2.visible = false;
					add(titleCard);
					
					if(FlxG.random.int(0, 2000) == 5) MenuSongManager.playSound("titlecard/hotel_fart", 1);
					else MenuSongManager.playSound("titlecard/hotel", 1);

					MenuSongManager.changeSongVolume(0.1, 0.6);
					FlxTween.tween(titleCard, {"scale.x": 1.15, "scale.y": 1.15}, 8, {ease:FlxEase.linear});
					FlxTween.tween(titleCard, {alpha: 1}, 0.6, {ease:FlxEase.quartIn, onComplete: function(twn){
						new FlxTimer().start(4, function(tmr) {
							theReturn();
						});
					}});
				}
			});
		});
	}

	override function beatHit(curBeat:Int) {
		if(nextSub == "leave" && !StoryMenuState.instance.selectedWeek) {
			button.onBeatHit(curBeat);
			bg.onBeatHit(curBeat);
		}
	}

	override function openSubState(subState:FlxSubState) {
		if(curTimer == null || curTimer.finished) return;
		curTimer.active = false;
	}

	override function closeSubState() {
		if(curTimer == null || curTimer.finished)
			goToNewSub();
		else 
			curTimer.active = true;
	}

	function goToNewSub():Void {
		switch(nextSub) {
			case "explanation":
				handleExplanationState();
			case "difficulty":
				handleDifficultyState();
			case "modifiers":
				handleModifiersState();
			case "shop":
				handleShopState();
			case "leave":
				handleLeaveState();
		}
	}
	
	private function handleExplanationState():Void {
		curTimer = new FlxTimer().start(1.5, function(tmr) {
			StoryMenuState.instance.openSubState(new PrerunTutorialSubState());
		});
		nextSub = "difficulty";
	}
	
	private function handleDifficultyState():Void {
		curTimer = new FlxTimer().start(2, function(tmr) {
			StoryMenuState.instance.openSubState(new RunDifficultySelectSubState());
		});
		nextSub = "modifiers";
	}
	
	private function handleModifiersState():Void {
		curTimer = new FlxTimer().start(1.6, function(tmr) {
			StoryMenuState.instance.openSubState(new ModifierSelectSubState());
		});
		nextSub = "shop";
	}
	
	private function handleShopState():Void {
		trace(DoorsUtil.curRun.runModifiers);
		Main.execAsync(function() {
			DoorsUtil.curRun = new DoorsRun(
				'F1',
				DoorsUtil.wantedDiff, 
				DoorsUtil.curRun.runModifiers, 
				DoorsUtil.curRun.runKnobModifier
			);
			lock.release();
		});

		curTimer = new FlxTimer().start(0.8, function(tmr) {
			StoryMenuState.instance.openSubState(new PrerunShopSubState());
		});
		nextSub = "leave";
	}
	
	private function handleLeaveState():Void {
		setupLeaveButtonInteractions();
		
		curTimer = new FlxTimer().start(5, function(tmr) {
			endTheElevatorSequence(function() {
				lock.wait();
				finishElevatorSequence();
			});
		});
	}
	
	private function setupLeaveButtonInteractions():Void {
		button.onJustHovered = function() {
			button.normal.alpha = 0.001;
			button.outline.alpha = 1;
		};
		
		button.onJustUnhover = function() {
			button.normal.alpha = 1;
			button.outline.alpha = 0.001;
		};
		
		button.onClick = function() {
			if(StoryMenuState.instance.selectedWeek) return;
			StoryMenuState.instance.selectedWeek = true;
			initializePlayState();
			LoadingState.loadAndSwitchState(new PlayState(), true);
		};

		
		bg.onJustHovered = function() {
			bg.normal.alpha = 0.001;
			bg.outline.alpha = 1;
		};
		
		bg.onJustUnhover = function() {
			bg.normal.alpha = 1;
			bg.outline.alpha = 0.001;
		};
		
		bg.onClick = function() {
			if(StoryMenuState.instance.selectedWeek) return;
			
			endTheElevatorSequence(finishElevatorSequence);
			StoryMenuState.instance.selectedWeek = true;
		};
	}
	
	private function initializePlayState():Void {
		StoryMenuState.instance.curDifficulty = [for (x in CoolUtil.defaultDifficulties) x.toLowerCase()].indexOf(DoorsUtil.curRun.runDiff.toLowerCase());

        CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
        PlayState.isStoryMode = true;
		
        PlayState.storyDifficulty = StoryMenuState.instance.curDifficulty;
		PlayState.targetDoor = 0;
        PlayState.storyPlaylist = ["starting-point"];

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
	}
	
	private function finishElevatorSequence():Void {
		DoorsUtil.curRun.curDoor = 0;
		StoryMenuState.door = 0;
		
		StoryMenuState.instance.saveData();
		
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		PlayState.isStoryMode = true;
		
		StoryMenuState.instance.changeState(function() {
			StoryMenuState.instance.canUseShowStats = true;
			MusicBeatState.switchState(new StoryMenuState());
		});
	}
}