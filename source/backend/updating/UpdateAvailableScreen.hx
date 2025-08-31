package backend.updating;

import backend.MarkdownUtil;
import states.MainMenuState;
import flixel.math.FlxPoint;
import backend.updating.UpdateUtil.UpdateCheckCallback;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;

class UpdateAvailableScreen extends MusicBeatState {
	public var bg:FlxSprite;

	public var versionCheckBG:FlxSprite;
	public var title:FlxText;
	public var versionDifferenceLabel:FlxText;
	public var changeLogText:FlxText;
	public var check:UpdateCheckCallback;

	public var optionsBG:FlxSprite;
	public var installButton:FlxText;
	public var skipButton:FlxText;

	public var installSelected:Bool = true;

	public function new(check:UpdateCheckCallback) {
		super();
		this.check = check;
	}

	public override function create() {
		super.create();

		FlxG.camera.flash(0xFF000000, 0.25);
		MenuSongManager.crossfade("glPractice", 1, 120, true);

		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat1"));
		bg.color = 0xFF181818;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();
		add(bg);

		title = new FlxText(0, -1, FlxG.width, "NEW UPDATE AVAILABLE", 32, false);
		title.setFormat(FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		title.antialiasing = ClientPrefs.globalAntialiasing;

		versionDifferenceLabel = new FlxText(0, title.y + title.height - 20, FlxG.width, '(CURRENT) ${check.currentVersionTag} - ${check.newVersionTag} (NEWEST)', 28, false);
		versionDifferenceLabel.setFormat(FONT, 28, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		versionDifferenceLabel.antialiasing = ClientPrefs.globalAntialiasing;

		versionCheckBG = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/updating/topPart"));
		versionCheckBG.antialiasing = ClientPrefs.globalAntialiasing;

		changeLogText = new FlxText(0, versionCheckBG.y + versionCheckBG.height + 10, FlxG.width, "", 20, true);
		changeLogText.borderColor = 0xFF000000;
		MarkdownUtil.applyMarkdownText(changeLogText, check.updates[check.updates.length - 1].body);
		changeLogText.antialiasing = ClientPrefs.globalAntialiasing;
		changeLogText.font = FONT;

		installButton = new FlxText(0, FlxG.height, Std.int(FlxG.width / 2), "> INSTALL NEWEST <", 32);
		installButton.setFormat(MEDIUM_FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		installButton.antialiasing = ClientPrefs.globalAntialiasing;

		skipButton = new FlxText(Std.int(FlxG.width / 2), FlxG.height, Std.int(FlxG.width / 2), "SKIP INSTALLATION", 32);
		skipButton.setFormat(FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		skipButton.antialiasing = ClientPrefs.globalAntialiasing;

		skipButton.y = 620;
		installButton.y = 620;

		installButton.alignment = skipButton.alignment = CENTER;

		optionsBG = new FlxSprite(0, FlxG.height - 100).loadGraphic(Paths.image("menus/updating/bottomPart"));
		optionsBG.alpha = 0.75;

		add(changeLogText);

		add(versionCheckBG);
		add(title);
		add(versionDifferenceLabel);

		add(optionsBG);
		add(installButton);
		add(skipButton);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		oldPos = FlxG.mouse.getScreenPosition();
	}

	var destY:Float = 0;
	var oldPos:FlxPoint;

	public override function update(elapsed:Float) {
		super.update(elapsed);

		destY = FlxMath.bound(destY - (FlxG.mouse.wheel * 75), 0, Math.max(0, changeLogText.height - FlxG.height + versionCheckBG.height + 20 + optionsBG.height));
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, destY, 1/3);

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			installSelected = !installSelected;
			changeSelection();
		}

		var newPos = FlxG.mouse.getScreenPosition();
		if (oldPos.x != newPos.x || oldPos.y != newPos.y) {
			if (newPos.y >= optionsBG.y) {
				if (installSelected != (installSelected = (newPos.x < (FlxG.width / 2)))) {
					changeSelection();
				}
			}
			oldPos = newPos;
		}

		if (controls.ACCEPT || (newPos.y >= optionsBG.y && FlxG.mouse.justPressed))
			select();
	}

	public function select() {
		if (installSelected) {
			MenuSongManager.playSound("confirmMenu");
			FlxG.switchState(new UpdateScreen(check));
		} else {
			MenuSongManager.playSound("cancelMenu");
			FlxG.switchState(new MainMenuState());
		}
	}


	public function changeSelection() {
		if (installSelected) {
			installButton.text = "> INSTALL NEWEST <";
			installButton.setFormat(MEDIUM_FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
			skipButton.text = "SKIP INSTALLATION";
			skipButton.setFormat(FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		} else {
			installButton.text = "INSTALL NEWEST";
			installButton.setFormat(FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
			skipButton.text = "> SKIP INSTALLATION <";
			skipButton.setFormat(MEDIUM_FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		}
	}

	public override function destroy() {
		super.destroy();
		oldPos.put();
	}
}