package objects;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class StrumNote extends FlxSpriteGroup
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;

	public var hasBackgroundStrumLine:Bool = true;
	private var backgroundStrumline:FlxSprite;
	
	public var isPlayerStrum:Bool = true;

	private var player:Int;
	
	public var strumSprite:FlxSkewedSprite;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int, ?isP1Strum:Int = 1, ?hasBgStrumline:Bool = true) {
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.hasBackgroundStrumLine = hasBgStrumline;
		super(x, y);

		strumSprite = new FlxSkewedSprite(0, 0);
		
		if(hasBackgroundStrumLine){
			backgroundStrumline = new FlxSprite(-2, -FlxG.height*2);
			add(backgroundStrumline);
		}
		
		add(strumSprite);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(strumSprite.animation.curAnim != null) lastAnim = strumSprite.animation.curAnim.name;

		strumSprite.frames = Paths.getSparrowAtlas('notes/' + texture);
		strumSprite.animation.addByPrefix('green', 'arrowUP');
		strumSprite.animation.addByPrefix('blue', 'arrowDOWN');
		strumSprite.animation.addByPrefix('purple', 'arrowLEFT');
		strumSprite.animation.addByPrefix('red', 'arrowRIGHT');

		strumSprite.antialiasing = ClientPrefs.globalAntialiasing;
		strumSprite.setGraphicSize(Std.int(strumSprite.width * 0.7));


		switch (Math.abs(noteData) % 4)
		{
			case 0:
				strumSprite.animation.addByPrefix('static', 'arrowLEFT');
				strumSprite.animation.addByPrefix('pressed', 'left press', 24, false);
				strumSprite.animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				strumSprite.animation.addByPrefix('static', 'arrowDOWN');
				strumSprite.animation.addByPrefix('pressed', 'down press', 24, false);
				strumSprite.animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				strumSprite.animation.addByPrefix('static', 'arrowUP');
				strumSprite.animation.addByPrefix('pressed', 'up press', 24, false);
				strumSprite.animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				strumSprite.animation.addByPrefix('static', 'arrowRIGHT');
				strumSprite.animation.addByPrefix('pressed', 'right press', 24, false);
				strumSprite.animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		strumSprite.updateHitbox();

		if(hasBackgroundStrumLine){
			backgroundStrumline.makeGraphic(Math.round(strumSprite.width) + 3, Std.int(FlxG.height)*4, 0xFF000000);
			backgroundStrumline.alpha = ClientPrefs.data.strumlineBackgroundOpacity * strumSprite.alpha;
		}

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}

		// the weird number is the basic scale of the strum sprite, and this formula gives me 1.1 if it's 10% bigger, and 0.9 if 10% smaller.
		
		if(hasBackgroundStrumLine){
			backgroundStrumline.scale.set((strumSprite.scale.x / 0.694267515923567), 1);
			backgroundStrumline.updateHitbox();
			backgroundStrumline.alpha = ClientPrefs.data.strumlineBackgroundOpacity * strumSprite.alpha;
		}
		
		if(strumSprite.animation.curAnim != null && strumSprite.animation.curAnim.name == 'confirm') {
			strumSprite.centerOrigin();
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		strumSprite.animation.play(anim, force);
		strumSprite.centerOffsets();
		strumSprite.centerOrigin();
	}
}


class VortexStrumNote extends FlxSkewedSprite
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	
	public var isPlayerStrum:Bool = true;

	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int, ?isP1Strum:Int = 1) {
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		frames = Paths.getSparrowAtlas('notes/' + texture);
		animation.addByPrefix('green', 'arrowUP');
		animation.addByPrefix('blue', 'arrowDOWN');
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('red', 'arrowRIGHT');

		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(width * 0.7));

		switch (Math.abs(noteData) % 4)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if(animation.curAnim.name == 'confirm') {
			centerOrigin();
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
	}
}
