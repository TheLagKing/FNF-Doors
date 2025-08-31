package substates.story;

import objects.ui.*;
import flixel.FlxG;

using StringTools;

class PrerunTutorialSubState extends StoryModeSubState
{
	var menuBG:DoorsMenu;
	var text:FlxText;

	var buttonHovered:Bool = false;

	public function new()
	{
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		menuBG = new DoorsMenu(300, 40, "tutorial", Lang.getText("tutorial", "newUI"));
		menuBG.closeFunction = stopGaming;
		menuBG.whileHoveringClose = function(){buttonHovered = true;}

		text = new FlxText(318, 133, 644, "", 32);
		text.setFormat(FONT, 32, 0xFFFEDEBF, CENTER);
		text.antialiasing = ClientPrefs.globalAntialiasing;
		text.text = Lang.getText("tutorial", "story");

		add(menuBG);
		add(text);

		startGaming();
	}

	override function startGaming(){
		menuBG.y += FlxG.height;
		text.y += FlxG.height;

		FlxTween.tween(menuBG, {y: menuBG.y - FlxG.height}, 0.6, {ease: FlxEase.backOut});
		FlxTween.tween(text, {y: text.y - FlxG.height}, 0.6, {ease: FlxEase.backOut});
	}

	override function stopGaming(){
		FlxTween.tween(menuBG, {y: menuBG.y + FlxG.height}, 0.6, {ease: FlxEase.backOut});
		FlxTween.tween(text, {y: text.y + FlxG.height}, 0.6, {ease: FlxEase.backOut, onComplete: function(twn){
			close();
		}});
	}

	override function update(elapsed:Float)
	{
		buttonHovered = false;

		super.update(elapsed);

		if(buttonHovered) theMouse.currentAction = POINTING;
		else theMouse.currentAction = NONE;
	}
}