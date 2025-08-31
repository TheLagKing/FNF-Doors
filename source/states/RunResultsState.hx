package states;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.effects.particles.FlxEmitter;
import openfl.filters.ShaderFilter;
import shaders.HeatwaveShader;
import shaders.NoiseDeformShader;
import shaders.RainbowShader;
import objects.ui.DoorsButton;
import objects.ui.DoorsMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxTextNew as FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import DoorsUtil;
import Highscore;
import backend.metadata.StoryModeMetadata.RunRanking;

class RunResultsState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public var camFollowPos:FlxObject;
	var camFollow:FlxPoint;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var scoreText:FlxText;
	var accText:FlxText;
	var missText:FlxText;
	var modText:FlxText;
	var timeText:FlxText;
	var songAmtText:FlxText;

	var rankSprite:FlxSprite;
	var menu:DoorsMenu;

	var _outcome:RunOutcomeType;
	var bg:RunOutcome;

	var _rankOverwrite:Null<RunRanking>;

	public function new(outcome:RunOutcomeType, ?rankOverwrite:RunRanking){
		_outcome = outcome;
		_rankOverwrite = rankOverwrite;
		if(_rankOverwrite == null && (DoorsUtil.modifierActive(54) || _outcome == F1_LOSE)) _rankOverwrite = RunRanking.F;
		super();
	}

	override function create()
	{
		super.create();
		DoorsUtil.loadRunData();
		DoorsUtil.isDead = false;
		DoorsUtil.saveStoryData();
		
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		camFollowPos = new FlxObject(960, 540, 1, 1);
		camFollow = new FlxPoint(200, 200);

		camGame.follow(camFollowPos, LOCKON, 0.95);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		camGame.zoom = 0.67;

		var text:String = "";
		switch(_outcome) {
			case F1_WIN:
				MenuSongManager.crossfade("results_win", 1, 120, true);
				text = Lang.getText("tbc", "story/results");
			case F1_LOSE:
				MenuSongManager.crossfade("results_lose", 1, 120, true);
				text = Lang.getText("died", "story/results");
		}
		
		bg = new RunOutcome(_outcome);
		add(bg);


		menu = new DoorsMenu(0, 30, "post-run-stats", text, false);
		menu.cameras = [camHUD];
		add(menu);

		initializeTextElements(menu);

		rankSprite = new FlxSprite().loadGraphic(Paths.image("menus/post-run-stats/" + switch(_rankOverwrite??DoorsUtil.calculateRunRank()){
			case P: "PRank";
			case S: "SRank";
			case A: "ARank";
			case B: "BRank";
			case C: "CRank";
			case D: "DRank";
			case F: "FRank";
		}));
		rankSprite.scale.set(0.4, 0.4);
		rankSprite.updateHitbox();
		rankSprite.setPosition(461,switch(_rankOverwrite??DoorsUtil.calculateRunRank()){
			case P: 128;
			case S: 168;
			case A: 168;
			case B: 168;
			case C: 168;
			case D: 168;
			case F: 168;
		});
		rankSprite.antialiasing = ClientPrefs.globalAntialiasing;


		var kiki:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/post-run-stats/kiki"));
		kiki.scale.set(0.9, 0.9);
		kiki.updateHitbox();
		kiki.setPosition(
			rankSprite.x + (rankSprite.width/2 - kiki.width/2),
			rankSprite.y + (rankSprite.height/2 - kiki.height/2) + 5
		);
		kiki.antialiasing = ClientPrefs.globalAntialiasing;
		FlxTween.tween(kiki, {angle: 360}, 14, {type: LOOPING});

		menu.add(kiki);
		menu.add(rankSprite);

		var mmButton:DoorsButton = new DoorsButton(10, 579, Lang.getText("mainmenu", "newUI"), LARGE, NORMAL, function(){
			DoorsUtil.endRun();
			DoorsUtil.isDead = false;
			DoorsUtil.saveStoryData();
			MusicBeatState.switchState(new MainMenuState());
		});
		menu.add(mmButton);

		var newRunButton:DoorsButton = new DoorsButton(360, 579, Lang.getText("newrun", "newUI"), LARGE, NORMAL, function(){
			DoorsUtil.endRun();
			DoorsUtil.loadRunData();
			DoorsUtil.isDead = false;
			DoorsUtil.saveStoryData();
			MusicBeatState.switchState(new StoryMenuState());
		});
		menu.add(newRunButton);

		var heatwave = new NoiseDeformShader();
		heatwave.setStrength(15);
		heatwave.setScale(5);
		heatwave.setSpeedX(4);
		heatwave.setSpeedY(-4);
		heatwave.setAlphaThreshold(0.01);

		var newLineY = 369-51;
		for(i => entityData in DoorsUtil.curRun.entitiesToEncounter){
			if(i % 4 == 0) {
				newLineY += 51;
			}
			var indic = new EntityIndicator(11 + ((i % 4) * 166), newLineY, entityData.entityName, heatwave);
			menu.add(indic);
		}
		add(heatwave);

		updateAwards();
		addValues();
		addOutcomeShaders();
		addOutcomeParticles();
	}

	private function addOutcomeShaders() {
		switch(_outcome){
			case F1_LOSE:
				var waterShader = new HeatwaveShader();
				var waterFilter = new ShaderFilter(waterShader.shader);
				add(waterShader);
				camGame.setFilters([waterFilter]);
			default:
		}
	}
	
	private function addOutcomeParticles():Void {	
		switch(_outcome) {
			case F1_LOSE:
				var bubbleEmitter = new FlxEmitter(0, FlxG.height);
				bubbleEmitter.setSize(FlxG.width, 0);
				bubbleEmitter.launchMode = SQUARE;
				bubbleEmitter.velocity.set(-20, -100, 20, -200);
				bubbleEmitter.acceleration.set(-2, -5, 2, 5);
				bubbleEmitter.lifespan.set(8, 10);
				bubbleEmitter.alpha.set(0.7, 0.8, 0, 0);
				bubbleEmitter.keepScaleRatio = true;
				bubbleEmitter.scale.set(0.8, 0.8, 1.1, 1.1, 0.8, 0.8, 1.1, 1.1);
				bubbleEmitter.loadParticles(Paths.image('deathScreen/guiding/bubble'), 100);
				bubbleEmitter.cameras = [camGame];
				add(bubbleEmitter);

				var starsEmitter = new FlxEmitter(824, 204);
				starsEmitter.setSize(1,1);
				starsEmitter.launchMode = CIRCLE;
				starsEmitter.speed.set(100, 200, 800, 1000);
				starsEmitter.acceleration.set(-10, -20, 10, 20);
				starsEmitter.lifespan.set(12, 15);
				starsEmitter.alpha.set(0.2, 0.2, 0.8, 1);
				starsEmitter.keepScaleRatio = true;
				starsEmitter.scale.set(0.2, 0.2, 0.4, 0.4, 0.8, 0.8, 1.1, 1.1);
				starsEmitter.loadParticles(Paths.image('deathScreen/guiding/star'), 100);
				starsEmitter.cameras = [camGame];
				add(starsEmitter);
				
				bubbleEmitter.start(false, Conductor.crochet/1000);
				starsEmitter.start(false, Conductor.crochet/1000 * 2);
			default:
		}	
	}

	private function initializeTextElements(menu:DoorsMenu) {
		scoreText = new FlxText(11, 94, 0, Lang.getText("runScore", "story/results"), 24, 0, 0xFFFEDEBF);
		scoreText.setFormat(FONT, 24, 0xFFFEDEBF, LEFT);
		menu.add(scoreText);

		accText = new FlxText(11, 123, 0, Lang.getText("runRating", "story/results"), 24, 0, 0xFFFEDEBF);
		accText.setFormat(FONT, 24, 0xFFFEDEBF, LEFT);
		menu.add(accText);

		missText = new FlxText(11, 152, 0, Lang.getText("runMiss", "story/results"), 24, 0, 0xFFFEDEBF);
		missText.setFormat(FONT, 24, 0xFFFEDEBF, LEFT);
		menu.add(missText);

		modText = new FlxText(11, 186, 0, Lang.getText("runMods", "story/results"), 36, 0, 0xFFFEDEBF);
		modText.setFormat(FONT, 36, 0xFFFEDEBF, LEFT);
		menu.add(modText);

		timeText = new FlxText(11, 253, 0, Lang.getText("runTime", "story/results"), 36, 0, 0xFFFEDEBF);
		timeText.setFormat(FONT, 36, 0xFFFEDEBF, LEFT);
		menu.add(timeText);

		songAmtText = new FlxText(10, 316, 0, Lang.getText("runSongs", "story/results"), 36, 0, 0xFFFEDEBF);
		songAmtText.setFormat(FONT, 36, 0xFFFEDEBF, LEFT);
		menu.add(songAmtText);
	}

	private function updateAwards() {
		switch(_outcome) {
			case F1_WIN:
				AwardsManager.youWin = true;
				if(DoorsUtil.curRun.runDiff.toLowerCase() == "hard") AwardsManager.youWinHard = true;
				if(DoorsUtil.curRun.runMisses <= 0) AwardsManager.thatsEasy = true;
				if(DoorsUtil.curRun.runMisses <= 0 && DoorsUtil.curRun.runRating >= 0.999) AwardsManager.tissButAScratch = true;
				if(DoorsUtil.curRun.runKnobModifier >= 2.5) AwardsManager.hotelHell = true;
				if(!AwardsManager.hasMissedHeartbeat) AwardsManager.cardiacArrest = true; 
				if(AwardsManager.hasOnlyPickedHigher) AwardsManager.youreFast = true;
				if(AwardsManager.hasOnlyPickedLower) AwardsManager.youreSlow = true;
			case F1_LOSE:
				
		}


		AwardsManager.onFinishRun();
	}

	private function addValues(){
		var rainbow = new RainbowShader();
		rainbow.setSpeed(0.5);
		rainbow.setFrequency(0.5);
		rainbow.setSaturation(0.8);
		rainbow.setBrightness(1.8);
		add(rainbow);

		trace(FlxG.save.data.bestSMScore, DoorsUtil.curRun.runScore);
		trace(FlxG.save.data.bestSMMiss, DoorsUtil.curRun.runMisses);
		trace(FlxG.save.data.bestSMAcc, DoorsUtil.curRun.runRating);

		if(FlxG.save.data.bestSMScore == null || FlxG.save.data.bestSMScore <= DoorsUtil.curRun.runScore) {
			var newBestScore = new FlxText(265, 94, 0, Lang.getText("newBest", "story/results"));
			newBestScore.setFormat(FONT, 24, 0xFFFFFFFF);
			menu.add(newBestScore);
			newBestScore.shader = rainbow.shader;
		}

		if(FlxG.save.data.bestSMMiss == null || FlxG.save.data.bestSMMiss >= DoorsUtil.curRun.runMisses) {
			var newBestScore = new FlxText(265, 150, 0, Lang.getText("newBest", "story/results"));
			newBestScore.setFormat(FONT, 24, 0xFFFFFFFF);
			menu.add(newBestScore);
			newBestScore.shader = rainbow.shader;
		}

		if(FlxG.save.data.bestSMAcc == null || FlxG.save.data.bestSMAcc <= DoorsUtil.curRun.runRating) {
			var newBestScore = new FlxText(265, 122, 0, Lang.getText("newBest", "story/results"));
			newBestScore.setFormat(FONT, 24, 0xFFFFFFFF);
			menu.add(newBestScore);
			newBestScore.shader = rainbow.shader;
		}

		scoreText.text += Std.string(DoorsUtil.curRun.runScore);
		var actualPercent = Highscore.floorDecimal(DoorsUtil.curRun.runRating * 100, 2) + "%";
		accText.text += Std.string(actualPercent);
		missText.text += Std.string(DoorsUtil.curRun.runMisses);
		modText.text += ((DoorsUtil.curRun.runKnobModifier - 1) > 0 ? "+" : "") + 
						(DoorsUtil.curRun.runKnobModifier - 1) * 100 + "%";
		timeText.text += formatTime(DoorsUtil.curRun.runHours, DoorsUtil.curRun.runSeconds);
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

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT || controls.BACK) {
				leftState = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		super.update(elapsed);
	}
}

enum RunOutcomeType {
	F1_WIN;
	F1_LOSE;
}

class RunOutcome extends FlxSpriteGroup {
	var _outcome:RunOutcomeType;

	public function new(outcome:RunOutcomeType) {
		super(0, 0);
		_outcome = outcome;

		switch(outcome){
			case F1_WIN:
				var bgDark:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-win/bg_dark"));
				bgDark.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgDark);
				
				var bgLight:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-win/bg_lit"));
				bgLight.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgLight);

				_winStartLightTweens(bgDark, bgLight);
			case F1_LOSE:
				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/bg"));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);
				
				var mic:FlxSprite = new FlxSprite(1546, 327).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/floating_mic"));
				mic.antialiasing = ClientPrefs.globalAntialiasing;
				add(mic);
				
				var gradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/gradient"));
				gradient.antialiasing = ClientPrefs.globalAntialiasing;
				add(gradient);
				
				var hand:FlxSprite = new FlxSprite(993, 240).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/hand"));
				hand.antialiasing = ClientPrefs.globalAntialiasing;
				add(hand);
				
				var moon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/moon"));
				moon.antialiasing = ClientPrefs.globalAntialiasing;
				add(moon);
				
				var fg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/outcomes/f1-lose/fg"));
				fg.antialiasing = ClientPrefs.globalAntialiasing;
				add(fg);

				FlxTween.tween(mic, {y: mic.y + 20}, 3, {ease: FlxEase.sineInOut, type: PINGPONG});
				FlxTween.tween(hand, {y: hand.y + 20}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
		}
	}

	function _winStartLightTweens(dark:FlxSprite, light:FlxSprite){
		FlxTween.tween(light, {alpha: FlxG.random.float(0, 0.3)}, FlxG.random.float(0.6, 2), {ease: FlxEase.bounceOut, startDelay: FlxG.random.float(0.6, 2), onComplete: function(twn){
			FlxTween.tween(light, {alpha: FlxG.random.float(0.8, 1)}, FlxG.random.float(0.3, 0.9), {ease: FlxEase.bounceOut, startDelay: FlxG.random.float(0.3, 0.9), onComplete: function(twn){
				_winStartLightTweens(dark, light);
			}});
		}});
	}
}

class EntityIndicator extends FlxSpriteGroup {
	public var assignedEntity:String;
	public var bg:FlxSprite;
	public var text:FlxText;
	public var amount:FlxText;

	public var entitySeenAmount(get, never):Int;
	public function get_entitySeenAmount(){
		for(entity in DoorsUtil.curRun.entitiesEncountered.keys()){
			if(DoorsUtil.curRun.entitiesToEncounter.filter(function(data) {
				return data.entityName == entity && data.entityName.toLowerCase() == assignedEntity.toLowerCase();
			}).length > 0){
				return DoorsUtil.curRun.entitiesEncountered.get(entity);
			}
		}
		return 0;
	}

	public function new(x:Float, y:Float, entity:String, ?noiseShader:NoiseDeformShader){
		super(x, y);

		this.assignedEntity = entity;

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/post-run-stats/entitySeen"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		text = new FlxText(0, 3, bg.width, entity.toUpperCase(), 24);
		text.setFormat(FONT, 24, 0xFFFEDEBF, CENTER);
		text.antialiasing = ClientPrefs.globalAntialiasing;
		add(text);

		amount = new FlxText(140, -5, 0, "x0", 18);
		amount.setFormat(FONT, 32, 0xFFFEDEBF, LEFT, OUTLINE, 0xFF452D25);
		amount.antialiasing = ClientPrefs.globalAntialiasing;
		amount.angle = 10;
		
		if(entitySeenAmount == 0){
			bg.loadGraphic(Paths.image("menus/post-run-stats/entityNotSeen"));
			bg.alpha = 0.3;
			text.alpha = 0.3;
			bg.shader = noiseShader.shader;
			text.shader = noiseShader.shader;
		} else {
			if(entitySeenAmount > 1) add(amount);
			amount.text = "x" + entitySeenAmount;
		}
	}
}
