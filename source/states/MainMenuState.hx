package states;

import flixel.math.FlxRect;
import states.storyrooms.shop.ShopState;
import states.storyrooms.shop.GlitchedShopState;
import flixel.addons.api.FlxGlasshat;
import options.substates.GameplaySettingsSubState;
import flixel.system.debug.interaction.tools.Transform.GraphicTransformCursorScaleY;
import flixel.math.FlxPoint;
import PopUp;
#if desktop
import Discord.DiscordClient;
#end
import online.Glasshat;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxTextNew as FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import SoundCompare;
import gamejolt.*;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var doorsEngineVersion:String = '1.0.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	var camFollowPos:FlxObject;
	var camFollow:FlxPoint;

	var bg:FlxSprite;
	var settings:StoryModeSpriteHoverable;
	var whiteSettings:StoryModeSpriteHoverable;
	var indicationText:FlxSpriteGroup;
	var lightsClosedBox:FlxSprite;
	var debugKeys:Array<FlxKey>;
	var fullBlack:FlxSprite;

	var trinitySpider:StoryModeSpriteHoverable;

	public var leftSelector:StoryModeSpriteHoverable;
	public var rightSelector:StoryModeSpriteHoverable;

	var interactibles:Array<InteractibleMenuItem> = [];

	private static var initialCameraPosition:FlxPoint;
	private static var currentPanel:Int = 1;

	override function create()
	{
		Paths.clearStoredMemory();
		MenuSongManager.crossfade("freakyMenuLoop", 1, 102, true);
		Paths.setCurrentLevel("preload");
		
		if(!Glasshat.loggedIn) {
			var loginReturn:String = Glasshat.initStuffs();
			if (loginReturn == 'no login found')
			{
				Main.popupManager.addPopup(new MessagePopup(10, "Glasshat Notification", "Not signed into Glasshat. Sign in in the options menu."));
			} 
		}

		#if desktop
		DiscordClient.changePresence("In the Hotel", null, "gameicon");
		#end
		#if debug
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		camFollowPos = new FlxObject(0, 0, 1, 1);

		camFollow = new FlxPoint(200, 200);

		camGame.follow(camFollowPos, LOCKON, 0.95);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		//Add the fucking background my homie
		bg = new FlxSprite(-768, 0).loadGraphic(Paths.image("mainmenu/new/bg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var drawer = new FlxSprite(761, 763).loadGraphic(Paths.image("mainmenu/new/drawer"));
		var musicPlayer = new InteractibleMenuItem(755, 105, "mainmenu/new/music", null, true, "free");
		var trophy = new InteractibleMenuItem(173, 234, "mainmenu/new/trophy", null, true, "ach");
		var shelf = new FlxSprite(90, 19).loadGraphic(Paths.image("mainmenu/new/shelf"));
		var tipJar = new InteractibleMenuItem(2419, 71, "mainmenu/new/tip", FlxRect.get(639, 449, 158, 195), true, "tip");
		var credit = new InteractibleMenuItem(2734, 678, "mainmenu/new/credits", null, true, (Lang.curLang == "en" ? null : "cred"));
		var painting = new InteractibleMenuItem(743, 75, "mainmenu/new/paintings", FlxRect.get(1316, 8, 261, 417), true, "gal", (AwardsManager.isUnlockedID("youWin") || AwardsManager.isUnlockedID("rip")));
		var jeffBack = new FlxSprite(2241, 93).loadGraphic(Paths.image("mainmenu/new/jeff"));
		var jeffAnim = new FlxSprite(2302, 348);
		var elevator = new InteractibleMenuItem(1296, 0, "mainmenu/new/elevator", FlxRect.get(43, 118, 665, 962), true, "sm");

		drawer.antialiasing = ClientPrefs.globalAntialiasing;
		shelf.antialiasing = ClientPrefs.globalAntialiasing;
		jeffBack.antialiasing = ClientPrefs.globalAntialiasing;

		jeffAnim.frames = Paths.getSparrowAtlas("mainmenu/new/AnimJeff");
		jeffAnim.animation.addByPrefix("idle", "jeff", 24, true);
		jeffAnim.animation.play("idle");
		jeffAnim.scale.set(0.409, 0.409);
		jeffAnim.updateHitbox();
		jeffAnim.setPosition(2302, 348);
		jeffAnim.antialiasing = ClientPrefs.globalAntialiasing;

		musicPlayer.isBlocked = trophy.isBlocked = 
		tipJar.isBlocked = credit.isBlocked =
		painting.isBlocked = elevator.isBlocked = function(){
			return leftSelector.isHovered || rightSelector.isHovered || settings.isHovered;
		}
		musicPlayer.onClick = function(){
			MusicBeatState.switchState(new NewFreeplayState());
		}
		trophy.onClick = function(){
			MusicBeatState.switchState(new AchievementsState());
		}
		tipJar.onClick = function(){
			openSubState(new DonationSubState());
		}
		credit.onClick = function(){
			LoadingState.loadAndSwitchState(new CreditsState(), false);
		}
		painting.onClick = function(){
			if(painting.isUnlocked) MusicBeatState.switchState(new GalleryState());
		}
		elevator.onClick = function(){
			DoorsUtil.loadRunData();

			if(DoorsUtil.curRun != null && DoorsUtil.curRun.currentRoom != null){
				if(DoorsUtil.curRun.currentRoom.room.bossType == "shop"){
					switch(DoorsUtil.generateWhichShop()){
						case "glitched":
							MusicBeatState.switchState(new GlitchedShopState());
						case "jeff":
							MusicBeatState.switchState(new ShopState());
					}
					return;
				}
			} 

			if(DoorsUtil.curRun.curDoor == 100){
				MusicBeatState.switchState(new RunResultsState(F1_WIN));
				return;
			}

			MusicBeatState.switchState(new StoryMenuState());
		}

		lightsClosedBox = new FlxSprite(0, 0).makeSolid(Math.ceil(bg.width), Math.ceil(bg.height), 0xFF080808);
		lightsClosedBox.alpha = 0.0001;

		trinitySpider = new StoryModeSpriteHoverable(0, 0, "trinityspider");
		trinitySpider.visible = false;

		settings = new StoryModeSpriteHoverable(FlxG.width * 0.8, 0, "mainmenu/Settings");
		settings.cameras = [camHUD];
		settings.scale.set(0.8, 0.8);
		settings.updateHitbox();
		settings.setPosition(FlxG.width - settings.width);
		whiteSettings = new StoryModeSpriteHoverable(FlxG.width * 0.8, 0, "mainmenu/Settings Outline");
		whiteSettings.cameras = [camHUD];
		whiteSettings.alpha = 0.000001;
		whiteSettings.scale.set(0.8, 0.8);
		whiteSettings.updateHitbox();
		whiteSettings.setPosition(FlxG.width - whiteSettings.width);

		add(shelf);
		add(trophy);
		add(painting);
		add(musicPlayer);
		add(drawer);
		add(jeffBack);
		add(elevator);
		add(credit);
		add(jeffAnim);
		add(tipJar);
		add(trinitySpider);
		add(lightsClosedBox);

		add(settings);
		add(whiteSettings);

		interactibles.push(trophy);
		interactibles.push(tipJar);
		interactibles.push(credit);
		interactibles.push(painting);
		interactibles.push(musicPlayer);
		interactibles.push(elevator);

		FlxG.camera.zoom = 0.7;
		camFollowPos.setPosition(1620, 540);
		camGame.focusOn(camFollowPos.getPosition());
		camGame.snapToTarget();

		var doorsEngine:FlxText = new FlxText(2, FlxG.height - 48, 0, (Lang.getText("engineVersionShit", "generalshit"):String).replace("{0}", doorsEngineVersion), 12);
		doorsEngine.scrollFactor.set();
		doorsEngine.setFormat(FONT, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		doorsEngine.antialiasing = ClientPrefs.globalAntialiasing;
		doorsEngine.cameras = [camHUD];
		add(doorsEngine);

		var gameVersion:FlxText = new FlxText(2, doorsEngine.y + 24, 0, (Lang.getText("gameVersionShit", "generalshit"):String).replace("{0}", VERSION), 12);
		gameVersion.scrollFactor.set();
		gameVersion.setFormat(FONT, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		gameVersion.antialiasing = ClientPrefs.globalAntialiasing;
		gameVersion.cameras = [camHUD];
		add(gameVersion);

		drawAdditionalUI();
		if(initialCameraPosition == null) initialCameraPosition = new FlxPoint(1620, 540);

		changePanel(0);
		super.create();
		Paths.clearUnusedMemory();
		startGaming();

		FlxG.console.registerFunction("getAwardPopup", function() {
			var award = AwardsManager.getAwardFromID("rushFind");
			
			if (award != null && !AwardsManager.isUnlocked(award))
			{
				Main.popupManager.addPopup(new AwardPopup(6, award));
			}
		});

		FlxG.console.registerFunction("clearAchievements", function() {
			for (award in AwardsManager.fullAwards){
				Reflect.setProperty(FlxG.save.data, award.achievementID, null);
			}
			FlxG.save.flush();
		});
	}

	function startGaming() {
		fullBlack = new FlxSprite().makeGraphic(1920, 1080, 0xFF000000);
		fullBlack.alpha = 1;
		fullBlack.cameras = [camHUD];
		fullBlack.screenCenter();
		add(fullBlack);

		camGame.zoom = 0.8;
		FlxTween.tween(fullBlack, {alpha: 0.00001}, 2.0);
		FlxTween.tween(camGame, {zoom: 0.7}, 2.0, {ease: FlxEase.expoOut});
	}

	function stopGaming(chosenInteractible:InteractibleMenuItem){

	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 2, 0, 1);
		camFollowPos.setPosition(
			FlxMath.lerp(
				camFollowPos.x, 
				(FlxG.mouse.getPosition().x - (initialCameraPosition.x-1620)) / 20 + initialCameraPosition.x, 
				lerpVal*2
			), 
			initialCameraPosition.y);

		if (!selectedSomethin)
		{
			whiteSettings.alpha = FlxMath.lerp(whiteSettings.alpha, 0, lerpVal);
			settings.checkOverlap(camHUD);

			leftSelector.checkOverlap(camHUD);
			rightSelector.checkOverlap(camHUD);
	
			if((leftSelector.isHovered && FlxG.mouse.justPressed) || controls.UI_LEFT_P) changePanel(-1);
			else if((rightSelector.isHovered && FlxG.mouse.justPressed) || controls.UI_RIGHT_P) changePanel(1);

			/*if(theSwitch.isHovered){
				if(FlxG.mouse.justPressed){
					if(lightsClosedBox.alpha >= 0.01){
						FlxTween.cancelTweensOf(lightsClosedBox);
						FlxTween.tween(lightsClosedBox, {alpha: 0}, 0.7, {ease: FlxEase.bounceOut, startDelay: 0.0, onStart: function(twn){
							MenuSongManager.playSound("mainmenu/BulbZap", 1.0);
							MenuSongManager.changeSongVolume(1.0, 0.7);
							MenuSongManager.changeSongPitch(1.0, 0.7);
							theSwitch.loadGraphic(Paths.image("mainmenu/Switch"));
						}});
					} else {
						theSwitch.loadGraphic(Paths.image("mainmenu/Switch2"));
						lightsClosedBox.alpha = 0.9;
						FlxTween.cancelTweensOf(lightsClosedBox);
						MenuSongManager.changeSongVolume(0.3, 0.1);
						MenuSongManager.changeSongPitch(0.3, 0.1);
						FlxTween.tween(lightsClosedBox, {alpha: 0}, 0.7, {ease: FlxEase.bounceOut, startDelay: 5.0, onStart: function(twn){
							MenuSongManager.playSound("mainmenu/BulbZap", 1.0);
							MenuSongManager.changeSongVolume(1.0, 0.7);
							MenuSongManager.changeSongPitch(1.0, 0.7);
							theSwitch.loadGraphic(Paths.image("mainmenu/Switch"));
						}});
					}
				}
			}*/

			if(settings.isHovered){
				if(settings.justHovered){
					onHover(settings, "Settings Outline", "states/mainmenu/sett");
				}
				if(FlxG.mouse.justPressed) 
					openSubState(new GameplaySettingsSubState(true));
			} else if (settings.justStoppedHovering) {
				onUnHover(settings, "Settings");
			} 

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			#if debug
			if (FlxG.keys.anyJustPressed(debugKeys)) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			if(FlxG.random.bool((1 / 4096) * (elapsed * 60))){
				FlxTween.cancelTweensOf(trinitySpider);
				trinitySpider.setPosition(951, -91);
				trinitySpider.visible = true;
				FlxTween.linearPath(trinitySpider, [
					FlxPoint.get(1054, 91),
					FlxPoint.get(1027, 418),
					FlxPoint.get(895, 743),
					FlxPoint.get(485, 755),
					FlxPoint.get(592, 1088),
				], 15, true, {ease: FlxEase.sineInOut});
			}
		}

		super.update(elapsed);
	}

	override function beatHit() {
		super.beatHit();

		for(i in interactibles){
			i.onBeatHit(curBeat);
		}
		if(curBeat % 4 == 0) {
			whiteSettings.alpha = 0.2;
		}
	}

	function onHover(spr:Dynamic, path:String, name:String){
		spr.loadGraphic(Paths.image('mainmenu/${path}'));
	}

	function onUnHover(spr:Dynamic, path:String){
		spr.loadGraphic(Paths.image('mainmenu/${path}'));
	}

	function drawAdditionalUI(){
		rightSelector = new StoryModeSpriteHoverable(0, 0, "story_mode_backgrounds/puzzle_painting/rightSelector");
		rightSelector.flipX = false;
		rightSelector.cameras = [camHUD];
		rightSelector.setPosition(1190, 314);

		leftSelector = new StoryModeSpriteHoverable(0, 0, "story_mode_backgrounds/puzzle_painting/rightSelector");
		leftSelector.flipX = true;
		leftSelector.cameras = [camHUD];
		leftSelector.setPosition(31, 314);

		add(rightSelector);
		add(leftSelector);
	}

	function changePanel(change:Int){
		currentPanel += change;
		currentPanel = Math.floor(FlxMath.bound(currentPanel, 0, 2));

		switch(currentPanel){
			case 0: 
				initialCameraPosition.set(820, initialCameraPosition.y);
				rightSelector.visible = true;
				leftSelector.visible = false;
			case 1:	
				initialCameraPosition.set(1520, initialCameraPosition.y);
				rightSelector.visible = true;
				leftSelector.visible = true;
			case 2:	
				initialCameraPosition.set(2300, initialCameraPosition.y);
				rightSelector.visible = false;
				leftSelector.visible = true;
		}
	}
}

class InteractibleMenuItem extends FlxSpriteGroup {
	public var normal:FlxSprite;
	public var outline:FlxSprite;
	public var hitbox:StoryModeSpriteHoverable;
	public var textIndicator:FlxText;
	public var isHovered(get, never):Bool;
	function get_isHovered(){
		return hitbox == null ? false : hitbox.isHovered;
	}

	public var isBlocked:Void->Bool;
	public var isUnlocked:Bool = true;

	public var onClick:Void->Void;
	public var onHover:Void->Void;
	public var onJustUnhover:Void->Void;
	public var onJustHovered:Void->Void;

	public function new(x:Float, y:Float, path:String, ?hitboxRect:FlxRect = null, ?autoFunction:Bool = true, ?name:String = "", ?isUnlocked:Bool = true){
		super(x, y);
		this.isUnlocked = isUnlocked;

		normal = new FlxSprite(0, 0).loadGraphic(Paths.image((isUnlocked ? path : '${path}_locked')));
		normal.antialiasing = ClientPrefs.globalAntialiasing;
		normal.alpha = 1;
		add(normal);

		outline = new FlxSprite(0, 0).loadGraphic(Paths.image('${path}_outline'));
		outline.antialiasing = ClientPrefs.globalAntialiasing;
		outline.alpha = 0.001;
		add(outline);

		if(name != "") {			
			var goUp:Bool = this.y >= FlxG.height/2;
			var textWidth:Float = (hitboxRect == null ? outline.width : hitboxRect.width) + 200;
			var textX:Float = (hitboxRect == null ? 0 : hitboxRect.x) - 100;
			var textY:Float = (hitboxRect == null ? (goUp ? (outline.height/2) : 0) : (goUp ? hitboxRect.y + (hitboxRect.height/2) : hitboxRect.y));
			textIndicator = new FlxText(textX, textY, textWidth, Lang.getText(name, "states/mainmenu"));
			textIndicator.setFormat(FONT, 48, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
			textIndicator.antialiasing = ClientPrefs.globalAntialiasing;
			textIndicator.alpha = 0.00001;
			textIndicator.borderSize = 2;
			add(textIndicator);
		}

		if(hitboxRect == null) hitbox = cast new StoryModeSpriteHoverable(0, 0, path);
		else hitbox = cast new StoryModeSpriteHoverable(hitboxRect.x, hitboxRect.y, "").makeGraphic(Math.floor(hitboxRect.width), Math.floor(hitboxRect.height), 0xFFFF0000);
		hitbox.alpha = 0.001;
		hitbox.antialiasing = ClientPrefs.globalAntialiasing;
		add(hitbox);

		if(autoFunction){
			onClick = function() {}
			onHover = function() {}
			onJustUnhover = function() {
				if(!isUnlocked) return;
				normal.alpha = 1;
				outline.alpha = 0.001;
				if(name != "") {
					var goUp:Bool = this.y >= FlxG.height/2;
					var textY:Float = (hitboxRect == null ? 0 : (goUp ? hitboxRect.y + (hitboxRect.height/2) : hitboxRect.y));
					FlxTween.cancelTweensOf(textIndicator);
					FlxTween.tween(textIndicator, {alpha: 0, y: this.y + textY + (goUp ? (normal.height/2) : 0)}, 0.6, {ease: FlxEase.sineInOut});
				}
			}
			onJustHovered = function() {
				if(!isUnlocked) return;
				normal.alpha = 0.001;
				outline.alpha = 1;
				if(name != "") {
					var goUp:Bool = this.y >= FlxG.height/2;
					var textY:Float = (hitboxRect == null ? 0 : (goUp ? hitboxRect.y + (hitboxRect.height/2) : hitboxRect.y));
					FlxTween.cancelTweensOf(textIndicator);
					FlxTween.tween(textIndicator, {alpha: 1, y: this.y + textY + (goUp ? (normal.height/2)-80 : 80)}, 0.6, {ease: FlxEase.sineInOut});
				}
			}
			isBlocked = function(){return false;}
		}
	}

	override function update(elapsed:Float){
		hitbox.checkOverlap(camera);

		if(isUnlocked) {
			outline.alpha = FlxMath.lerp(
				outline.alpha, 
				isHovered && !isBlocked() ? 1 : 0.001,
				CoolUtil.boundTo(elapsed, 0, 1)
			);
		}

		if(hitbox.isHovered && !isBlocked() && isUnlocked){
			onHover();
			if(hitbox.justHovered){
				onJustHovered();
			}
			if(FlxG.mouse.justPressed && isUnlocked) onClick();
		} else if (hitbox.justStoppedHovering) {
			onJustUnhover();
		} 

		super.update(elapsed);
	}

	public function onBeatHit(curBeat:Int){
		if(curBeat % 4 == 0 && isUnlocked){
			outline.alpha += 0.5;
		}
	}
}