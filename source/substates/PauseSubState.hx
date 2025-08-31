package substates;

import shaders.NoiseDeformShader;
import options.substates.BaseOptionsMenu;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import flixel.group.FlxGroup;
import objects.ui.DoorsButton;
import objects.ui.DoorsMenu;
import options.substates.GameplaySettingsSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;
import DoorsUtil;
import backend.metadata.SongMetadata;
import flxanimate.FlxAnimate;

class PauseSubState extends MusicBeatSubstate {
    public static var instance:PauseSubState;

    private var pauseMusic:FlxSound;
    private var bg:FlxSprite;
    private var vinyl:PauseVinyl;

    private var menuGroup:FlxSpriteGroup;
    private var pauseMenu:DoorsMenu;
    private var buttonGroup:FlxTypedSpriteGroup<DoorsButton>;

    private var creditsText:FlxText;
    private var revivesText:FlxText;

    private var holdTime:Float = 0;
    private var cantUnpause:Float = 0.1;
    private var canUnPause:Bool = true;

    public function new() {
        super();
        instance = this;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        setupBackground();
        setupAudio();
        setupVinyl();
        setupMenu();
        playEnterAnimations();

        FlxTween.freezeStateName = "states.PlayState";
        persistentUpdate = false;
    }

    private function setupBackground():Void {
        bg = new FlxSprite(0, 0)
            .makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);
    }

    private function setupAudio():Void {
        pauseMusic = new FlxSound();
        pauseMusic.loadEmbedded(Paths.music("SillyPause"), true, true);
        pauseMusic.volume = 0;
        pauseMusic.play(false);
        FlxG.sound.list.add(pauseMusic);
    }

    private function setupVinyl():Void {
        var meta = loadMetadata();
        vinyl = new PauseVinyl(FlxG.width, 0, meta.ostArtPath ?? "guidingLight");
        vinyl.rotationSpeed = 300;
        add(vinyl);

        var meta = loadMetadata();
        if(ClientPrefs.data.shaders && meta.ostArtPath != null && meta.ostArtPath == "glitch") {
            var heatwave = new NoiseDeformShader();
            heatwave.setStrength(5);
            heatwave.setScale(5);
            heatwave.setSpeedX(4);
            heatwave.setSpeedY(-4);
            heatwave.setAlphaThreshold(0.01);
            add(heatwave);

            vinyl.shader = heatwave.shader;
        }
    }

    private function setupMenu():Void {
        menuGroup = new FlxSpriteGroup(40, 40);
        add(menuGroup);

        pauseMenu = new DoorsMenu(
            0, 0,
            "pause",
            Lang.getText("pause", "newUI") + " - " + CoolUtil.getDisplaySong(PlayState.SONG.song),
            false
        );
        menuGroup.add(pauseMenu);

        buttonGroup = new FlxTypedSpriteGroup<DoorsButton>(16, 558);
        createButtons();
        menuGroup.add(buttonGroup);

        createCredits();
        createDifficultyBars();
    }

    private function createButtons():Void {
        var labels = ["QUIT", "RESTART", "OPTIONS", "RESUME"];
        for (i in 0...labels.length) {
            var label = labels[i];
            var style = switch (label) {
                case "QUIT", "RESTART": DoorsButtonWeight.DANGEROUS;
                case "OPTIONS": DoorsButtonWeight.NORMAL;
                default: DoorsButtonWeight.PRIORITY;
            };
            var btn = new DoorsButton(166 * i, 0,
                Lang.getText(label.toLowerCase(), "newUI"), MEDIUM, style,
                function() onPress(label)
            );
            buttonGroup.add(btn);

            var meta = loadMetadata();
            if(label == "RESTART" && PlayState.isStoryMode && DoorsUtil.curRun.revivesLeft <= 0) {
                if(ClientPrefs.data.shaders) {
                    var heatwave = new NoiseDeformShader();
                    heatwave.setStrength(15);
                    heatwave.setScale(5);
                    heatwave.setSpeedX(4);
                    heatwave.setSpeedY(-4);
                    heatwave.setAlphaThreshold(0.01);
                    add(heatwave);

                    btn.bg.shader = heatwave.shader;
                    btn.buttonText.shader = heatwave.shader;
                }
                btn.whenClicked = function() {
			        MenuSongManager.playSoundWithRandomPitch("glitch", [0.8, 1.2], 1.0);
                }
                btn.makeButton = function(text:String) {}
            }

            if(label == "OPTIONS" && meta.ostArtPath != null && meta.ostArtPath == "glitch") {
                if(ClientPrefs.data.shaders) {
                    var heatwave = new NoiseDeformShader();
                    heatwave.setStrength(15);
                    heatwave.setScale(5);
                    heatwave.setSpeedX(4);
                    heatwave.setSpeedY(-4);
                    heatwave.setAlphaThreshold(0.01);
                    add(heatwave);

                    btn.bg.shader = heatwave.shader;
                    btn.buttonText.shader = heatwave.shader;
                }
                btn.whenClicked = function() {
			        MenuSongManager.playSoundWithRandomPitch("glitch", [0.8, 1.2], 1.0);
                }
                btn.makeButton = function(text:String) {}
            }
        }
    }

    private function createCredits():Void {
        creditsText = makeText(19, 96, makeCreditLines());
        menuGroup.add(creditsText);

        if (PlayState.isStoryMode) {
            revivesText = makeText(
                19,
                creditsText.y + creditsText.height - 24,
                "Revives left: " + DoorsUtil.curRun.revivesLeft
            );
            menuGroup.add(revivesText);
        }
    }

    private function createDifficultyBars():Void {
        var baseY = (revivesText != null)
            ? revivesText.y + revivesText.height - 24
            : creditsText.y + creditsText.height;

        var diffBar = new PauseDifficultyBar(29, baseY, loadMetadata(), "DIFF");
        diffBar.selectedDifficulty = PlayState.storyDifficulty;
        menuGroup.add(diffBar);

        var mDiffBar = new PauseDifficultyBar(29, diffBar.y + diffBar.height - 12, loadMetadata(), "MDIFF");
        mDiffBar.selectedDifficulty = PlayState.storyDifficulty;
        menuGroup.add(mDiffBar);
    }

    private function makeText(x:Float, y:Float, text:String):FlxText {
        var t = new FlxText(x, y, 642, text, 32);
        t.setFormat(FONT, 32, 0xFFFEDEBF, LEFT, OUTLINE, 0xFF452D25);
        t.antialiasing = ClientPrefs.globalAntialiasing;
        return t;
    }

    private function loadMetadata():SongMetadata {
        return new SongMetadata(PlayState.SONG.song.toLowerCase().replace(' ', '-'));
    }

    private function makeCreditLines():String {
        var meta = loadMetadata();
        var artists    = meta.artists       ?? ["PLACEHOLDER"];
        var composers  = meta.music         ?? ["PLACEHOLDER"];
        var easy       = meta.easyCharters   ?? ["PLACEHOLDER"];
        var normal     = meta.normalCharters ?? ["PLACEHOLDER"];
        var hard       = meta.hardCharters   ?? ["PLACEHOLDER"];

        var artLine   = formatLine("art", artists);
        var musicLine = formatLine("music", composers);
        var charters = switch (PlayState.storyDifficulty) {
            case 0: easy;
            case 1: normal;
            case 2: hard;
            case 3: normal;
            default: normal;
        };
        var chartLine = formatLine("chart", charters);

        return artLine + "\n" + musicLine + "\n" + chartLine;
    }

    private function formatLine(key:String, items:Array<String>):String {
        return Lang.getText(key, "newCredit") + ": " + items.join(" | ");
    }

    private function playEnterAnimations():Void {
        bg.alpha = 0;
        menuGroup.x -= FlxG.width;
        TweenHandler(menuGroup, { x: 40 }, 0.6, { ease: FlxEase.quartInOut });
        TweenHandler(vinyl, { x: FlxG.width - 360 }, 0.6, { ease: FlxEase.quartInOut });
        TweenHandler(vinyl, { rotationSpeed: 10 }, 3, { ease: FlxEase.sineInOut });
        TweenHandler(bg, { alpha: 0.8 }, 0.6, { ease: FlxEase.quartInOut, startDelay: 0.3 });
    }

    public function TweenHandler(target:Dynamic, props:Dynamic, duration:Float, ?options:TweenOptions):VarTween {
        var t = options != null
            ? FlxTween.tween(target, props, duration, options)
            : FlxTween.tween(target, props, duration);
        t.stateName = "pauseMenu";
        return t;
    }

    override function update(elapsed:Float):Void {
        cantUnpause -= elapsed;
        pauseMusic.volume = Math.min(0.8, pauseMusic.volume + 0.1 * elapsed);
        if (cantUnpause <= 0 && Controls.instance.ACCEPT) onPress("RESUME");
        super.update(elapsed);
    }

    public static function restartSong(noTrans:Bool = false):Void {
        PlayState.instance.paused = true;

        if(PlayState.isStoryMode) {
            DoorsUtil.curRun.revivesLeft -= 1;
            DoorsUtil.saveRunData();
        }
        MusicBeatState.resetState();
    }

    override function destroy():Void {
        FlxTween.freezeStateName = "";
        pauseMusic.destroy();
        super.destroy();
    }

    private function onPress(label:String):Void {
        if(!canUnPause) return;
        switch (label) {
            case "RESUME": stopGaming();
            case "RESTART": confirmOrRestart();
            case "OPTIONS": openOptions();
            case "QUIT": confirmOrQuit();
        }
    }

    private function confirmOrRestart():Void {
        if (PlayState.isStoryMode) openSubState(new WarningSubState("RESTART"));
        else restartSong();
    }

    private function confirmOrQuit():Void {
        if (PlayState.isStoryMode) openSubState(new WarningSubState("QUIT"));
        else performQuit();
    }

    private function openOptions():Void {
        BaseOptionsMenu.hideGlasshat = true;
        openSubState(new GameplaySettingsSubState(true));
    }

    public static function performQuit():Void {
        if (DoorsUtil.curRun.revivesLeft > 0 || !PlayState.isStoryMode) {
            PlayState.deathCounter = 0;
            PlayState.seenCutscene = false;
            if (PlayState.isStoryMode) {
                DoorsUtil.curRun.revivesLeft -= 1;
                DoorsUtil.curRun.latestHealth = Math.max(1, PlayState.instance.health);
                DoorsUtil.saveRunData();
            }
            MenuSongManager.curMusic = "";
            if (PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
            else MusicBeatState.switchState(new NewFreeplayState());
            PlayState.cancelMusicFadeTween();
            PlayState.changedDifficulty = false;
            PlayState.chartingMode = false;
        } else {
            PlayState.deathCounter = 0;
            PlayState.seenCutscene = false;
            StoryMenuState.resetData();
            if (PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
            PlayState.cancelMusicFadeTween();
            PlayState.changedDifficulty = false;
            PlayState.chartingMode = false;
        }
    }

    private function stopGaming():Void {
        canUnPause = false;
        var step = 0;
        new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
            var introSounds = ['3', '2', '1'];
            var graphicKeys = ['ready', 'set', 'go'];
            var antialias = ClientPrefs.globalAntialiasing;
            switch (step) {
                case 0:
                    TweenHandler(vinyl, { x: FlxG.width }, Conductor.crochet / 1000 * 4, { ease: FlxEase.quartInOut });
                    TweenHandler(vinyl, { rotationSpeed: 300 }, Conductor.crochet / 1000, { ease: FlxEase.quartInOut });
                    TweenHandler(menuGroup, { x: -menuGroup.width }, Conductor.crochet / 1000, { ease: FlxEase.quartInOut });
                    TweenHandler(bg, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.quartInOut });
                    showCountdownSprite(graphicKeys[0], introSounds[0], antialias);
                case 1:
                    showCountdownSprite(graphicKeys[1], introSounds[1], antialias);
                case 2:
                    showCountdownSprite(graphicKeys[2], introSounds[2], antialias);
                case 3:
                    canUnPause = true;
                    close();
            }
            step++;
        }, 4);
    }

    private function showCountdownSprite(imgKey:String, sndKey:String, antialias:Bool):Void {
        var sprite = new FlxSprite().loadGraphic(Paths.image(imgKey));
        sprite.scrollFactor.set();
        sprite.updateHitbox();
        sprite.screenCenter();
        sprite.antialiasing = antialias;
        add(sprite);
        TweenHandler(sprite, { alpha: 0 }, Conductor.crochet / 1000, {
            ease: FlxEase.cubeInOut,
            onComplete: function(t) {
                remove(sprite);
                sprite.destroy();
            }
        });
        FlxG.sound.play(Paths.sound('intro' + sndKey), 0.6);
    }
}


class PauseVinyl extends FlxSprite {
	public var rotationSpeed:Float = 30;

	public function new(x:Float, y:Float, artPath:String, ?w:Int = 720, ?h:Int = 720){
		super(x, y);
		loadGraphic(Paths.image("ostArt/vinyls/" + artPath));
		setGraphicSize(w, h);
		updateHitbox();
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed){
		super.update(elapsed);

		angle += rotationSpeed * elapsed * 6;
	}
}

class PauseDifficultyBar extends FlxSpriteGroup {
	public var curDifficulty:Int = 0;
	var _lerpedDifficulty:Float = 0;

	var _metadata:SongMetadata;
	var _target:String = "DIFF";

	public var isUnlocked:Bool = true;
	public var isGlitch:Bool = false;

	public var selectedDifficulty(default, set):Int = 0;
	function set_selectedDifficulty(v:Int){
		if(_target == "MDIFF")
			curDifficulty = switch(v) {
				case 0: _metadata.mechanicDifficulties.easy;
				case 1: _metadata.mechanicDifficulties.normal;
				case 2: _metadata.mechanicDifficulties.hard;
				case 3: _metadata.mechanicDifficulties.hell;
				default: _metadata.mechanicDifficulties.normal;
			}
		else 
			curDifficulty = switch(v) {
				case 0: _metadata.difficulties.easy;
				case 1: _metadata.difficulties.normal;
				case 2: _metadata.difficulties.hard;
				case 3: _metadata.difficulties.hell;
				default: _metadata.difficulties.normal;
			}
		
		number.text = Std.string(curDifficulty);
		if (!isUnlocked) {
			curDifficulty = 0;
			number.text = "???";
		} else if (curDifficulty == -2){
			number.text = "TBD";
		} else if (curDifficulty == -1){
			number.text = "N/A";
		}
		
		selectedDifficulty = v;
		return v;
	}

	var actualBar:FlxAnimate;
	var label:FlxText;
	var number:FlxText;

	// Target can only be "DIFF" or "MDIFF" for Difficulty and Mechanic Difficulty
	public function new(x:Float, y:Float, songMetadata:SongMetadata, target:String){
		super(x, y);

		_metadata = songMetadata;
		_target = target;

		actualBar = new FlxAnimate(0, 6);
		Paths.loadAnimateAtlas(actualBar, "freeplay/new/difficulty-bar");
		actualBar.anim.addBySymbol("idle", "note bar", 24, false);
		actualBar.anim.play("idle", true, false, 0);
		actualBar.anim.pause();
		actualBar.setGraphicSize(233, 56);
		actualBar.updateHitbox();
		actualBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(actualBar);

		label = new FlxText(260, 9, 0, switch(_target){
			case "DIFF": Lang.getText("diff", "states/newFreeplay") + ":";
			case "MDIFF": Lang.getText("mdiff", "states/newFreeplay") + ":";
			default: Lang.getText("diff", "states/newFreeplay") + ":";
		}, 36, 0, 0xFFFEDEBF);
		label.antialiasing = ClientPrefs.globalAntialiasing;
		label.setFormat(FONT, 36, 0xFFFEDEBF, LEFT);
		add(label);

		number = new FlxText(label.x + label.width + 4, 0, 200, Std.string(curDifficulty), 48, 0, 0xFFFEDEBF);
		number.antialiasing = ClientPrefs.globalAntialiasing;
		number.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
		add(number);
	}

	override function update(elapsed:Float){
		_lerpedDifficulty = FlxMath.lerp(_lerpedDifficulty, curDifficulty, CoolUtil.boundTo(elapsed * 4, 0, 1));
		actualBar.anim.curFrame = Math.round(_lerpedDifficulty);

		super.update(elapsed);
	}
}