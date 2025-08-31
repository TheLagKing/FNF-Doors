package;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:structInit class SaveVariables {
	public var saveVersion:String = "F1NewTranslations";

	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var controllerMode:Bool = false;

	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var autoPause:Bool = true;
	public var antialiasing:Bool = true;

	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; //From Stilic
	public var framerate:Int = 60;

	public var camZooms:Bool = true;
	public var camAngle:Bool = true;
	public var camFollow:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var noteSplashes:Bool = true;
	public var ghostTapping:Bool = true;
	public var timeBarType:String = 'timeleft';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var hitsoundVolume:Float = 0;
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;
	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var perfectWindow:Int = 20;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
	public var guitarHeroSustains:Bool = true;
	public var discordRPC:Bool = true;
	public var chachaSlide:Bool = true;
	public var language:String = "en";
	public var displayLanguage:String = "English";
	public var colorblindMode:String = "none";
	public var filmGrain:Bool = true;
	public var iconsOnHB:Bool = false;

	public var strumlineBackgroundOpacity:Float = 0.0;

	//yosibu wanted this
	public var splashAlpha:Float = 0.6;
}

class ClientPrefs {
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	public static var globalAntialiasing(get, default):Bool;
	public static function get_globalAntialiasing(){return ClientPrefs.data.antialiasing;}

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		'heartbeat_left'=> [Q],
		'heartbeat_right'=>[E],

		'item1'         => [ONE],
		'item2'         => [TWO],
		'item3'         => [THREE],
		'item4'         => [FOUR],
		'item5'         => [FIVE],
		'item6'         => [SIX],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'reset'			=> [R],
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		
		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN],
		'debug_2'		=> [EIGHT]
	];

	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up'		=> [DPAD_UP, Y],
		'note_left'		=> [DPAD_LEFT, X],
		'note_down'		=> [DPAD_DOWN, A],
		'note_right'	=> [DPAD_RIGHT, B],
		
		'ui_up'			=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left'		=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down'		=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right'		=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'accept'		=> [A, START],
		'back'			=> [B],
		'pause'			=> [START],
		'reset'			=> [BACK]
	];

	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings() {
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		if(!FlxG.save.flush()) return false;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', 'leetram'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		FlxG.log.add("Settings saved!");
		save.flush();

		return true;
	}

	public static function loadPrefs() {
		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
		
		if(Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		FlxG.autoPause = ClientPrefs.data.autoPause;

		if(FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}

		if(data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', 'leetram');
		if(save != null)
		{
			if(save.data.keyboard != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls) {
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
				}
			}
			if(save.data.gamepad != null) {
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls) {
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
				}
			}
			reloadVolumeKeys();
		}
	}

	public static function transferToNewVersion(){
		if(defaultData.saveVersion == ClientPrefs.data.saveVersion) return true;


		while(defaultData.saveVersion != ClientPrefs.data.saveVersion){
			if(ClientPrefs.data.saveVersion == null){
				FlxG.save.erase();
				ClientPrefs.data = defaultData;
				ClientPrefs.data.saveVersion = "F1v1";
				FlxG.save.flush();
			} else {
				switch(ClientPrefs.data.saveVersion){
					case "F1v1":
						FlxG.save.data.curRun = null;
						DoorsUtil.curRun = new DoorsRun();
						ClientPrefs.data.saveVersion = "F1v2";
						FlxG.save.flush();
					case "F1v2":
						FlxG.save.data.misses = null;
						ClientPrefs.data.saveVersion = "F1Completionist";
						FlxG.save.flush();
					case "F1Completionist":
						FlxG.save.data.curRun = null;
						DoorsUtil.curRun = new DoorsRun();
						ClientPrefs.data.saveVersion = "F1GreenhousePopup";
						FlxG.save.flush();
						break;
					case "F1GreenhousePopup":
						ClientPrefs.data.language = "en";
						ClientPrefs.data.displayLanguage = "English";
						ClientPrefs.data.saveVersion = "F1NewTranslations";
						break;
				}
			}
		}
		return ClientPrefs.saveSettings();
	}
	
	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
		{
			if(controller != true)
			{
				for (key in keyBinds.keys())
				{
					if(defaultKeys.exists(key))
						keyBinds.set(key, defaultKeys.get(key).copy());
				}
			}
			if(controller != false)
			{
				for (button in gamepadBinds.keys())
				{
					if(defaultButtons.exists(button))
						gamepadBinds.set(button, defaultButtons.get(button).copy());
				}
			}
		}

	public static function clearInvalidKeys(key:String) {
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
	}

	public static function reloadVolumeKeys() {
		TitleState.muteKeys = keyBinds.get('volume_mute').copy();
		TitleState.volumeDownKeys = keyBinds.get('volume_down').copy();
		TitleState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}

	public static function toggleVolumeKeys(turnOn:Bool) {
		if(turnOn)
		{
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		}
		else
		{
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
		}
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
