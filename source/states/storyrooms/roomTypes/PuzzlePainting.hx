package states.storyrooms.roomTypes;

import openfl.utils.Assets;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
import flixel.FlxSubState;

using flixel.util.FlxSpriteUtil;

class PuzzlePainting extends BaseSMRoom {
	public var availableShapes:Map<String, Array<String>> = [
		"big" => ["circle", "los", "octo", "square"],
		"small" => ["circle", "los", "octo", "square"]
	];

	var bg:FlxSprite;
	var fire:FlxSprite;
	var leftBg:FlxSprite;
	var rightBg:FlxSprite;

	var leftSelector:StoryModeSpriteHoverable;
	var rightSelector:StoryModeSpriteHoverable;

	var currentPanel:Int = 1;
	public var heldPainting:Null<DoorsPainting>;
	public var heldLerpPoint:FlxPoint;
	public var heldLerpAngle:Float;
	
	var currentPaiDisposition:Array<Null<DoorsPainting>> = [];
	var wantedPaiDisposition:Array<PaintingOutline> = [];

	public static var instance:PuzzlePainting;

	var isCorrect:Bool = false;

    override function create() { 
		instance = this;
        drawPuzzleRooms();
		drawAdditionalUI();
		drawPaintings();
    }

	private function drawPuzzleRooms(){
		Paths.image("story_mode_backgrounds/puzzle_painting/opened");

		bg = new FlxSprite().loadGraphic(Paths.image("story_mode_backgrounds/puzzle_painting/fireplace"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		fire = new FlxSprite();
		fire.frames = Paths.getSparrowAtlas("story_mode_backgrounds/puzzle_painting/fire");
		fire.scale.set(0.272, 0.272);
		fire.updateHitbox();
		fire.setPosition(695, 646);
		fire.antialiasing = ClientPrefs.globalAntialiasing;
		fire.animation.addByPrefix("idle", "Fire/FireForPaintingRoom_", 24, true);
		fire.animation.play("idle");

		leftBg = new FlxSprite(-1920).loadGraphic(Paths.image("story_mode_backgrounds/puzzle_painting/left"));
		leftBg.antialiasing = ClientPrefs.globalAntialiasing;

		rightBg = new FlxSprite(1920).loadGraphic(Paths.image("story_mode_backgrounds/puzzle_painting/right"));
		rightBg.antialiasing = ClientPrefs.globalAntialiasing;

		add(bg);
		add(fire);
		add(leftBg);
		add(rightBg);

		currentPanel = 1;
	}

	function drawAdditionalUI(){
		rightSelector = new StoryModeSpriteHoverable(0, 0, "story_mode_backgrounds/puzzle_painting/rightSelector");
		rightSelector.flipX = false;
		rightSelector.cameras = [camHUD];
		rightSelector.setPosition(1190, 314);

		leftSelector = new StoryModeSpriteHoverable(0, 0, "story_mode_backgrounds/puzzle_painting/rightSelector");
		leftSelector.flipX = true;
		leftSelector.cameras = [camHUD];
		leftSelector.setPosition(31, 314);

		add(rightSelector);
		add(leftSelector);
	}

	function drawPaintings(){
		var currentStrDisposition:Array<String> = [];
		var wantedStrDisposition:Array<String> = [];
		for(i in 1...5){
			var arr1:Array<String> = [];
			var arr2:Array<Array<String>> = [];
			for(key in availableShapes.keys()){
				arr1.push(key);
				arr2.push(availableShapes.get(key));
			}
			var chosenSize = FlxG.random.getObject(arr1);
			var chosenShape = FlxG.random.getObject(arr2[arr1.indexOf(chosenSize)]);
			var paint = new DoorsPainting(i, chosenSize, chosenShape);
			add(paint);
			currentStrDisposition.push(chosenSize+"_"+chosenShape);
			currentPaiDisposition.push(paint);

			var arr = availableShapes.get(chosenSize);
			arr.remove(chosenShape);
			availableShapes.set(chosenSize, arr);
		}
		wantedStrDisposition = currentStrDisposition.copy();
		FlxG.random.shuffle(wantedStrDisposition);
		
		var arraysMatch = true;
		while(arraysMatch) {
			FlxG.random.shuffle(wantedStrDisposition);
			
			arraysMatch = true;
			for(i in 0...wantedStrDisposition.length) {
				if(wantedStrDisposition[i] != currentStrDisposition[i]) {
					arraysMatch = false;
					break;
				}
			}
		}
		for(i in 1...wantedStrDisposition.length+1){
			var splitted = wantedStrDisposition[i-1].split("_");
			var chosenSize = splitted[0];
			var chosenShape = splitted[1];
			var outline = new PaintingOutline(i, chosenSize, chosenShape);
			add(outline);
			wantedPaiDisposition.push(outline);
		}

		emptyHB = cast new StoryModeSpriteHoverable(0,0,"").makeGraphic(1,1,FlxColor.TRANSPARENT);
		add(emptyHB);
	}

	var emptyHB:StoryModeSpriteHoverable;
	var initCorrect:Bool = false;
    override function update(elapsed:Float) { 
		if(!isCorrect){
			leftSelector.checkOverlap(camHUD);
			rightSelector.checkOverlap(camHUD);
	
			if(leftSelector.isHovered && FlxG.mouse.justPressed) changePanel(-1);
			else if(rightSelector.isHovered && FlxG.mouse.justPressed) changePanel(1);
	
			var topLeft:FlxPoint = new FlxPoint(0,0);
			for(i in 0...currentPaiDisposition.length){
				if(currentPaiDisposition[i] == null){
					switch(i+1){
						case 1: topLeft = new FlxPoint(-1819, 100);
						case 2: topLeft = new FlxPoint(-884, 100);
						case 3: topLeft = new FlxPoint(2171, 100);
						case 4: topLeft = new FlxPoint(3106, 100);
					}
		
					emptyHB.scale.set(617, 756);
					emptyHB.updateHitbox();
					emptyHB.setPosition(topLeft.x, topLeft.y);
					break;
				}
				emptyHB.scale.set(1, 1);
				emptyHB.updateHitbox();
				emptyHB.setPosition(0, 1090);
			}
	
			emptyHB.checkOverlap(camGame);
			if(emptyHB.isHovered && FlxG.mouse.justPressed){
				StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
					for(i in 0...currentPaiDisposition.length){
						if(currentPaiDisposition[i] == null) PuzzlePainting.instance.putPaintingDown(i+1);
					}
				});
			}

			if(heldPainting != null){
				heldPainting.y = FlxMath.lerp(heldPainting.y, heldLerpPoint.y, CoolUtil.boundTo(elapsed * 6, 0, 1));
				heldPainting.x = FlxMath.lerp(heldPainting.x, heldLerpPoint.x, CoolUtil.boundTo(elapsed * 8, 0, 1));
			}
		} else {
			if(!initCorrect){
				initCorrect = true;
				if(currentPanel == 0) changePanel(1);
				else if(currentPanel == 2) changePanel(-1);

				FlxTween.tween(leftSelector, {alpha: 0}, 0.5);
				FlxTween.tween(rightSelector, {alpha: 0}, 0.5);
				
				remove(fire);
				bg.loadGraphic(Paths.image("story_mode_backgrounds/puzzle_painting/opened"));
				var doorHitbox:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(812, 377, "").makeGraphic(297, 539, FlxColor.TRANSPARENT);
				add(doorHitbox);
				var txtDoorNumber1 = new FlxText(doorHitbox.x + 114, doorHitbox.y + 94, 0, "", 64);
				txtDoorNumber1.text = Std.string(door+1);
				if(Std.parseInt(txtDoorNumber1.text) < 10){
					txtDoorNumber1.text = "0" + Std.string(door+1);
				}
				txtDoorNumber1.setFormat(FONT, 64, FlxColor.BLACK, CENTER);
				txtDoorNumber1.antialiasing = ClientPrefs.globalAntialiasing;
				txtDoorNumber1.color = FlxColor.BLACK;
				add(txtDoorNumber1);
				doors.push({
					song: "None",
					side: "left",
					doorNumber: door+1,
					doorSpr: doorHitbox,
					isLocked: false
				});
			}
		}

		isCorrect = checkIfCorrect();

		super.update(elapsed);
    }

	function changePanel(change:Int){
		currentPanel += change;
		currentPanel = Math.floor(FlxMath.bound(currentPanel, 0, 2));

		switch(currentPanel){
			case 0: 
				game.initialCameraPosition.set(-940, game.initialCameraPosition.y);
				rightSelector.visible = true;
				leftSelector.visible = false;
			case 1:	
				game.initialCameraPosition.set(960, game.initialCameraPosition.y);
				rightSelector.visible = true;
				leftSelector.visible = true;
			case 2:	
				game.initialCameraPosition.set(2840, game.initialCameraPosition.y);
				rightSelector.visible = false;
				leftSelector.visible = true;
		}
	}

	public function pickupPainting(painting:DoorsPainting){
		if(currentPanel == 1) return;
		
		if(heldPainting != null) {
			heldPainting.spot = painting.spot;
			putPaintingDown(painting.spot);
			heldPainting = painting;
			heldPainting.angle = 30;
			heldPainting.cameras = [camHUD];
			heldPainting.screenCenter();
			heldPainting.y += 300;
			heldLerpPoint = new FlxPoint(heldPainting.x, heldPainting.y);
			heldPainting.y -= 30;
			heldPainting.spot = 0;
		} else {
			heldPainting = painting;
			heldPainting.angle = 30;
			heldPainting.cameras = [camHUD];
			heldPainting.screenCenter();
			heldPainting.y += 300;
			heldLerpPoint = new FlxPoint(heldPainting.x, heldPainting.y);
			heldPainting.y -= 30;
			currentPaiDisposition[painting.spot-1] = null;
			heldPainting.spot = 0;
		}
	}

	public function putPaintingDown(spot:Int){
		currentPaiDisposition[spot-1] = heldPainting;
		currentPaiDisposition[spot-1].spot = spot;
		currentPaiDisposition[spot-1].angle = 0;
		currentPaiDisposition[spot-1].cameras = [camGame];
		var topLeft:FlxPoint = new FlxPoint(0,0);
		switch(spot){
			case 1: topLeft = new FlxPoint(-1819, 100);
			case 2: topLeft = new FlxPoint(-884, 100);
			case 3: topLeft = new FlxPoint(2171, 100);
			case 4: topLeft = new FlxPoint(3106, 100);
		}
		currentPaiDisposition[spot-1].setPosition(topLeft.x, topLeft.y);

		currentPaiDisposition.sort(function(a, b){
			if(a == null) return 0;
			if(b == null) return 0;
			if (a.x < b.x)
				return -1;
			else
				return 1;
		});
		heldPainting = null;
	}

	function checkIfCorrect(){
		for(i in 0...currentPaiDisposition.length){
			if(currentPaiDisposition[i] == null) return false;
			if(currentPaiDisposition[i].size != wantedPaiDisposition[i].size 
				|| currentPaiDisposition[i].shape != wantedPaiDisposition[i].shape){
				return false;
			}
		}
		return true;
	}
    
    override function beatHit(curBeat:Int) { 
		
    }

    override function onHandleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float){
		
    }
}

class DoorsPainting extends FlxSpriteGroup {
	var bigPaint = ["drown", "sans", "nmi", "madness", "formations", "waiting"];
	var smallPaint = ["gray", "swmg", "losthat", "recognisable", "streetlight"];

	// 0 = held, 1-4 = down
	public var spot:Int = 0;

	var paintingFrame:StoryModeSpriteHoverable;

	public var size:String;
	public var shape:String;

	public function new(position:Int, size:String, shape:String){
		this.size = size;
		this.shape = shape;
		this.spot = position;
		var topLeft:FlxPoint = new FlxPoint(0,0);
		switch(position){
			case 1: topLeft = new FlxPoint(-1819, 100);
			case 2: topLeft = new FlxPoint(-884, 100);
			case 3: topLeft = new FlxPoint(2171, 100);
			case 4: topLeft = new FlxPoint(3106, 100);
		}
		super(topLeft.x,topLeft.y);

		paintingFrame = new StoryModeSpriteHoverable(0, 0, 
			'story_mode_backgrounds/puzzle_painting/paintings/frame_${size}_${shape}'
		);

		var chosenPaint:String = FlxG.random.getObject(size == "big" ? bigPaint : smallPaint);
		(size == "big" ? bigPaint : smallPaint).remove(chosenPaint);

		var paintingTexture = new FlxSprite(0,0).loadGraphic(
			Assets.getBitmapData(Paths.getPreloadPath('images/story_mode_backgrounds/puzzle_painting/paintings/p_${size}/${chosenPaint}.png')), false, 0, 0, true, '${chosenPaint}${FlxG.random.currentSeed}');
		var mask = new FlxSprite(0,0).loadGraphic(
			Assets.getBitmapData(Paths.getPreloadPath('images/story_mode_backgrounds/puzzle_painting/paintings/masks/frame_${size}_${shape}.png')), false, 0, 0, true, '${FlxG.random.currentSeed}${shape}${size}');
		
		var theActualPainting = new FlxSprite(0,0);
		
		paintingTexture.drawFrame();
		var data:BitmapData = paintingTexture.pixels.clone();
		data.copyChannel(mask.pixels, new Rectangle(0, 0, paintingTexture.width, paintingTexture.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
	
		theActualPainting.pixels = data;

		//FlxSpriteUtil.alphaMaskFlxSprite(paintingTexture, mask, theActualPainting);
		add(theActualPainting);
		add(paintingFrame);

		forEach(function(spr){
			spr.scale.set(0.7,0.7);
			spr.updateHitbox();
			spr.antialiasing = ClientPrefs.globalAntialiasing;
		});
	}
	
	override function update(elapsed:Float){
		paintingFrame.checkOverlap(PuzzlePainting.instance.camGame);
		if(paintingFrame.isHovered && FlxG.mouse.justPressed){
			StoryMenuState.instance.theMouse.startLongAction(0.5, function(){
				PuzzlePainting.instance.pickupPainting(this);
			});
		}

		super.update(elapsed);
	}

    override function toString(){
        return (paintingFrame.name.replace("story_mode_backgrounds/puzzle_painting/paintings/frame_", "") + " | x: "+this.x + " | y: "+this.y);
    }
}

class PaintingOutline extends FlxSpriteGroup {
	public var outlineVisible:Bool = true;

	public var size:String;
	public var shape:String;

	public function new(position:Int, size:String, shape:String){
		this.size = size;
		this.shape = shape;
		var topLeft:FlxPoint = new FlxPoint(0,0);
		switch(position){
			case 1: topLeft = new FlxPoint(-1819, 100);
			case 2: topLeft = new FlxPoint(-884, 100);
			case 3: topLeft = new FlxPoint(2171, 100);
			case 4: topLeft = new FlxPoint(3106, 100);
		}
		super(topLeft.x,topLeft.y);

		var outline = new StoryModeSpriteHoverable(0, 0, 
							'story_mode_backgrounds/puzzle_painting/paintings/outline_${size}_${shape}'
							);
		add(outline);

		forEach(function(spr){
			spr.alpha = 0.5;
			spr.scale.set(0.7,0.7);
			spr.updateHitbox();
			spr.antialiasing = ClientPrefs.globalAntialiasing;
		});
	}

	var curTime:Float = 0.0;
	override function update(elapsed:Float){
		if(outlineVisible){
			forEach(function(spr){
				spr.alpha = 0.5 + (FlxMath.fastSin(curTime) - 0.5)/6;
			});
			curTime += elapsed;
		} else {
			forEach(function(spr) {if(spr.alpha > 0) spr.alpha -= elapsed / 6;});
		}
		super.update(elapsed);
	}
}