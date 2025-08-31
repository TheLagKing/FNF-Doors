package states;

import backend.metadata.StoryModeMetadata.RunRanking;
import backend.metadata.DeathMetadata;
import objects.items.Item;
import backend.storymode.InventoryManager;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import states.storyrooms.shop.ShopState;
import states.storyrooms.shop.GlitchedShopState;
import shaders.GlitchPosterize;
import flixel.input.mouse.FlxMouse;
import shaders.FilmGrain;
import flixel.effects.FlxFlicker;
import shaders.StaticShader;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import shaders.VignetteShader;
import openfl.filters.BitmapFilter;
import shaders.HaltChromaticAberration;
import shaders.SoftLight;
import shaders.RGBGlitchShader;
import openfl.filters.ShaderFilter;
import openfl.display.BitmapData;
import openfl.Assets;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
#if desktop
import Discord.DiscordClient;
#end
import Date;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.text.FlxTextNew as FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;
import ClientPrefs;
import SoundCompare;
import DoorsUtil;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var instance:StoryMenuState;

	public var camFollowPos:FlxObject;
	public var camFollowPosWalkingYOffset:Float = 0;
	var camFollow:FlxPoint;

	public var curDifficulty:Int = 1;

	public static var door:Int = 0;
	public static var excludedSongList:Array<String> = [];
	public var iLikeMen:Float = 0;

	var foundSong:Bool = false;
	var foundItem:Bool = false;

	public var bossState:String = 'None';
	var stopspamming = false;

	var multipleSongsChosen = false;

	var itemDescription:FlxText;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var descBox:AttachedSprite;
	var descText:FlxText;

	public static var particleEmitter:FlxTypedEmitter<FlxParticle>;

	public var freezeItem:Bool = false;
	public var room:StoryRoom;

	private var healthBarBG:AttachedSprite;
	private var healthBarBGlit:AttachedSprite;
	public var healthBar:ColorBar;

	var progressButton:StoryModeSpriteHoverable;

	public var clickableThings:Array<StoryModeSpriteHoverable> = [];
	var loading:Bool = true;

	public var isDark:Bool = false;
	public var bigDarkness:FlxSprite;
	public var guidedLightDoor:FlxSprite;
	public var guidedLight:FlxSprite;
	public var guidedParticles:FlxEmitter;

	public var moneyIndicator:MoneyIndicator;
	public var knobIndicator:MoneyIndicator;

	public var iconP1:HealthIcon;
	
	public var activeEntities:Map<String, BaseSMMechanic> = [];

	//shaders 
	var glitchItemShader:RGBGlitchShader;
	public var vignetteShader:VignetteShader;
	var filmGrain:FilmGrain;

	public var hasTransitionShader:Bool = false;

	var camGameShaders:Array<Dynamic> = [];
	var camHUDShaders:Array<Dynamic> = [];

	var camGameFilters:Array<BitmapFilter> = [];
	var camHUDFilters:Array<BitmapFilter> = [];

	public var shaderUpdates:Array<Float->Void> = [];

	//lighting items
	private var lighterCounter:Int = 0;

	//item vars
	public var itemInventory:ItemInventory;

	public var furniture:Array<Furniture> = [];
	public var doors:Array<DoorAttributes> = [];
	public static var selectedDoor:String;

	public var initialCameraPosition:FlxPoint;

	public var closetForeground:FlxSprite;
	public var closetBackground:FlxSprite;
	public var roomObject:Null<BaseSMRoom>;

	public var overrideDarkCreation:Bool = false;
	override function create()
	{
		Paths.clearStoredMemory(true);

		camGameFilters = [];
		camGameShaders = [];
		instance = this;
		DoorsUtil.loadStoryData();
		DoorsUtil.loadRunData();

		DoorsUtil.reloadMaxHealth();

		Paths.image('flashlight');
		Paths.image('lighter');
		Paths.image('lighterGlow');

		particleEmitter = new FlxTypedEmitter(0, 0);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		camFollowPos = new FlxObject(0, 0, 1, 1);

		camFollow = new FlxPoint(200, 200);

		camGame.follow(camFollowPos, LOCKON, 0.95);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		freezeItem = false;
		foundItem = false;
		foundSong = false;

		door = DoorsUtil.curRun.curDoor;
		room = DoorsUtil.curRun.currentRoom;
		if(room == null) {
			room = DoorsUtil.curRun.rooms[DoorsUtil.curRun.rooms.length-1];
		}
		bossState = room.room.bossType;

		FlxG.watch.add(this, "room");
		FlxG.watch.add(this, "furniture", "furniture");

		isDark = room.room.isDark;
		musicThing();
		stopspamming = false;

		//GameOverSubstate.precacheDeath();

		if (door > 99) {
			changeState(function(){
				MusicBeatState.switchState(new RunResultsState(F1_WIN));
			});
		}

		curDifficulty = [for (x in CoolUtil.defaultDifficulties) x.toLowerCase()].indexOf(DoorsUtil.curRun.runDiff.toLowerCase());
		#if debug
		trace('DEBUG DefaultDiffs : ${CoolUtil.defaultDifficulties}');
		trace('DEBUG RunDiff : ${DoorsUtil.curRun.runDiff}');
		trace('DEBUG CurDiff : ${curDifficulty}');
		trace('DEBUG Knob Modifier : ${DoorsUtil.curRun.runKnobModifier}');
		#end


		PlayState.isStoryMode = true;
		persistentUpdate = false;
		persistentDraw = true;

		FlxG.camera.zoom = 0.75;
		initialCameraPosition = new FlxPoint(960, 540);
		camFollowPos.setPosition(initialCameraPosition.x, initialCameraPosition.y);
		overrideCamFollow = false;

		if(ClientPrefs.data.shaders){
			vignetteShader = new VignetteShader();
			vignetteShader.darkness = 15.0;
			vignetteShader.extent = 0.25;
			addUniqueShaderToCam("camGame", vignetteShader, 1);

			glitchItemShader = new RGBGlitchShader(0.5);
			add(glitchItemShader);

			if(ClientPrefs.data.filmGrain){
				filmGrain = new FilmGrain();
				addUniqueShaderToCam("camGame", filmGrain, 20);
			}
		}

		roomObject = null;
		switch (bossState){
			case 'pre-run': roomObject = new states.storyrooms.roomTypes.PreElevator();
			case 'lobby': roomObject = new states.storyrooms.roomTypes.Lobby();
			case "None": 
				switch(room.room.roomType){
					case "Hallway": roomObject = new states.storyrooms.roomTypes.Hallway();
					case "Normal": roomObject = new states.storyrooms.roomTypes.Normal(false);
					case "Long": roomObject = new states.storyrooms.roomTypes.Normal(true);
					case "Greenhouse": roomObject = new states.storyrooms.roomTypes.Greenhouse();
					default: roomObject = new states.storyrooms.roomTypes.Normal(false);
				}
			case "puzzle-paintings": roomObject = new states.storyrooms.roomTypes.PuzzlePainting();
			case "seek1" | "seek2": roomObject = new states.storyrooms.roomTypes.Seek();
			case "figure1" | "figure2": roomObject = new states.storyrooms.roomTypes.Figure();
			case "shop" | "jeff": MusicBeatState.switchState(new ShopState());
			case "glitched": MusicBeatState.switchState(new GlitchedShopState());
			case "courtyard": roomObject = new states.storyrooms.roomTypes.Courtyard();
			case "Greenhouse": roomObject = new states.storyrooms.roomTypes.Greenhouse();
		}

		if(isDark){
			roomsFunc(function(room:BaseSMRoom) {
				room.darkCreate();
			});

			if(!overrideDarkCreation) {
				bigDarkness = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF010101);
				add(bigDarkness);
				bigDarkness.screenCenter();
	
				if(roomObject != null){
					var randomDoorSide:String;
					var allDoorSides:Array<String> = [];
					for(door in doors){
						allDoorSides.push(door.side);
					}
	
					randomDoorSide = FlxG.random.getObject(allDoorSides);
					for(door in doors){
						if(randomDoorSide != door.side) {
							door.isDarkBlocked = true;
						}
					}
	
					for(fur in furniture){
						fur.isDarkBlocked = true;
					}
	
					var spr:Dynamic = roomObject.getDarkDoor(randomDoorSide);
					if(!Std.isOfType(spr, Bool)){
						guidedLightDoor = spr[0];
						guidedLightDoor.alpha = 0;
						FlxTween.tween(guidedLightDoor, {alpha: 1}, FlxG.random.float(4.0, 5.0), {ease: FlxEase.circOut});
						
						guidedLight = new FlxSprite(
							spr[1].x - 500, 
							spr[1].y - 350
						).loadGraphic(Paths.image("guidingLight"));
						guidedLight.alpha = 0;
						guidedLight.antialiasing = ClientPrefs.globalAntialiasing;
						
						FlxTween.tween(guidedLight, {alpha: 0.6}, FlxG.random.float(4.0, 5.0), {ease: FlxEase.circOut, onComplete: function(twn){
							FlxTween.tween(guidedLight, {alpha: 0.4}, 2.0, {ease: FlxEase.quadInOut, type: PINGPONG});
						}});
						add(guidedLightDoor);
						add(guidedLight);
					}
				}
			}
	
			roomsFunc(function(room:BaseSMRoom) {
				room.darkCreatePost();
			});
		}

		itemInventory = new ItemInventory(HORIZONTAL, this);
		itemInventory.cameras = [camHUD];
		add(itemInventory);
		if(itemInventory.items.members.length > 0) iLikeMen = itemInventory.items.members[0].y - 20;

		itemDescription = new FlxText(300, 0, 0, "", 32);
		itemDescription.text = "";
		itemDescription.setFormat(FONT, 32, FlxColor.WHITE, RIGHT);
		itemDescription.antialiasing = ClientPrefs.globalAntialiasing;
		itemDescription.alpha = 1;
		itemDescription.visible = false;
		itemDescription.cameras = [camHUD];

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.4;
		descBox.alpha = 0.4;
		descBox.cameras = [camHUD];
		add(descBox);

		descText = new FlxText(50, FlxG.height - 220, 1180, "", 32);
		descText.setFormat(FONT, 32, FlxColor.WHITE, CENTER);
		descText.antialiasing = ClientPrefs.globalAntialiasing;
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		descText.cameras = [camHUD];
		add(descText);

		healthBarBG = new AttachedSprite('healthBars/healthBar');
		healthBarBG.y = FlxG.height * 0.15;
		healthBarBG.screenCenter(X);
		healthBarBG.cameras = [camHUD];

		healthBar = new ColorBar(healthBarBG.x, healthBarBG.y - 80, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 30), Std.int(healthBarBG.height), 
		DoorsUtil.curRun, 'latestHealth', 0, DoorsUtil.maxHealth);
		healthBar.createImageEmptyBar(Paths.image('healthBars/healthbarMask'), FlxColor.WHITE) ;
		healthBar.createImageFilledBar(Paths.image('healthBars/healthbarMask'), FlxColor.WHITE) ;
		healthBar.cameras = [camHUD];

		add(healthBar);
		add(healthBarBG);
		
		healthBarBG.sprTracker = healthBar;

		healthBar.backColorTransform.color = FlxColor.fromRGB(255, 0, 0);
		healthBar.frontColorTransform.color = FlxColor.fromRGB(52, 111, 180);

		iconP1 = new HealthIcon("bf", false);
		iconP1.y = healthBar.y - 40;
		iconP1.x = healthBar.x + (healthBar.width * (DoorsUtil.curRun.latestHealth/DoorsUtil.maxHealth)) - (150 * iconP1.scale.x) / 2;
		iconP1.cameras = [camHUD];
		add(iconP1);

		healthBar.updateBar();

		progressButton = new StoryModeSpriteHoverable(FlxG.width - 320/2, 0, "notebookIdle");
		Paths.image("notebookHover");
		progressButton.scale.set(0.5, 0.5);
		progressButton.updateHitbox();
		progressButton.cameras = [camHUD];
		progressButton.antialiasing = ClientPrefs.globalAntialiasing;
		add(progressButton);

		add(particleEmitter);

		moneyIndicator = new MoneyIndicator(FlxG.width * 0.05, FlxG.height * 0.80, false);
		moneyIndicator.cameras = [camHUD];
		add(moneyIndicator);

		knobIndicator = new MoneyIndicator(FlxG.width * 0.05, FlxG.height * 0.88, true);
		knobIndicator.cameras = [camHUD];
		add(knobIndicator);

		if (DoorsUtil.curRun.latestHealth/DoorsUtil.maxHealth < 0.2)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		persistentUpdate = false;

		add(itemDescription); //moved it here because it was getting added every update

		super.create();

		if(DoorsUtil.isDead)
		{
			var deathMetadata = new DeathMetadata();
			deathMetadata.causeOfDeath = "PREVIOUS";

			openSubState(new GameOverSubstate(deathMetadata, this));
			return;
		}

		new FlxTimer().start(0.7, function(tmr){
			loading = false;
			ambianceManager(true);
		});

		for(ent in room.entitiesInRoom){
			var canSpawnVoid:Bool = true;
			for(otherEnts in room.entitiesInRoom){
				switch(otherEnts.className){
					case "Ambush" | "Rush": canSpawnVoid = false;
				}
			}
			DoorsUtil.addMechanicEntityToEncountered(ent.className.toLowerCase());
			switch(ent.className){
				case "Dupe": 
					new states.storymechanics.Dupe();
				case "Screech": 
					new states.storymechanics.Screech();
				case "Shadow" if(canSpawnVoid): 
					new states.storymechanics.Shadow();
				case "Void" if(canSpawnVoid): 
					new states.storymechanics.Void();
				case "Ambush": 
					new states.storymechanics.Ambush();
				case "Rush": 
					new states.storymechanics.Rush();
				case "Hide":
					new states.storymechanics.Hide();
			}
		}

		//PRELOADING ALL THE SOUNDS
		Paths.sound('scrollMenu');
		Paths.sound('cancelMenu');
		Paths.sound('DrawerOpen');
		Paths.sound('doorslam');

		if(hasTransitionShader)
			Paths.sound('bossEnter');

		if(isDark)
		{
			Paths.sound('AmbienceDark');
			Paths.sound('screech');
			Paths.sound('psst');
		}
		else{
			for(i in 1...23){
				Paths.sound('amb/${i}');
			}
		}
		
		MenuSongManager.changeSongPitch(1, 2.0);

		var funnyText:String = "";
		if(DoorsUtil.curRun.curDoor > 0) funnyText += "Door: " + DoorsUtil.curRun.curDoor;
		else funnyText += "In the Lobby";
		if(DoorsUtil.curRun.runScore > 0) funnyText += " | Score: " + DoorsUtil.curRun.runScore;
		if(DoorsUtil.curRun.runKnobModifier != 1) funnyText += " | Knob Modifier: " + (DoorsUtil.curRun.runKnobModifier-1)*100 + "%";

		#if desktop
		var discordSmallIcon = "";
		var rank = DoorsUtil.calculateRunRank();
		discordSmallIcon = switch(rank) {
			case P: "rank_p";
			case S: "rank_s";
			case A: "rank_a";
			case B: "rank_b";
			case C: "rank_c";
			case D: "rank_d";
			case F: "rank_f";
			default: "rank_a";
		}

		DiscordClient.changePresence("Looking for an exit...", 
		funnyText, 
		"gameicon", discordSmallIcon);
		#end
		
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.createPost();
		});

		roomsFunc(function(room:BaseSMRoom) {
			room.createPost();
		});

		// Achievements 
		if(AwardsManager.isUnlockedID("youWin")) AwardsManager.welcomeBack = true;

		FlxG.console.registerFunction("goToRoom", function(roomInt:Int) {
			door = roomInt;
			saveData();
			freezeItem = true;
			overrideCamFollow = true;
			changeState(function(){
				MusicBeatState.switchState(new StoryMenuState());
			});
		});

		FlxG.console.registerFunction("toggleDark", function() {
			DoorsUtil.curRun.currentRoom.room.isDark = !DoorsUtil.curRun.currentRoom.room.isDark;
			DoorsUtil.curRun.save();
			changeState(function(){
				MusicBeatState.switchState(new StoryMenuState());
			});
		});

		FlxG.console.registerFunction("reloadRoom", function() {
			changeState(function(){
				MusicBeatState.switchState(new StoryMenuState());
			});
		});

		FlxG.console.registerFunction("lookUpRoom", function(lookupCriteria:String, type:String) {
			for(i=>r in DoorsUtil.curRun.rooms){
				var index = i + DoorsUtil.curRun.initialDoor;
				if(index > door){
					switch(lookupCriteria){
						case "type":
							if(r.room == null) continue;
							if(r.room.bossType == type) return 'There is a room with type [${type}] on door [${index}].';
							if(r.room.bossType == "None" && r.room.roomType == type) return 'There is a room with type [${type}] on door [${index}].';
						case "furnitureInRoom":
							if(r.furniture == null) continue;
							for(fur in r.furniture){
								if(fur.name == type) return 'There is a room with furniture [${type}] on door [${index}].';
							}
						case "songInRoom":
							if(r.leftDoor == null || r.rightDoor == null) continue;
							for(fur in r.furniture) {
								if(fur.name.toLowerCase() == "closet" && fur.specificAttributes != null && fur.specificAttributes.jackSong.toLowerCase() == type.toLowerCase()) return 'There is a closet with song [${type}] on door [${index}].';
								if((fur.name.toLowerCase() == "drawer" || fur.name.toLowerCase() == "drawerLong" )&& fur.specificAttributes != null && fur.specificAttributes.timSong.toLowerCase() == type.toLowerCase()) return 'There is a closet with song [${type}] on door [${index}].';
							}
							if(r.rightDoor.song == type) return 'There is a door with song [${type}] on door [${index}] (It\'s on the right).';
							if(r.rightDoor.song == type) return 'There is a door with song [${type}] on door [${index}] (It\'s on the right).';
							if(r.leftDoor.song == type) return 'There is a door with song [${type}] on door [${index}] (It\'s on the left).';
						case "entityInRoom":
							for(entity in r.entitiesInRoom){
								if(entity.className.replace("states.storymechanics.", "").toLowerCase().trim() == type.toLowerCase().trim()) return 'There is a room with entity [${type}] on door [${index}].';
							}
					}
				}
			}
			return "No upcoming room found with criteria.";
		});

		FlxG.console.registerFunction("motherlode", function() {
			add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.80, 500, moneyIndicator, false, false, camHUD));
			add(new MoneyIndicator.MoneyPopup(FlxG.width*0.05, FlxG.height * 0.88, 50, knobIndicator, true, true, camHUD));
			
			saveData();
		});

		FlxG.console.registerFunction("giveItem", function(itemID:String) {
			var itemChosenStr:String = itemID;
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
				StoryMenuState.instance.saveData();
			}
		});

		FlxG.console.registerFunction("goToLoseEndingScreen", function() {
			changeState(function(){
				MusicBeatState.switchState(new RunResultsState(F1_LOSE, RunRanking.P));
			});
		});

		FlxG.console.registerFunction("goToWinEndingScreen", function() {
			changeState(function(){
				MusicBeatState.switchState(new RunResultsState(F1_WIN, RunRanking.P));
			});
		});

		FlxG.console.registerFunction("resetPopups", function(roomInt:Int) {
            FlxG.save.data.seenPopups = "";
            FlxG.save.flush();
		});

		FlxG.console.registerFunction("setHealth", function(fl:Float) {
			DoorsUtil.curRun.latestHealth = fl;
			healthBar.updateBar();
			StoryMenuState.instance.saveData();
		});

		Paths.clearUnusedMemory();
	}

	override function destroy() {
		FlxG.watch.remove(this, "room");
		FlxG.watch.remove(DoorsUtil, "curRun");
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.destroy();
		});
		super.destroy();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
		
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.closeSubState();
		});

		roomsFunc(function(room:BaseSMRoom) {
			room.closeSubState();
		});
	}


	var thisIsSoDumbJustWorkPlease:Bool = false;
	public var lookingIcon:Bool = false;
	var seekVariant:Bool = false;
	var timeHovered:Float = 0;
	public var doUpdate:Bool = true;
	public var inSubState:Bool = false;
	public var entityComing:Bool = false;
	public var canUseShowStats:Bool = true;
	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		ambianceManager();
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 8, 0, 1);
		if(!overrideCamFollow){
			if(camGame.target == null) camGame.target = camFollowPos;
			camFollowPos.setPosition(
				FlxMath.lerp(camFollowPos.x, FlxG.mouse.getPosition().x / 20 + initialCameraPosition.x - 32 + camFollowPosWalkingYOffset, lerpVal), 
				FlxMath.lerp(camFollowPos.y, FlxG.mouse.getPosition().y / 16 + initialCameraPosition.y - 22.5 + camFollowPosWalkingYOffset, lerpVal)
			);
		} else {
			if(camGame.target != null) camGame.target = null;
			camGame.focusOn(FlxPoint.weak(camFollowPos.x, camFollowPos.y + camFollowPosWalkingYOffset));
		}

		healthBar.updateBar();
		iconP1.x = healthBar.x + (healthBar.width * (healthBar.percent * 0.01)) - (150 * iconP1.scale.x) / 2;
		
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		particleEmitter.x = FlxG.mouse.x;
		particleEmitter.y = FlxG.mouse.y;

		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.update(elapsed);
		});

		roomsFunc(function(room:BaseSMRoom) {
			room.update(elapsed);
		});

		if (doUpdate && !inSubState && !movedBack && !selectedWeek && !loading && !entityComing)
		{
			// Handle mouse shit
			if (lookingIcon) theMouse.currentAction = LOOKING;
			else theMouse.currentAction = NONE;
			
			lookingIcon = false;

			progressButton.checkOverlap(camHUD);
			if (progressButton.isHovered && canUseShowStats){
				progressButton.loadGraphic(Paths.image("notebookHover"));
				progressButton.updateHitbox();
				timeHovered += elapsed * 2;
				progressButton.angle = (FlxMath.fastSin(timeHovered) * 57.2957795) / 10;
				lookingIcon = true;
				if (FlxG.mouse.justPressed){
					theMouse.startLongAction(0.5, function(){
						persistentUpdate = false;
						openSubState(new RunStatsSubstate());
					});
				}
			} else {
				timeHovered = 0;
				progressButton.angle = 0;
				progressButton.loadGraphic(Paths.image("notebookIdle"));
				progressButton.updateHitbox();
				
				for(door in doors){
					door.doorSpr.checkOverlap(camGame);
					if(door.doorSpr.isHovered){
						if(FlxG.mouse.justPressed){
							if(door.isDarkBlocked){
								updateDescription(Lang.getText("darkSight", "story/interactions"));
								continue;
							}

							theMouse.startLongAction(0.5, function(){
								selectedWeek = true;
								onDoorClick(door);
							});
						}
					}
				}
				

				if (!freezeItem){
					for(item in itemInventory.items.members){
						item.update(elapsed);
						item.checkOverlap(camHUD);
						if(item.isHovered){
							if(FlxG.mouse.justPressed){
								item.onStoryUse();
								
								entitiesFunc(function(entity:BaseSMMechanic) {
									entity.onItemActivate(item.itemData.itemID);
								});

								roomsFunc(function(room:BaseSMRoom) {
									room.onItemActivate(item.itemData.itemID);
								});
							}
							item.y = FlxMath.lerp(iLikeMen, item.y, CoolUtil.boundTo(1 - (elapsed * 4), 0, 1));
						} else {
							item.y = FlxMath.lerp(iLikeMen + 20, item.y, CoolUtil.boundTo(1 - (elapsed * 4), 0, 1));
						}
					}
				}
				
				for (thing in clickableThings){
					thing.checkOverlap(camGame);
					if(thing.isHovered){
						if(FlxG.mouse.justPressed){
							thing.onClick();
						}
					}
				}

				for(fur in furniture){
					if(fur.sprite != null) {
						fur.sprite.checkOverlap(camGame);
						if(fur.sprite.isHovered){
							if(FlxG.mouse.justPressed){
								if(fur.isDarkBlocked){
									updateDescription(Lang.getText("darkSight", "story/interactions"));
									continue;
								}
							}
						}


						try{
							handleFurniture(fur.sprite, fur.name, fur.side, fur.specificAttributes, elapsed);
						} catch(e){}
					}
				}
			}

			

			if(timeUntilDescDisappears > 0) timeUntilDescDisappears -= elapsed;
			else {
				if(descOnScreen){
					descOnScreen = false;
					FlxTween.cancelTweensOf(descText);
					FlxTween.cancelTweensOf(descBox);

					FlxTween.tween(descText, {alpha: 0}, 1.1, {onComplete: function(twn){
						updateDescription("");
					}});
					FlxTween.tween(descBox, {alpha: 0}, 1.0);
				}
			}
			
			if (controls.BACK && !movedBack && !selectedWeek) {
				MenuSongManager.playSound("cancelMenu",1.0);
				saveData();
				changeState(function(){
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}
		
		for (i in shaderUpdates){
			i(elapsed);
		}

		DoorsUtil.curRun.runSeconds += elapsed;
		if(DoorsUtil.curRun.runSeconds >= 3600) {
			DoorsUtil.curRun.runHours++;
			DoorsUtil.curRun.runSeconds -= 3600;
		}
		super.update(elapsed);

		
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.updatePost(elapsed);
		});

		roomsFunc(function(room:BaseSMRoom) {
			room.updatePost(elapsed);
		});
	}

	private function handleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		roomsFunc(function(room:BaseSMRoom) {
			room.onHandleFurniture(furSprite, furName, side, specificAttributes, elapsed);
		});
	}

	public var stopDeathEarly = false;
	public function fuckingDie(cause:String, ?tip:Null<String> = null, ?onStopDeathEarly:Null<Void->Void>){
		itemInventory.items.forEach(function(itm){
			itm.onStoryDeath();
		});

		if(stopDeathEarly) {
			stopDeathEarly = false;
			if(onStopDeathEarly == null) return;
			else onStopDeathEarly();
		}
		DoorsUtil.isDead = true;
		DoorsUtil.saveStoryData();
		persistentUpdate = false;

		var deathMetadata = new DeathMetadata();
		deathMetadata.causeOfDeath = cause;
		if(tip != null) deathMetadata.deathTipCategory = tip;

		openSubState(new GameOverSubstate(deathMetadata, this));
	}

	public static var canOpenState = true;
	override public function openSubState(subState:FlxSubState):Void {
		if(!canOpenState) return;

		super.openSubState(subState);
		
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.openSubState(subState);
		});
		roomsFunc(function(room:BaseSMRoom) {
			room.openSubState(subState);
		});
	}

	override function beatHit(){
		super.beatHit();
	}

	public var overrideCamFollow:Bool = false;
	var movedBack:Bool = false;
	public var selectedWeek:Bool = false;
	public var canAccessDoor = true;
	function onDoorClick(selectedDoor:DoorAttributes)
	{
		if(!canOpenState) {
			selectedWeek = false;
			return;
		}

		if((selectedDoor.isLocked && bossState == "None") || 
			(selectedDoor.hasBeenOpenedOnce != null && selectedDoor.hasBeenOpenedOnce == 1)){
			updateDescription(Lang.getText("doorClosed", "story/interactions"));
			FlxTween.color(descText, 1.0, 0xFFFF0000, 0xFFFFFFFF, {ease: FlxEase.quartOut});
			selectedWeek = false;
			return;
		}

		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.onDoorOpen(selectedDoor);
		});
		roomsFunc(function(room:BaseSMRoom) {
			room.onDoorOpen(selectedDoor);
		});
		
		if(canAccessDoor){
			var otherDoor = room.rightDoor;
			if(selectedDoor.side == "right") {
				otherDoor = room.leftDoor;
			}
			
			if(!activeEntities.exists("states.storymechanics.Dupe")){
				if(!otherDoor.isLocked && !otherDoor.isDarkBlocked && bossState == "None" && room.room.roomType == "Normal" && selectedDoor.doorNumber > otherDoor.doorNumber){
					AwardsManager.hasOnlyPickedLower = false;
				} else if (!otherDoor.isLocked && !otherDoor.isDarkBlocked  && bossState == "None" && room.room.roomType == "Normal" && selectedDoor.doorNumber < otherDoor.doorNumber){
					AwardsManager.hasOnlyPickedHigher = false;
				} 
			}
	
			AwardsManager.onLeaveDoor();
	
			var leSong:Dynamic = choosingNextDoor(door, selectedDoor);
	
			if (foundSong) {
				freezeItem = true;
				PlayState.storyPlaylist = [leSong];
				if(door == 99 && (PlayState.storyPlaylist.contains("imperceptible") || PlayState.storyPlaylist.contains("hyperacusis"))){
					PlayState.storyPlaylist = [leSong, "depths-below"];
				}
			} else {
				door = selectedDoor.doorNumber;
				saveData();
				freezeItem = true;
				overrideCamFollow = true;
				doDoorTransition(bossState, selectedDoor, function(){
					changeState(function(){
						MusicBeatState.switchState(new StoryMenuState());
					});
				});
				return;
			}
			saveData();
	
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
			PlayState.isStoryMode = true;
	
			PlayState.storyDifficulty = curDifficulty;
			PlayState.targetDoor = selectedDoor.doorNumber;
			var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), curDifficulty);
	
			var songSelectedName = PlayState.storyPlaylist[0].toLowerCase();
			if(Song.checkChartExists(poop, songSelectedName)){
				PlayState.SONG = Song.loadFromJson(poop, songSelectedName);
			}
			else{
				PlayState.SONG = Song.loadFromJson(songSelectedName, songSelectedName);
			}
			if(songSelectedName.toLowerCase() == "halt" || songSelectedName.toLowerCase() == "onward" || songSelectedName == "onward-hell"){
				DoorsUtil.curRun.latestHealth = 1;
			}
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
	
			overrideCamFollow = true;
			doDoorTransition(bossState, selectedDoor, function(){
				changeState(function(){
					LoadingState.loadAndSwitchState(new PlayState(), true);
				});
			});
			roomsFunc(function(room:BaseSMRoom) {
				room.onDoorOpenPost(selectedDoor);
			});
		}
	}

	private function doDoorTransition(boss:String, selectedDoor:DoorAttributes, callBack:Void->Void){
		var zoomInValue:Float = 1.3;
		var zoomInDuration:Float = 1.8;
		var fadeOutDuration:Float = 1.6;
		var leanInDuration:Float = 1.4;
		var switchStateTimer:Float = 1.4;
		var hasBossEnter:Bool = false;
		var bossEnterVolume:Float = 1.0;
		var walkingString:String = "walking leaving";
		var walkingVolume:Float = 1.0;
		var doorslamString:String = "doorslam";
		var doorslamVolume:Float = 0.7;
		var doorslamDelay:Float = 1.4;
		switch(boss){
			case "lobby":
				hasBossEnter = false;
				bossEnterVolume = 1.0;
				walkingString = "walking leaving";
				walkingVolume = 0.7;
				doorslamDelay = 1.4;
				fadeOutDuration = 1.4;
				zoomInValue = 1.3;
				zoomInDuration = 1.8;
				switchStateTimer = 29.4;
			case "seek1" | "seek2":
				hasBossEnter = true;
				bossEnterVolume = 0.8;
				walkingString = "walking boss";
				walkingVolume = 0.7;
				doorslamDelay = 5.55;
				fadeOutDuration = 5.55;
				zoomInValue = 1.5;
				zoomInDuration = 5.55;
				switchStateTimer = 5.55;
			case "figure1" :
				hasBossEnter = true;
				bossEnterVolume = 0;
				walkingString = "walking boss";
				walkingVolume = 0.7;
				doorslamDelay = 5.55;
				fadeOutDuration = 5.55;
				zoomInValue = 1.5;
				zoomInDuration = 5.55;
				switchStateTimer = 14.55;
			case "figure2":
				hasBossEnter = true;
				bossEnterVolume = 0;
				walkingString = "walking boss";
				walkingVolume = 0.7;
				doorslamDelay = 5.55;
				fadeOutDuration = 5.55;
				zoomInValue = 1.5;
				zoomInDuration = 5.55;
				switchStateTimer = 5.55;
			case "courtyard":
				walkingString = "walking boss";
				walkingVolume = 0.7;
				zoomInValue = 1.6;
				zoomInDuration = 5.55;
				fadeOutDuration = 5.55;
				doorslamDelay = 5.55;
				doorslamString = "CourtyardDoor";
				switchStateTimer = 5.55;
		}

		// 280ms per steps - leaving
		// 920ms per steps - boss

		overrideCamFollow = true;
		if(hasBossEnter) MenuSongManager.playSound("bossEnter", bossEnterVolume);
		MenuSongManager.playSound(doorslamString, doorslamVolume, doorslamDelay);
		MenuSongManager.playSound(walkingString, walkingVolume);
		FlxTween.tween(camFollowPos, {
			x: selectedDoor.doorSpr.getGraphicMidpoint().x, 
			y: selectedDoor.doorSpr.getGraphicMidpoint().y
		}, leanInDuration, {ease: FlxEase.linear});
		switch(walkingString){
			case "walking boss":
				FlxTween.tween(this, {camFollowPosWalkingYOffset: -2}, 0.80, {ease: FlxEase.cubeOut, onComplete:function(twn){
					FlxTween.tween(this, {camFollowPosWalkingYOffset: 2}, 0.16, {ease: FlxEase.backOut, type: LOOPING, loopDelay: 0.80});
				}, type: LOOPING, loopDelay: 0.16});
				FlxTween.tween(camGame, {angle: 0}, 0.8, {ease: FlxEase.cubeOut, onComplete:function(twn){
					FlxTween.tween(camGame, {angle: 0.1}, 0.16, {ease: FlxEase.backOut, onComplete:function(twn2){
						FlxTween.tween(camGame, {angle: 0}, 0.8, {ease: FlxEase.cubeOut, onComplete:function(twn3){
							FlxTween.tween(camGame, {angle: -0.1}, 0.16, {ease: FlxEase.backOut, type: LOOPING, loopDelay: 0.48});
						}, type: LOOPING, loopDelay: 0.48});
					}, type: LOOPING, loopDelay: 0.48});
				}, type: LOOPING, loopDelay: 0.48});
			case "walking leaving":
				FlxTween.tween(this, {camFollowPosWalkingYOffset: -2}, 0.16, {ease: FlxEase.cubeOut, onComplete:function(twn){
					FlxTween.tween(this, {camFollowPosWalkingYOffset: 2}, 0.16, {ease: FlxEase.backOut, type: LOOPING, loopDelay: 0.16});
				}, type: LOOPING, loopDelay: 0.16});
				FlxTween.tween(camGame, {angle: 0}, 0.16, {ease: FlxEase.cubeOut, onComplete:function(twn){
					FlxTween.tween(camGame, {angle: 0.1}, 0.16, {ease: FlxEase.backOut, onComplete:function(twn2){
						FlxTween.tween(camGame, {angle: 0}, 0.16, {ease: FlxEase.cubeOut, onComplete:function(twn3){
							FlxTween.tween(camGame, {angle: -0.1}, 0.16, {ease: FlxEase.backOut, type: LOOPING, loopDelay: 0.48});
						}, type: LOOPING, loopDelay: 0.48});
					}, type: LOOPING, loopDelay: 0.48});
				}, type: LOOPING, loopDelay: 0.48});
		}
		FlxTween.tween(camGame, {zoom: zoomInValue}, zoomInDuration, {ease: FlxEase.linear});
		camGame.fade(FlxColor.BLACK, fadeOutDuration, false);
		new FlxTimer().start(switchStateTimer, function(tmr:FlxTimer){
			callBack();
		});
	}

	function choosingNextDoor(door:Int, selectedDoor:Dynamic):Dynamic
	{
		foundSong = true;
		var song:String = selectedDoor.song;
		if(song != "None"){
			song = DoorsUtil.curRun.getReplacementSong(selectedDoor.song, door);
			if(song != "None") return song;
		} 
		foundSong = false;

		return "fuck off";
	}

	var descOnScreen:Bool = false;
	var timeUntilDescDisappears:Float = 0.0;
	public function updateDescription(text:String){
		FlxTween.cancelTweensOf(descText);
		FlxTween.cancelTweensOf(descBox);
		descText.text = text;
		if(text != ""){
			descText.alpha = 1;
			descOnScreen = true;
			timeUntilDescDisappears = text.split(" ").length / 2.5;
		} else {
			descText.alpha = 0;
		}
		
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	public function saveData(){
		DoorsUtil.curRun.curDoor = door;
		DoorsUtil.saveStoryData();
	}

	public static function resetData(){
		DoorsUtil.resetRun();
		DoorsUtil.loadStoryData();
		DoorsUtil.loadRunData();
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	var canSpawnAmbiance = false;
	var waitingLmao:Bool = false;

	var soundSelector = FlxG.random.int(1, 22);
	var randomAmbianceTimer = new FlxTimer();

	private function ambianceManager(?justEntered:Bool = false){
		roomsFunc(function(room:BaseSMRoom) {
			room.onAmbiance(justEntered);
		});
		var selectedAudioAmbiance = Std.string(soundSelector);

		if(!waitingLmao){
			if(FlxG.random.bool(15) && canSpawnAmbiance){
				canSpawnAmbiance = false;
				MenuSongManager.playSound("amb/" + selectedAudioAmbiance, 0.4);
				soundSelector = FlxG.random.int(1, 22);
				selectedAudioAmbiance = Std.string(soundSelector);
			} else {
				canSpawnAmbiance = false;
				waitingLmao = true;
				randomAmbianceTimer.start(FlxG.random.float(4.2, 10.8), function(tmr){
					canSpawnAmbiance = true;
					waitingLmao = false;
				});
			}
		}
	}

	public function checkForSeeingDouble()
	{
		if(entities.length == 2 + (activeEntities.exists("states.storymechanics.Void") ? 1 : 0) + (activeEntities.exists("states.storymechanics.Hide") ? 1 : 0)){
			AwardsManager.seeingDouble = true;
		}
	}

	override function onFocusLost(){
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.onFocusLost();
		});
		roomsFunc(function(room:BaseSMRoom) {
			room.onFocusLost();
		});
		super.onFocusLost();
	}

	override function onFocus(){
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.onFocus();
		});
		roomsFunc(function(room:BaseSMRoom) {
			room.onFocus();
		});
		super.onFocus();
	}

	public function changeState(callback:Void->Void){
		movedBack = true;
		entitiesFunc(function(entity:BaseSMMechanic) {
			entity.changeState();
		});
		roomsFunc(function(room:BaseSMRoom) {
			room.changeState();
		});
		callback();
	}

	public function useLight()
	{
		lighterCounter++;

		AwardsManager.fuckScreech = true;
		if(lighterCounter > 1) AwardsManager.burnTheHotel = true;
	}

	private function updateCameraFilters(camera:String){
		switch(camera){
			case 'camGame':
				camGameFilters = [];
				for(s in camGameShaders){
					if(!Std.isOfType(s, FilmGrain)){
						camGameFilters.push(new ShaderFilter(s.shader));
					} else {
						camGameFilters.push(new ShaderFilter(s));
					}
				}
				camGame.setFilters(camGameFilters);
			case 'camHUD':
				camHUDFilters = [];
				for(s in camHUDShaders){
					if(!Std.isOfType(s, FilmGrain)){
						camHUDFilters.push(new ShaderFilter(s.shader));
					} else {
						camHUDFilters.push(new ShaderFilter(s));
					}
				}
				camHUD.setFilters(camHUDFilters);
		}
	}

	function musicThing()
	{
		if(DoorsUtil.isDead) return;
		if(isDark && (bossState == "None"))
		{
			if(DoorsUtil.isDead) return;
			MenuSongManager.crossfade('DarkAmbience', 0.3, 120, true);
			return;
		}

		if(room.musicData != null){
			MenuSongManager.crossfade(DoorsUtil.handleMusicVariations(room.musicData), 1, room.musicData.bpm, true);

			return;
		}

		switch(bossState)
		{
			case 'pre-run': MenuSongManager.crossfade('storyModePre', 1, 120, true);
			case 'lobby': MenuSongManager.crossfade('storyModeIntro', 1, 93, true);
			case "None": MenuSongManager.crossfade('storyModeBGM', 1, 93, true);
			case "puzzle-paintings": MenuSongManager.crossfade('storyModePaintings', 1, 100, true);
			case "seek1" | "seek2": MenuSongManager.crossfade('storyModeBoss', 1, 120, true);
			case "figure1" | "figure2": MenuSongManager.crossfade('storyModeBoss', 1, 120, true);
			case "courtyard": MenuSongManager.crossfade('courtyard', 1, 110, true);
			case "greenhouse": MenuSongManager.crossfade('greenhouse', 1, 80, true);
		}
		if(bossState == "None"){
			switch(room.room.roomType){
				case "Greenhouse": MenuSongManager.crossfade('greenhouse', 1, 80, true);
			}
		}
	}

	public function addUniqueShaderToCam(camera:String, shader:Dynamic, layer:Int){
		switch(camera){
			case 'camGame':
				if(!camGameShaders.contains(shader)){
					camGameShaders.insert(layer, shader);
					updateCameraFilters("camGame");
				}
			case 'camHUD':
				if(!camHUDShaders.contains(shader)){
					camHUDShaders.insert(layer, shader);
					updateCameraFilters("camHUD");
				}
		}
	}

	public function removeUniqueShaderFromCam(camera:String, shader:Dynamic){
		switch(camera){
			case 'camGame':
				if(camGameShaders.contains(shader)){
					camGameShaders.remove(shader);
					updateCameraFilters("camGame");
				}
			case 'camHUD':
				if(camHUDShaders.contains(shader)){
					camHUDShaders.remove(shader);
					updateCameraFilters("camHUD");
				}
		}
	}
}