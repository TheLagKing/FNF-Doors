package substates.story;

import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class PaperSubState extends StoryModeSubState
{
	private var curSelected:Int = 0;
	private var optionsArray:Array<Dynamic> = [];

	var grid:FlxBackdrop;
	var paper:FlxSprite;

	var clickAnywhereToLeave:FlxText;

	var canLeave:Bool = true;

	public function new(n:Int)
	{
		super();
		
		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x80432004, 0x80400415));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		add(grid);

        paper = new FlxSprite().loadGraphic(Paths.image("storyPaper/paper" + n));
        paper.antialiasing = true;
        paper.screenCenter(XY);
        add(paper);

		clickAnywhereToLeave = new FlxText(0, FlxG.height * 0.9, FlxG.width, Paths.getText("newUI/clickOff"));
		clickAnywhereToLeave.antialiasing = ClientPrefs.globalAntialiasing;
		clickAnywhereToLeave.setFormat(FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		clickAnywhereToLeave.alpha = 0;
		add(clickAnywhereToLeave);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		startGaming();
		canLeave = false;
	}

	override function startGaming(){
		paper.y += FlxG.height;
		FlxTween.tween(paper, {y: paper.y - FlxG.height}, 0.6, {ease: FlxEase.quintOut, onComplete: function(twn){
			canLeave = true;
		}});
		FlxTween.tween(grid, {alpha: 1, x: grid.x + FlxG.height, y: grid.y + FlxG.height}, 0.6, {ease: FlxEase.quintOut});
		FlxTween.tween(clickAnywhereToLeave, {alpha: 0.4}, 0.6, {ease: FlxEase.quintOut, startDelay: 3.0});
	}

	override function stopGaming(){
		FlxG.sound.play(Paths.sound('cancelMenu'));
		this._parentState.persistentUpdate = true;
		StoryMenuState.canOpenState = false;
		FlxTween.tween(grid, {alpha: 0, x: grid.x + FlxG.height, y: grid.y + FlxG.height}, 0.6, {ease: FlxEase.quadIn});
		FlxTween.tween(paper, {y: paper.y + FlxG.height}, 0.6, {ease: FlxEase.quadIn, onComplete: function (twn){
			close();
			this._parentState.persistentUpdate = false;
			StoryMenuState.canOpenState = true;
		}});
		FlxTween.tween(clickAnywhereToLeave, {alpha: 0}, 0.6, {ease: FlxEase.quadIn});
	}

	override function update(elapsed:Float)
	{
		if (canLeave && (controls.BACK || FlxG.mouse.justPressed)) {
			canLeave = false;
			stopGaming();
		}

		super.update(elapsed);
	}
}