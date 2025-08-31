package backend.updating;

import states.TitleState;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.ui.FlxBar;
import backend.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends MusicBeatState {
	public var updater:AsyncUpdater;

	public var progressBar:FlxBar;

	public var done:Bool = false;
	public var elapsedTime:Float = 0;
	public var lerpSpeed:Float = 0;

	public var generalProgress:FlxText;
	public var partProgress:FlxText;

	public function new(check:UpdateCheckCallback) {
		super();
		updater = new AsyncUpdater(check.updates);
	}

	public override function create() {
		super.create();

		progressBar = new FlxBar(0, FlxG.height - 75, LEFT_TO_RIGHT, FlxG.width, 75);
		progressBar.createGradientBar([0xFF000000], [0xFFFEDEBF, 0xFF452D25], 1, 90);
		progressBar.setRange(0, 4);
		progressBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(progressBar);

		partProgress = new FlxText(0, progressBar.y, FlxG.width, "-\n-", 20);
		partProgress.y -= partProgress.height;
		partProgress.setFormat(FONT, 20, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		partProgress.alignment = CENTER;
		partProgress.antialiasing = ClientPrefs.globalAntialiasing;
		add(partProgress);

		generalProgress = new FlxText(0, partProgress.y - 10, FlxG.width, "", 32);
		generalProgress.y -= generalProgress.height;
		generalProgress.alignment = CENTER;
		generalProgress.setFormat(FONT, 20, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		generalProgress.antialiasing = ClientPrefs.globalAntialiasing;
		add(generalProgress);

		updater.execute();
	}


	public override function update(elapsed:Float) {
		super.update(elapsed);

		elapsedTime += elapsed;

		progressBar.y = FlxG.height - (65 + (Math.sin(elapsedTime * Math.PI / 2) * 10));

		if (done) return;

		var prog = updater.progress;
		lerpSpeed = FlxMath.lerp(lerpSpeed, prog.downloadSpeed, 0.0625);
		switch(prog.step) {
			case PREPARING:
				progressBar.value = 0;
				generalProgress.text = "Preparing update installation... (1/5)";
				partProgress.text = "Creating installation folder and cleaning old update files...";
			case DOWNLOADING_ASSETS:
				progressBar.value = 1 + ((prog.curFile-1+(prog.bytesLoaded/prog.bytesTotal)) / prog.files);
				generalProgress.text = "Downloading update assets... (2/5)";
				partProgress.text = 'Downloading file ${prog.curFileName}\n(${prog.curFile+1}/${prog.files} | ${CoolUtil.getSizeString(prog.bytesLoaded)} / ${CoolUtil.getSizeString(prog.bytesTotal)} | ${CoolUtil.getSizeString(lerpSpeed)}/s)';
			case DOWNLOADING_EXECUTABLE:
				progressBar.value = 2 + (prog.bytesLoaded/prog.bytesTotal);
				generalProgress.text = "Downloading new engine executable... (3/5)";
				partProgress.text = 'Downloading ${prog.curFileName}\n(${CoolUtil.getSizeString(prog.bytesLoaded)} / ${CoolUtil.getSizeString(prog.bytesTotal)} | ${CoolUtil.getSizeString(lerpSpeed)}/s)';
			case REMOVING_OLD:
				progressBar.value = 3 + (prog.curFile/prog.files);
				generalProgress.text = "Removing old files... (4/5)";
				partProgress.text = 'Removing ${prog.curFileName}';
			case INSTALLING:
				progressBar.value = 4 + ((prog.curFile-1+(prog.curZipProgress.curFile/prog.curZipProgress.fileCount))/prog.files);
				generalProgress.text = "Installing new files... (5/5)";
				partProgress.text = 'Installing ${prog.curFileName}\n(${prog.curFile}/${prog.files})';
		}
		if (done = prog.done) {	
			remove(generalProgress);
			remove(partProgress);

			FlxG.camera.fade(0xFF000000, 1.0, false, function() {
				if (updater.executableReplaced) {
					// the executable has been replaced, restart the game entirely
					Sys.command('start "title" "${AsyncUpdater.executableName}" /b');
					openfl.system.System.exit(0);
				} else {
					// assets update, switch back to TitleState.
					FlxG.switchState(new TitleState());
				}
			});
		}
	}
}
