package states;

import flixel.ui.FlxBar;
import flixel.math.FlxRandom;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var canLeave:Bool = false;
	var startedLoading:Bool = false;
	var numberOfLoaded:Int = 0;
	var assetMap:Map<String, Array<String>> = [];
	var finishedImages:Bool = false;
	var finishedSounds:Bool = false;
	var finishedMusics:Bool = false;
	var finishedInstOgg:Bool = false;
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var targetShit:Float = 0;

	var lilGuy:FlxSprite;

	var keysArray:Array<Dynamic> = [];
	var controlArray:Array<String> = [];
	var randomTips:Array<{title:String, text:String}> = [
		{title: "lby", text: "lby"},
		{title: "warn", text: "healthZero"},
		{title: "dyk", text: "fig"},
		{title: "dyk", text: "shart"},
		{title: "dyk", text: "balls"},
		{title: "dyk", text: "skibidi"},
		{title: "dyk", text: "locker"},
		{title: "dyk", text: "no"},
		{title: "dyu", text: "didu"},
		{title: "dyk", text: "dark"},
		{title: "dyk", text: "bf"},
		{title: "ff", text: "ah"},
		{title: "dyk", text: "gun"},
		{title: "dyk", text: "maid"},
		{title: "dyk", text: "burned"},
		{title: "dyk", text: "the"},
		{title: "dyk", text: "shit"},
		{title: "dyk", text: "dik"},
		{title: "ff", text: "hymn"},
		{title: "ff", text: "none"},
		{title: "dyk", text: "mitosis"},
		{title: "ff", text: "insane"},
		{title: "ff", text: "behind"},
		{title: "dyk", text: "nini"},
		{title: "kyd", text: "ido"},
		{title: "dyk", text: "yosibu"},
		{title: "dyk", text: "yesterday"},
		{title: "dyk", text: "vaporeon"},
		{title: "dyk", text: "reset"},
		{title: "dyk", text: "fatrush"},
		{title: "dyk", text: "procrastinating"},
		{title: "pt", text: "eyes"},
		{title: "pt", text: "halt"},
		{title: "pt", text: "heartbeat"},
		{title: "pt", text: "run"},
		{title: "pt", text: "idle"},
		{title: "pt", text: "crashout"},
		{title: "pt", text: "findTim"},
		{title: "pt", text: "findJack"},
		{title: "pt", text: "searchDrawers"},
		{title: "dyk", text: "stareRemake"},
		{title: "dyk", text: "rushscreechcommon"},
		{title: "dyk", text: "f1update"},
		{title: "dyk", text: "demo2release"}
	];

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var loadBar:FlxBar;
	var maxLength:Int = 0;
	override function create()
	{
		switch(Type.getClassName(Type.getClass(target)).split(".").pop()){
			case "PlayState":
				assetMap = PlayState.preloadEverything();
			case "CreditsState":
				assetMap = CreditsState.preloadEverything();
		}

		maxLength = assetMap.get("images").length + assetMap.get("sounds").length + assetMap.get("music").length + assetMap.get("instogg").length;

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];
	
		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		lilGuy = new FlxSprite(FlxG.width * 0.02, FlxG.height * 0.8);
		lilGuy.frames = Paths.getSparrowAtlas('characters/lilSeek', "shared");
		lilGuy.animation.addByPrefix('idle', 'Idle', 12, true, false, false);
		lilGuy.animation.addByPrefix('NOTE_LEFT', 'Left', 12, false, false, false);
		lilGuy.animation.addByPrefix('NOTE_DOWN', 'Down', 12, false, false, false);
		lilGuy.animation.addByPrefix('NOTE_UP', 'Up', 12, false, false, false);
		lilGuy.animation.addByPrefix('NOTE_RIGHT', 'Right', 12, false, false, false);
		lilGuy.animation.play("idle", true, false);

		loadBar = new FlxBar(0, FlxG.height-10, LEFT_TO_RIGHT, FlxG.width, 10, this,
			'targetShit', 0, 1);
		loadBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		add(loadBar);

		var fuckFact:FlxText = new FlxText(FlxG.width * 0.02, FlxG.height * 0.5, FlxG.width * 0.98, "", 32);
		fuckFact.setFormat(FONT, 64, 0xFFFFC100);
		fuckFact.antialiasing = ClientPrefs.globalAntialiasing;

		var randomFuckFact:FlxText = new FlxText(FlxG.width * 0.02, FlxG.height * 0.6, FlxG.width * 0.98, "");
		randomFuckFact.setFormat(FONT, 32, 0xFFFFFFFF);
		randomFuckFact.antialiasing = ClientPrefs.globalAntialiasing;

		add(lilGuy);
		add(fuckFact);
		add(randomFuckFact);
		add(loadBar);

		var randomObject = new FlxRandom().getObject(randomTips);

		randomFuckFact.text = Lang.getText(randomObject.text, "loadingTips/text", "value");
		fuckFact.text = Lang.getText(randomObject.title, "loadingTips/title", "value");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);

		canLeave = false;
	}
	
	private function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		lilGuy.animation.play(controlArray[key], true, false);
	}
		
	private function getKeyFromEvent(key:FlxKey):Int {
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}
	
	var curLoadedIndex:Int = 0;
	override function update(elapsed:Float)
	{
		if(!canLeave){
			if(!finishedImages){
				if(assetMap.get("images").length > 0) {
					Paths.image(assetMap.get("images")[curLoadedIndex]);
					curLoadedIndex++;
					numberOfLoaded++;
					if(curLoadedIndex == assetMap.get("images").length){
						finishedImages = true;
						curLoadedIndex = 0;
					}
				} else {
					finishedImages = true;
					curLoadedIndex = 0;
				}
			}
			else if(!finishedSounds){
				if(assetMap.get("sounds").length > 0) {
					Paths.sound(assetMap.get("sounds")[curLoadedIndex]);
					curLoadedIndex++;
					numberOfLoaded++;
					if(curLoadedIndex == assetMap.get("sounds").length){
						finishedSounds = true;
						curLoadedIndex = 0;
					}
				} else {
					finishedSounds = true;
					curLoadedIndex = 0;
				}
			}
			else if(!finishedMusics){
				if(assetMap.get("music").length > 0) {
					Paths.music(assetMap.get("music")[curLoadedIndex]);
					curLoadedIndex++;
					numberOfLoaded++;
					if(curLoadedIndex == assetMap.get("music").length){
						finishedMusics = true;
						curLoadedIndex = 0;
					}
				} else {
					finishedMusics = true;
					curLoadedIndex = 0;
				}
			}
			else if(!finishedInstOgg){
				if(assetMap.get("instogg").length > 0) {
					Paths.inst(assetMap.get("instogg")[0]);
					Paths.voices(assetMap.get("instogg")[0]);
					numberOfLoaded++;
					finishedInstOgg = true;
				} else {
					finishedInstOgg = true;
					curLoadedIndex = 0;
				}
			} else {
				canLeave = true;
				onLoad();
			}
		}
		targetShit = numberOfLoaded / maxLength;
		var otherTargetShit = FlxMath.remapToRange(numberOfLoaded / maxLength, 0, 1, 1, 0);
		MenuSongManager.changeSongVolume(Math.max(0, otherTargetShit - 0.2), 0.1);

		//don't know if this one is good i'll just leave it here
		/*var lilGuyWantedX:Float = loadBar.percent/100 * FlxG.width - lilGuy.width/2;
		lilGuy.x = Math.max(FlxG.width * 0.02, Math.min((FlxG.width * 0.98) - lilGuy.width, lilGuyWantedX));*/
		
		super.update(elapsed);
	}
	
	function onLoad()
	{
		if(!canLeave) return;
		
		MenuSongManager.curMusic = "";
		MusicBeatState.switchState(target);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);
		
		return new LoadingState(target, stopMusic, directory);
	}
	
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	
	override function destroy()
	{
		super.destroy();
		
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
	}
}