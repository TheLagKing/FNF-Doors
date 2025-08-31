package substates.story;

import objects.ui.DoorsButton.DoorsButtonWeight;
import objects.ui.DoorsButton.DoorsButtonSize;
import objects.ui.*;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import DoorsUtil;

using StringTools;

class RunStatsSubstate extends StoryModeSubState {
	// UI Elements
	private var menuBG:DoorsMenu;
	private var buttons:Map<String, DoorsButton>;
	private var statText:FlxText;
	
	// State
	private var doUpdate:Bool = true;
	private var buttonHovered:Bool = false;

	public function new() {
		super();
		initializeCamera();
		createUI();
		startGaming();
	}

	private function initializeCamera():Void {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	private function createUI():Void {
		createMenu();
		createButtons();
		createStatText();
		addUIElements();
	}

	private function createMenu():Void {
		menuBG = new DoorsMenu(300, 40, "run-stats", Lang.getText("stats", "newUI"));
		menuBG.closeFunction = stopGaming;
		menuBG.whileHoveringClose = () -> buttonHovered = true;
	}

	private function createButtons():Void {
		buttons = new Map<String, DoorsButton>();

		buttons.set("quit", createButton(318, 598, "quit", "newUI", MEDIUM, NORMAL, exitStoryMode));
		buttons.set("modifiers", createButton(487, 598, "showMod", "newUI", LARGE, NORMAL, showModifiers));
		buttons.set("reset", createButton(812, 598, "reset", "newUI", MEDIUM, DANGEROUS, resetGame));
	}

	private function createButton(x:Float, y:Float, langKey:String, langSection:String, 
								size:DoorsButtonSize, type:DoorsButtonWeight, callback:Void->Void):DoorsButton {
		var button = new DoorsButton(x, y, Lang.getText(langKey, langSection), size, type);
		button.whileHovered = () -> buttonHovered = true;
		button.whenClicked = callback;
		return button;
	}

	private function createStatText():Void {
		statText = new FlxText(318, 133, 644, "", 32);
		statText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT);
		statText.antialiasing = ClientPrefs.globalAntialiasing;
		updateStatText();
	}

	private function addUIElements():Void {
		add(menuBG);
		for (button in buttons) {
			add(button);
		}
		add(statText);
	}

	private function updateStatText():Void {
		statText.text = getStatsString();
	}

	private function getStatsString():String {
		var run = DoorsUtil.curRun;
		var mainStats = run.runScore > 0 ? getActiveRunStats() : getEmptyRunStats();
		
		return mainStats + 
			   getDifficultyString() +
			   getDoorString() +
			   getTimeString();
	}

	private function getActiveRunStats():String {
		return '${Lang.getText("score", "generalshit")}: ${formatLargeNumbers(Std.string(DoorsUtil.curRun.runScore))}\n\n' +
			   '${Lang.getText("runRating", "story/results")}${Std.string(Highscore.floorDecimal(DoorsUtil.curRun.runRating * 100, 2))}%\n\n' +
			   '${Lang.getText("misses", "generalshit")}: ${DoorsUtil.curRun.runMisses}\n\n';
	}

	private function getEmptyRunStats():String {
		return '${Lang.getText("noSongs", "story/runstats")}\n\n\n\n\n\n';
	}

	private function getDifficultyString():String {
		return '${Lang.getText("diff", "story/runstats")}: ${CoolUtil.capitalize(DoorsUtil.curRun.runDiff)}\n';
	}

	private function getDoorString():String {
		var run = DoorsUtil.curRun;
		if (run.curDoor <= 0) return "\n";
		
		return StoryMenuState.instance.activeEntities.exists("states.storymechanics.Dupe") ?
			   '${Lang.getText("currentDoor", "story/runstats")}: ???\n' :
			   '${Lang.getText("currentDoor", "story/runstats")}: ${run.curDoor}\n';
	}

	private function getTimeString():String {
		return '${Lang.getText("timePlayed", "story/runstats")}: ${formatTime(DoorsUtil.curRun.runHours, DoorsUtil.curRun.runSeconds)}\n';
	}

	// Button Callbacks
	private function showModifiers():Void {
		StoryMenuState.instance.openSubState(new ModifierSelectSubState(true));
	}

	private function resetGame():Void {
		StoryMenuState.resetData();
		MenuSongManager.playSound("cancelMenu", 1.0);
		@:privateAccess StoryMenuState.instance.changeState(() -> {
			MusicBeatState.switchState(new MainMenuState());
		});
	}

	private function exitStoryMode():Void {
		MusicBeatState.switchState(new MainMenuState());
	}

	private function formatLargeNumbers(nbr:String):String {
		var result = '';
		var count = 0;
		var i = nbr.length - 1;
		while (i >= 0) {
			result = nbr.charAt(i) + result;
			count++;
			if (count % 3 == 0 && i > 0) {
				result = "'" + result;
			}
			i--;
		}
		return result;
	}

	private function formatTime(hours:Int, seconds:Float):String {
		var totalSeconds = hours * 3600 + seconds;
		var minutes = Math.floor(totalSeconds / 60);
		var remainingSeconds = totalSeconds % 60;
		var milliseconds = Math.floor((remainingSeconds - Math.floor(remainingSeconds)) * 1000);

		var parts = {
			hours: StringTools.lpad(Std.string(hours), '0', 2),
			minutes: StringTools.lpad(Std.string(minutes % 60), '0', 2),
			seconds: StringTools.lpad(Std.string(Math.floor(remainingSeconds)), '0', 2),
			milliseconds: StringTools.lpad(Std.string(milliseconds), '0', 3)
		};

		return '${parts.hours}:${parts.minutes}:${parts.seconds}.${parts.milliseconds}';
	}

	override function startGaming():Void {
		doUpdate = true;
	}

	override function stopGaming():Void {
		close();
	}

	override function update(elapsed:Float):Void {
		buttonHovered = false;
		updateStatText();
		super.update(elapsed);
		theMouse.currentAction = buttonHovered ? POINTING : NONE;
	}
}