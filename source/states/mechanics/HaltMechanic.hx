package states.mechanics;

import shaders.HaltChromaticAberration;
import shaders.GlitchShader;
#if !flash 
import openfl.filters.ShaderFilter;
#end

class HaltMechanic extends MechanicsManager
{
	// UI Elements
	private var blue_vignette:FlxSprite;
	private var turnaroundbitch:FlxSprite;
	private var haltIcon:FlxSprite;

	// Gameplay variables
	private var haltState:Bool = false;
	private var storyDifficulty:Int = 1;
	private var oteTime:Float = 0;
	
	// Hitboxes
	private var bfHitbox:FlxSprite;
	private var haltHitbox:FlxSprite;
	private var bfHitboxOTE:FlxSprite;

	// Shaders
	private var haltGlitch:GlitchShader;
	private var haltChroma:HaltChromaticAberration;

	// Song beat patterns
	private var haltPatterns:Map<String, HaltBeatPattern> = new Map();

	public function new()
	{
		super();
		storyDifficulty = PlayState.storyDifficulty;
		setupHaltPatterns();
	}

	private function setupHaltPatterns():Void
	{
		haltPatterns.set('halt', new HaltBeatPattern([0, 128, 448], [64, 320]));
		haltPatterns.set('onward', new HaltBeatPattern([0, 160, 224, 352], [96, 192, 288, 416]));
		haltPatterns.set('onward-hell', new HaltBeatPattern([0, 96, 160, 224, 352, 480], [32, 128, 192, 288, 416]));
	}

	override function create()
	{
		// Preload assets
		Paths.getSparrowAtlas('haltIcon');
		Paths.image('turnaroundbitch');
		Paths.image('blue_vignette');
	}

	override function createPost()
	{
		setupUI();
		setupShaders();
		setupHitboxes();
		
		game.dad.alpha = 0.7;
		if(PlayState.isStoryMode) game.health = 1;
	}
	
	private function setupUI():Void
	{
		// Hide the original P2 icon
		game.iconP2.alpha = 0;
		
		// Setup Halt icon
		haltIcon = new FlxSprite(260, 0);
		haltIcon.frames = Paths.getSparrowAtlas('haltIcon');
		haltIcon.animation.addByPrefix("death", "Halt Glitch Left0", 24, true, false, false);
		haltIcon.animation.addByPrefix("idle", "Halt Left0", 24, true, false, false);
		haltIcon.animation.play("idle");
		haltIcon.flipX = false;
		haltIcon.setGraphicSize(200);
		haltIcon.updateHitbox();
		if(!ClientPrefs.data.downScroll) haltIcon.y = game.healthBar.y - 60;
		haltIcon.antialiasing = ClientPrefs.globalAntialiasing;
		haltIcon.cameras = [game.camHUD];
		
		// Setup turnaround warning
		turnaroundbitch = new FlxSprite().loadGraphic(Paths.image('turnaroundbitch'), 0, 0);
		turnaroundbitch.screenCenter();
		turnaroundbitch.alpha = 0.00001;
		turnaroundbitch.antialiasing = ClientPrefs.globalAntialiasing;
		turnaroundbitch.cameras = [game.camHUD];
		
		// Setup blue vignette
		blue_vignette = new FlxSprite().loadGraphic(Paths.image('blue_vignette'), 0, 0);
		blue_vignette.scale.set(1280/1920, 720/1080);
		blue_vignette.updateHitbox();
		blue_vignette.screenCenter();
		blue_vignette.alpha = 0.0001;
		blue_vignette.cameras = [game.camHUD];
		
		// Add sprites to stage
		add(haltIcon);
		add(turnaroundbitch);
		add(blue_vignette);
	}
	
	private function setupShaders():Void
	{
		if(!ClientPrefs.data.shaders) return;
		
		// Setup glitch shader
		haltGlitch = new GlitchShader();
		haltGlitch.iMouseX = 500;
		haltGlitch.NUM_SAMPLES = 8;
		haltGlitch.glitchMultiply = 0;
		add(haltGlitch);
		var filter:ShaderFilter = new ShaderFilter(haltGlitch.shader);
		addFilterToCamera(filter);
		
		// Setup chromatic aberration shader
		haltChroma = new HaltChromaticAberration();
		haltChroma.k = 0.0;
		haltChroma.kcube = 0.0;
		haltChroma.offset = 0.0;
		add(haltChroma);
		var filter2:ShaderFilter = new ShaderFilter(haltChroma.shader);
		addFilterToCamera(filter2);
	}
	
	private function addFilterToCamera(filter:ShaderFilter):Void
	{
		game.camGameFilters.push(filter);
		game.updateCameraFilters('camGame');
		game.camHUDFilters.push(filter);
		game.updateCameraFilters('camHUD');
	}
	
	private function setupHitboxes():Void
	{
		bfHitbox = new FlxSprite(game.boyfriend.x, game.boyfriend.y)
			.makeSolid(Std.int(game.boyfriend.width - 50), Std.int(game.boyfriend.height), FlxColor.ORANGE);
		bfHitbox.alpha = 0;
		
		haltHitbox = new FlxSprite(game.dad.x + 200, game.dad.y)
			.makeSolid(Std.int(game.dad.width), Std.int(game.dad.height), FlxColor.BLUE);
		haltHitbox.alpha = 0;
		
		bfHitboxOTE = new FlxSprite(game.boyfriend.x, game.boyfriend.y)
			.makeSolid(Std.int(game.boyfriend.width*(4.5/3)), Std.int(game.boyfriend.height), FlxColor.YELLOW);
		bfHitboxOTE.alpha = 0;
		
		add(bfHitboxOTE);
		add(bfHitbox);
		add(haltHitbox);
	}

	override function updatePost(elapsed:Float)
	{
		updateHitboxPositions();
		handleSpaceBarHealth(elapsed);
		updateVignetteAndChroma(elapsed);
		handleAchievementTracking(elapsed);
	}
	
	private function updateHitboxPositions():Void
	{
		bfHitbox.x = game.boyfriend.x + 25;
		haltHitbox.x = game.dad.x + (haltState ? 170 : 150);
		bfHitboxOTE.x = game.boyfriend.x + (game.boyfriend.width - bfHitboxOTE.width)/2;
	}
	
	private function handleSpaceBarHealth(elapsed:Float):Void
	{
		if (!game.allowCountdown) return;
		
		// Health drain when space is pressed
		var healthDrainAmount:Float = storyDifficulty >= 2 ? 0.6 : 0.35;
		var minHealthForDrain:Float = 
			storyDifficulty == 0 ? 0.1 :
			storyDifficulty == 1 ? 0.05 :
			storyDifficulty == 2 ? 0.02 : 0;
			
		if (FlxG.keys.pressed.SPACE && (game.health >= minHealthForDrain || storyDifficulty == 3)) {
			game.health -= healthDrainAmount * elapsed;
		}
		
		// Death from vignette
		var deathThreshold:Float = 
			storyDifficulty == 0 ? 0.95 :
			storyDifficulty == 1 ? 0.9 :
			storyDifficulty == 2 ? 0.8 :
			storyDifficulty == 3 ? 0.6 : 0.9;
			
		if (blue_vignette.alpha >= deathThreshold && PlayState.healthLoss > 0.01) {
			game.health = -1;
		}
	}
	
	private function updateVignetteAndChroma(elapsed:Float):Void
	{
		var overlapping:Bool = haltHitbox.overlaps(bfHitbox);
		
		if (overlapping) {
			// Player is in danger zone
			var vignetteFactor:Float = DoorsUtil.modifierActive(27) ? 3.33 : 5;
			blue_vignette.alpha += elapsed/vignetteFactor;
			
			if (ClientPrefs.data.shaders) {
				haltChroma.offset = FlxMath.lerp(haltChroma.offset, 1, CoolUtil.boundTo(elapsed / 4, 0, 1));
			}
		} else {
			// Player is safe
			blue_vignette.alpha -= elapsed/8;
			
			if (ClientPrefs.data.shaders) {
				haltChroma.offset = FlxMath.lerp(haltChroma.offset, 0, CoolUtil.boundTo(elapsed / 4, 0, 1));
			}
		}
	}
	
	private function handleAchievementTracking(elapsed:Float):Void
	{
		var overlappingOTE:Bool = haltHitbox.overlaps(bfHitboxOTE);
		
		// Update animation based on overlap
		if (overlappingOTE) {
			if (haltIcon.animation.getByName("idle") == haltIcon.animation.curAnim) {
				haltIcon.animation.play("death");
			}
		} else {
			if (haltIcon.animation.getByName("death") == haltIcon.animation.curAnim) {
				haltIcon.animation.play("idle");
			}
		}
		
		// Track "On The Edge" achievement progress
		if (!AwardsManager.onTheEdge) {
			if (overlappingOTE) {
				oteTime += elapsed;
				
				if (oteTime >= 20) {
					AwardsManager.onTheEdge = true;
				}
			} else if (oteTime > 0) {
				oteTime -= elapsed * 2;
			}
		}
	}

	override function onBeatHit(curBeat:Int)
	{
		var pattern:HaltBeatPattern = haltPatterns.get(song.toLowerCase());
		if (pattern == null) return;
		
		handleHaltBeats(curBeat, pattern.leftBeats, true);
		handleHaltBeats(curBeat, pattern.rightBeats, false);
	}
	
	private function handleHaltBeats(curBeat:Int, beats:Array<Int>, isLeft:Bool):Void
	{
		for (beatNum in beats) {
			// Main halt effect
			if (curBeat == beatNum) {
				if (ClientPrefs.data.shaders) {
					haltGlitch.glitchMultiply = (storyDifficulty >= 2) ? 0.2 : 0.1;
				}
				if (isLeft) haltLeft(true) else haltRight(true);
				return;
			}
			
			// Warning effects
			if (curBeat == beatNum - 4 || curBeat == beatNum - 2) {
				if (isLeft) haltLeft() else haltRight();
				applyWarningEffects();
				return;
			} 
			
			if (curBeat == beatNum - 3 || curBeat == beatNum - 1) {
				if (isLeft) haltRight() else haltLeft(); 
				applyWarningEffects();
				return;
			}
			
			// Earlier warnings based on modifiers
			if (DoorsUtil.modifierActive(37) && curBeat == beatNum - 12) {
				applyWarningEffects();
				return;
			} else if (!DoorsUtil.modifierActive(37) && curBeat == beatNum - 8 && storyDifficulty != 3) {
				applyWarningEffects();
				return;
			}
		}
	}
	
	private function applyWarningEffects():Void
	{
		if (ClientPrefs.data.shaders) {
			haltGlitch.glitchMultiply = 0.4;
		}
		haltWarn();
	}
	
	private function haltLeft(?real:Bool = false)
	{
		haltState = false;
		haltIcon.x = 260;
		haltIcon.flipX = false;
		cancelAndFadeTurnaround();
		
		if (real) {
			applyRealHaltEffects();
			shuffleArrowsIfNeeded(false);
		}
	}
	
	private function haltRight(?real:Bool = false)
	{
		haltState = true;
		haltIcon.x = 820;
		haltIcon.flipX = true;
		cancelAndFadeTurnaround();
		
		if (real) {
			applyRealHaltEffects();
			shuffleArrowsIfNeeded(true);
		}
	}
	
	private function cancelAndFadeTurnaround():Void
	{
		FlxTween.cancelTweensOf(turnaroundbitch);
		FlxTween.tween(turnaroundbitch, {alpha: 0.00001}, 0.2, {ease: FlxEase.quintOut});
		game.enableHaltLerp = false;
	}
	
	private function applyRealHaltEffects():Void
	{
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			game.enableHaltLerp = true;
		});
	}
	
	private function shuffleArrowsIfNeeded(toLeft:Bool):Void
	{
		if (storyDifficulty <= 2 && !(DoorsUtil.modifierActive(51) && !PlayState.isStoryMode)) return;
		
		var startPos:Array<Float> = toLeft ? [92, 204, 316, 428] : [1068, 956, 844, 732];
		var angles:Array<Float> = toLeft ? [360, 360, 360, 360] : [0, 0, 0, 0];
		var delays:Array<Float> = toLeft ? [0, 0.05, 0.1, 0.15] : [0.15, 0.1, 0.05, 0];
		
		for (i in 0...4) {
			var index = toLeft ? i : 3-i;
			FlxTween.tween(
				game.playerStrums.members[index], 
				{x: startPos[i], angle: angles[i]}, 
				0.3, 
				{ease: FlxEase.quintOut, startDelay: delays[i]}
			);
		}
	}

	private function haltWarn()
	{
		FlxTween.cancelTweensOf(turnaroundbitch);
		FlxTween.tween(turnaroundbitch, {alpha: 0.8}, 0.2, {ease: FlxEase.quintOut});
		game.camGame.zoom += 0.3;
	}
}

// Helper class to store beat patterns
class HaltBeatPattern
{
	public var leftBeats:Array<Int>;
	public var rightBeats:Array<Int>;
	
	public function new(left:Array<Int>, right:Array<Int>)
	{
		leftBeats = left;
		rightBeats = right;
	}
}