package objects;

import flixel.util.FlxDestroyUtil;
import flxanimate.FlxAnimate;
import animateatlas.AtlasFrameMaker;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var extraImages:Array<String>;
	var attachChars:String;
	var attachCharOffset:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
    public var justHovered:Bool = false;
    public var isHovered:Bool = false;
	
	public var attachChar:Character;
	public var attachOffset = {x:0, y:0};
	
	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.isPlaying;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		if(!isAnimateAtlas) animation.curAnim.paused = value;
		else
		{
			if(value) atlas.anim.pause();
			else atlas.anim.play();
		} 

		return value;
	}

	override function set_alpha(setInput:Float):Float{
		super.set_alpha(setInput);
		if(attachChar!=null)
			attachChar.alpha = alpha;
		return setInput;
	}

	override function set_x(setInput:Float):Float{
		super.set_x(setInput);
		if(attachChar!=null)
			attachChar.x= x + this.attachOffset.x;
		return setInput;
	}
	
	override function set_y(setInput:Float):Float{
		super.set_y(setInput);
		if(attachChar!=null)
			attachChar.y= y + this.attachOffset.y;
		return setInput;
	}

	public var isAttached:Bool;
	
	public function attachCharacter(input:Character){
		attachChar   = input;
		attachChar.x = this.x;
		attachChar.y = this.y;
	}

	public var isAnimateAtlas:Bool;
	
	public var mostRecentRow:Int = 0;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose

	public var idleSuffix:String = '';
	public var bfEmotion:String = ""; //null or ["" / "worried" / "scared"]

	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var hasMissAnimations:Bool = false;

	public var ghostSpritePool:FlxTypedGroup<Character>;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;
	
	public var extraImages:Array<String> = [];
	public var extraTypes:Array<String> = [];
	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	
	//lol thx again neo. Modifying this solution a little
	function addFrames(otherFrames:FlxFramesCollection, reload:Bool = true) {
        if(otherFrames == null) return;

        for(frame in otherFrames.frames) {
            this.frames.pushFrame(frame);
        }

        if(reload) {
            this.frames = this.frames;
        }
    }
	
	function getFrames(imageName:String, ?setImageFile:Bool=true):FlxFramesCollection
	{
		var returnFrames:FlxFramesCollection;
		returnFrames = Paths.getSparrowAtlas(imageName);

		if(setImageFile){
			imageFile = imageName;
		}
		return returnFrames;
	}

	public static function getCharacterPath(character:String = 'bf'){
		if(character == "hide_gf") return "";
		if(character == "hide_bf") return "";

		var characterPath:String = 'characters/' + character + '.json';

		var path:String = Paths.getPreloadPath(characterPath);
		if (!Assets.exists(path))
		{
			path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
		}
		
		var rawJson = Assets.getText(path);
		var json:CharacterFile = cast Json.parse(rawJson);
		var imageFile = json.image;

		return imageFile;
	}

	public function new(x:Float, y:Float, ?character:String = 'bf', 
		?isPlayer:Bool = false, ?isAttachment:Bool = false, ?forceAtlas:Bool = false,
		?isGhost:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':
			case "hide_gf" | "gf":
				makeGraphic(1, 1, 0x01000000);
			case "hide_bf":
				makeGraphic(1, 1, 0x01000000);
			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				var rawJson = Assets.getText(path);

				var json:CharacterFile = cast Json.parse(rawJson);

				loadCharacterFile(json, isAttachment, forceAtlas, isGhost);
				
				if(!isGhost){
					ghostSpritePool = new FlxTypedGroup<Character>();
					for(i in 0...10){
						playGhostAnim("idle", 0, false, true);
					} 
				}
		}

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance("recalc");
	}	

	public function loadCharacterFile(json:Dynamic, ?isAttachment:Bool = false, ?forceAtlas:Bool = false, ?isGhost:Bool = false) {
		isAnimateAtlas = false;

		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT, null);
		if (Assets.exists(animToFind))
			isAnimateAtlas = true;
		
		scale.set(1, 1);
		updateHitbox();
		
		if(!isAnimateAtlas)
			frames = Paths.getAtlas(json.image);
		else
		{
			atlas = new FlxAnimate();
			atlas.showPivot = false;
			try
			{
				Paths.loadAnimateAtlas(atlas, json.image);
			}
			catch(e:Dynamic)
			{
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
			}
		}

		imageFile = json.image;
		if(!forceAtlas) frames = getFrames(json.image);
		if(json.extraImages != null) {
			var images:Array<String> = cast json.extraImages;
			extraImages = images;
			for (image in images) {
				addFrames(getFrames(image));
			}
		}

		this.isAttached = isAttachment;

		if(json.attachChars !=null && !isAttachment){
			trace(json.attachCharOffset);
			if(json.attachCharOffset !=null && !isAttachment && json.attachCharOffset.length > 1){
				this.attachOffset.x = json.attachCharOffset[0];
				this.attachOffset.y = json.attachCharOffset[1];
				trace(this.attachOffset);
			}
			this.attachChar = new Character(this.x,this.y,json.attachChars, false, true);

			//Reset character position stuff
			this.x =this.x +0;
			this.y =this.y +0;
		}

		jsonScale = json.scale;
		if(json.scale != 1) {
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}

		positionArray = json.position;
		cameraPosition = json.camera_position;

		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		if(isGhost) singDuration = 999;
		flipX = !!json.flip_x;
		if(json.no_antialiasing) {
			antialiasing = false;
			noAntialiasing = true;
		}

		if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
			healthColorArray = json.healthbar_colors;

		antialiasing = !noAntialiasing;
		if(!ClientPrefs.globalAntialiasing) antialiasing = false;

		animationsArray = json.animations;
		if(animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(!isAnimateAtlas)
					{
						if(animIndices != null && animIndices.length > 0)
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						else
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
					}
				else
					{
						if(animIndices != null && animIndices.length > 0)
							atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
						else
							atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
					}

				if(anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else addOffset(anim.anim, 0, 0);
			}
		} else {
			quickAnimAdd('idle', 'BF idle dance');
		}
		originalFlipX = flipX;
		

		if (isPlayer)
			{
				flipX = !flipX;
			}
			
		if(isAnimateAtlas) copyAtlasValues();
	}

	function ghostCharFactory() {
		var ghostSprite = new Character(x,y,curCharacter,isPlayer, false, isAnimateAtlas, true);
		return ghostSprite;
	}

	override function update(elapsed:Float)
	{
		if(isAnimateAtlas){
			atlas.update(elapsed);
		} 

		if(debugMode || (!isAnimateAtlas && animation.curAnim == null) || (isAnimateAtlas && atlas.anim.curSymbol == null))
			{
				super.update(elapsed);
				return;
			}	

		if(heyTimer > 0)
			{
				var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
				heyTimer -= elapsed * rate;
				if(heyTimer <= 0)
				{
					var anim:String = getAnimationName();
					if(specialAnim && (anim == 'hey' || anim == 'cheer'))
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			}
		else if(specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (getAnimationName().endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}

		if (getAnimationName().startsWith('sing')) holdTimer += elapsed;
		else if(isPlayer) holdTimer = 0;

		if (!isPlayer && holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();
		if(isAnimationFinished() && animOffsets.exists('$name-loop'))
			playAnim('$name-loop');

		super.update(elapsed);
	}

	public var danced:Bool = false;
	public function dance(?fromFunction:String)
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + bfEmotion + idleSuffix);
				else
					playAnim('danceLeft' + bfEmotion + idleSuffix);
			}
			else if(animOffsets.exists('idle' + bfEmotion + idleSuffix)) {
				playAnim('idle' + bfEmotion + idleSuffix);
			}
		}
	}

	public function isAnimationFinished():Bool
		{
			if(isAnimationNull()) return false;
			return !isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
		}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, ?Special:Bool = false, ?parentXOff:Float = 0, ?parentYOff:Float =0):Void
	{
		specialAnim = Special;
		if(this.isAttached){
			updateHitbox();
		}

		if(!isAnimateAtlas) animation.play(AnimName, Force, Reversed, Frame);
		else atlas.anim.play(AnimName, Force, Reversed, Frame);
		var daOffset = animOffsets.get(AnimName);
		
		if(attachChar !=null && attachChar.animation!=null ){
			attachChar.playAnim(AnimName, Force, Reversed, Frame, daOffset[0], daOffset[1]);
		}
		
		if (animOffsets.exists(AnimName))
		{
			if(this.isAttached){
				updateHitbox();
				offset.set(daOffset[0]+parentXOff, daOffset[1]+parentYOff);
			}
			else{
				offset.set(daOffset[0], daOffset[1]);
			}
		}
		else{
			if(this.isAttached){
				updateHitbox();
			}
			offset.set(-parentXOff, -parentYOff);
		}
	}

	public function playGhostAnim(animToPlay:String, noteData:Int, ?isPopoff:Bool = false, ?isPreload:Bool = false){
		if(curCharacter == "mg_screech" || curCharacter == "hide_bf" || curCharacter == "hide_gf") return;
		if(Type.getClassName(Type.getClass(FlxG.state)).split(".").pop() != "PlayState") return;

		var ghost = ghostSpritePool.recycle(Character, ghostCharFactory, true, true);
		if(isPreload) {
			ghost.kill();
			return;
		}

		if(!PlayState.instance.members.contains(ghostSpritePool))
			PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.dadGroup), ghostSpritePool);
		
		if(!isPopoff) PlayState.instance.camHUD.zoom += 0.03;
		PlayState.instance.camGame.zoom += 0.015;

		ghost.setColorTransform(
			colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier,
			Std.int(colorTransform.redOffset), Std.int(colorTransform.greenOffset), 
			Std.int(colorTransform.blueOffset), Std.int(colorTransform.alphaOffset)
		);
		ghost.updateColorTransform();

		ghost.setPosition(x, y);
		ghost.playAnim(animToPlay, true);
		ghost.holdTimer = 0;
		ghost.alpha = FlxMath.bound(alpha - 0.2, 0, 1);
		ghost.visible = visible;
		ghost.color = color;
		
		var xAdditionGhost:Float = 0.0;
		var yAdditionGhost:Float = 0.0;
		switch(noteData){
			case 0:
				xAdditionGhost = -30.0;
			case 1:
				yAdditionGhost = 30.0;
			case 2:
				yAdditionGhost = -30.0;
			case 3:
				xAdditionGhost = 30.0;
		}

		
		FlxTween.tween(ghost, {
			alpha: 0, 
			x: ghost.x + xAdditionGhost + (isPopoff ? FlxG.random.int(-60, 60) : FlxG.random.int(-10, 10)),
			y: ghost.y + yAdditionGhost + (isPopoff ? FlxG.random.int(-60, 60) : FlxG.random.int(-10, 10)),
		}, Conductor.crochet / 1000 * 3, {ease: FlxEase.linear, onComplete: function(twn){
			ghost.kill();
		}});
	}

	inline public function isAnimationNull():Bool
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curSymbol == null);

	public function finishAnimation():Void
		{
			if(isAnimationNull()) return;
	
			if(!isAnimateAtlas) animation.curAnim.finish();
			else atlas.anim.curFrame = atlas.anim.length - 1;
		}

	inline public function getAnimationName():String
		{
			var name:String = '';
			@:privateAccess
			if(!isAnimationNull()) name = !isAnimateAtlas ? animation.curAnim.name : atlas.anim.lastPlayedAnim;
			return (name != null) ? name : '';
		}
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + bfEmotion + idleSuffix) != null && animation.getByName('danceRight' + bfEmotion + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
	
	public function destroyAtlas()
		{
			if (atlas != null)
				atlas = FlxDestroyUtil.destroy(atlas);
		}

	public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        if  ((this.x + this.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + this.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            isHovered = false;
        }
    }

	// Atlas support
	// special thanks ne_eo & shadowmario for the references, you're the goat!!
	public var atlas:FlxAnimate;
	public override function draw()
	{
		if(isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		super.draw();
	}

	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}

	public override function destroy()
	{
		super.destroy();
		destroyAtlas();
	}
}
