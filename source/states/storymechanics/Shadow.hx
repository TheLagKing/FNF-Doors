package states.storymechanics;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

class Shadow extends BaseSMMechanic {
	// Constants
	private static inline var REQUIRED_CLICKS:Int = 40;
	private static inline var CLICK_VARIATION:Int = 20;
	private static inline var EXTRA_CLICKS_MODIFIER:Int = 30;
	
	// Shadow elements
	private var shadowSprite:StoryModeSpriteHoverable;
	private var shadowMouse:FlxSprite;
	private var shadowParticleEmitter:FlxEmitter;
	
	// State tracking
	private var shadowHurts:Bool = false;
	private var shadowClickCounter:Int = 0;
	
	// Tweens
	private var shadowInitialTween:FlxTween;
	private var shadowMouseTween:FlxTween;
	private var shadowKillTween:FlxTween;
	private var shadowShakeTween:FlxTween;
	private var shadowKillTimer:FlxTimer;
	
	// Sound effects
	private var shadowStartSound:FlxSound;
	private var shadowHurtSound:FlxSound;
	private var shadowEndSound:FlxSound;

	override function create() { 
		initShadowSprite();
		initShadowMouse();
		initParticleEmitter();
		initSounds();
		startShadowSequence();
	}

	private function initShadowSprite():Void {
		shadowSprite = new StoryModeSpriteHoverable(0, 0, "");
		shadowSprite.cameras = [camHUD];
		shadowSprite.frames = Paths.getSparrowAtlas('story_mode_backgrounds/average 4chan user');
		shadowSprite.animation.addByPrefix("idle", "Shadow0", 24, true);
		shadowSprite.animation.play("idle");
		shadowSprite.scale.set(0.55, 0.55);
		shadowSprite.updateHitbox();
		shadowSprite.alpha = 0.000001;
		shadowSprite.screenCenter(XY);
		add(shadowSprite);
	}
	
	private function initShadowMouse():Void {
		shadowMouse = new FlxSprite();
		shadowMouse.frames = Paths.getSparrowAtlas('story_mode_backgrounds/MouseAnimation');
		shadowMouse.animation.addByPrefix('idle', 'Mouse', 12, true);
		shadowMouse.alpha = 0.00001;
		shadowMouse.cameras = [camHUD];
		shadowMouse.antialiasing = ClientPrefs.globalAntialiasing;
		shadowMouse.scale.set(0.6, 0.6);
		shadowMouse.updateHitbox();
		shadowMouse.screenCenter();
		shadowMouse.x += 50;
		shadowMouse.y += 50;
		shadowMouse.animation.play('idle', true, false);
		add(shadowMouse);
	}
	
	private function initParticleEmitter():Void {
		shadowParticleEmitter = new FlxEmitter();
		shadowParticleEmitter.makeParticles(2, 2, FlxColor.BLACK, 120);
		shadowParticleEmitter.scale.set(1, 1, 1, 1, 4, 4, 8, 8);
		shadowParticleEmitter.launchMode = SQUARE;
		shadowParticleEmitter.angle.set(-90, 90);
		shadowParticleEmitter.lifespan.set(0.1, 1);
		shadowParticleEmitter.alpha.set(0.6, 1.0, 0.0, 0.0);
		shadowParticleEmitter.color.set(FlxColor.BLACK, FlxColor.GRAY);
		shadowParticleEmitter.cameras = [camHUD];
		add(shadowParticleEmitter);
	}
	
	private function initSounds():Void {
		shadowStartSound = new FlxSound().loadEmbedded(Paths.sound("shadowStart"), false, true);
		shadowHurtSound = new FlxSound().loadEmbedded(Paths.sound("shadowHurt"), true, false);
		shadowHurtSound.volume = 0.00001;
		shadowEndSound = new FlxSound().loadEmbedded(Paths.sound("shadowEnd"), false, true);
	}
	
	private function startShadowSequence():Void {
		shadowStartSound.play();
		MenuSongManager.changeSongVolume(0.00001, 1);
		
		new FlxTimer().start(1, function(tmr){
			shadowHurts = true;
			StoryMenuState.instance.checkForSeeingDouble();
		});
		
		var prevT:Float = 0;
		shadowInitialTween = FlxTween.tween(shadowSprite, {alpha: 1}, 3, {
			ease: FlxEase.linear, 
			onComplete: function(twn) {
				startDamagePhase(prevT);
			}
		});

		shadowMouseTween = FlxTween.tween(shadowMouse, {alpha: 1}, 3);

		shadowShakeTween = FlxTween.num(0.0, 0.005, 3, {ease: FlxEase.linear}, function(f){
			camGame.shake(f, 0.0166667);
			camHUD.shake(f, 0.0166667);
		});
	}
	
	private function startDamagePhase(prevT:Float):Void {
		shadowHurtSound.play();
		FlxTween.tween(shadowStartSound, {volume: 0.0}, 3.0, {ease: FlxEase.cubeIn});
		FlxTween.tween(shadowHurtSound, {volume: 1.0}, 3.0, {ease: FlxEase.cubeIn});
		
		var damageTime:Float = 8 - ((DoorsUtil.maxHealth - health) * 3);
		camGame.shake(0.005, damageTime);
		camHUD.shake(0.005, damageTime);
		
		shadowKillTween = FlxTween.num(0.0, health, damageTime, {
			ease: FlxEase.expoIn
		}, function(t) {
			DoorsUtil.addStoryHealth(prevT - t, false);
			prevT = t;
		});
		
		shadowKillTimer = new FlxTimer().start(damageTime, function(tmr) {
			shadowHurtSound.stop();
			shadowFucksYou();
		});
	}

	private function shadowFucksYou():Void {
		StoryMenuState.instance.fuckingDie("SONG", "shadow", function(){
            DoorsUtil.curRun.revivesLeft += 1;
        });
	}

	private function stopShadow():Void {
		cleanupActiveEffects();
		
		shadowEndSound.play();
		MenuSongManager.changeSongVolume(1, 8);
		
		fadeOutShadow();
	}
	
	private function cleanupActiveEffects():Void {
		shadowStartSound.stop();
		shadowHurtSound.stop();
		camGame.shake(0.0, 0.01);
		camHUD.shake(0.0, 0.01);
		
		cancelActiveTweensAndTimers();
	}
	
	private function cancelActiveTweensAndTimers():Void {
		if (shadowInitialTween != null && shadowInitialTween.active) {
			shadowInitialTween.cancel();
		}
		if (shadowMouseTween != null && shadowMouseTween.active) {
			shadowMouseTween.cancel();
		}
		if (shadowKillTween != null && shadowKillTween.active) {
			shadowKillTween.cancel();
		}
		if (shadowKillTimer != null && shadowKillTimer.active) {
			shadowKillTimer.cancel();
		}
		if (shadowShakeTween != null && shadowShakeTween.active) {
			shadowShakeTween.cancel();
		}
	}
	
	private function fadeOutShadow():Void {
		FlxTween.tween(shadowSprite, {alpha: 0}, 2, {
			ease: FlxEase.quartOut, 
			onComplete: function(twn) {
				shadowHurts = false;
				StoryMenuState.instance.doUpdate = true;
				remove(shadowSprite);
			}
		});

		FlxTween.tween(shadowMouse, {alpha: 0}, 2, {
			ease: FlxEase.quartOut, 
			onComplete: function(twn) {
				remove(shadowMouse);
			}
		});
	}

	override function onFocusLost() {
		if (shadowStartSound != null) shadowStartSound.stop();
		if (shadowHurtSound != null) shadowHurtSound.stop();
	}

	override function onFocus() {
		if (shadowStartSound != null) shadowStartSound.resume();
		if (shadowHurtSound != null) shadowHurtSound.resume(); 
	}

	override function changeState() {
		if (shadowStartSound != null) shadowStartSound.stop();
		if (shadowHurtSound != null) shadowHurtSound.stop(); 
	}

	override function createPost() {
		// Empty implementation
	}

	override function update(elapsed:Float) { 
		if (shadowHurts) {
			StoryMenuState.instance.doUpdate = false;
			
			if (FlxG.mouse.justPressed) {
				handleShadowClick();
			}
			
			checkForVictory();
		}
	}
	
	private function handleShadowClick():Void {
		shadowClickCounter++;
		
		var mousePos = FlxG.mouse.getPositionInCameraView(camHUD);
		shadowParticleEmitter.setPosition(mousePos.x, mousePos.y);
		shadowParticleEmitter.start(true, 0.1, 40);
		
		MenuSongManager.playSoundWithRandomPitch("shadow_hit", [0.6, 1.4], 0.4);
	}
	
	private function checkForVictory():Void {
		var requiredClicks = REQUIRED_CLICKS + FlxG.random.int(-10, CLICK_VARIATION);
		
		if (DoorsUtil.modifierActive(29)) {
			requiredClicks += EXTRA_CLICKS_MODIFIER;
		}
		
		if (shadowClickCounter >= requiredClicks) {
			stopShadow();
		}
	}
}