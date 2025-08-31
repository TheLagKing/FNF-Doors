package substates;

import objects.ui.*;
import flixel.FlxG;

using StringTools;

class DonationSubState extends MusicBeatSubstate
{
	var menuBG:DoorsMenu;
	var text:FlxText;
	var donateButton:DoorsButton;

	var buttonHovered:Bool = false;

	public function new()
	{
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		menuBG = new DoorsMenu(300, 40, "tutorial", Lang.getText("donateMenu", "newUI"));
		menuBG.closeFunction = stopGaming;
		menuBG.whileHoveringClose = function(){buttonHovered = true;}

		text = new FlxText(25, 105, 631, "", 36);
		text.setFormat(FONT, 36, 0xFFFEDEBF, LEFT, OUTLINE, 0xFF452D25);
		text.borderSize = 2;
		text.antialiasing = ClientPrefs.globalAntialiasing;
		text.text = Lang.getText("donateMenuText", "newUI");

		donateButton = new DoorsButton(186, 552, Lang.getText("donateKofi", "newUI"), LARGE, NORMAL);
		donateButton.whileHovered = function(){buttonHovered = true;}
		donateButton.whenClicked = function(){
			CoolUtil.browserLoad('https://ko-fi.com/glasshatstudios');
		}

		add(menuBG);
		menuBG.add(text);
		menuBG.add(donateButton);

		startGaming();
	}

	private function startGaming(){
		menuBG.y += FlxG.height;

		FlxTween.tween(menuBG, {y: menuBG.y - FlxG.height}, 0.6, {ease: FlxEase.backOut});
	}

	private function stopGaming(){
		FlxTween.tween(menuBG, {y: menuBG.y + FlxG.height}, 0.6, {ease: FlxEase.backOut, onComplete: function(twn){
			close();
		}});
	}

	override function update(elapsed:Float)
	{
		buttonHovered = false;
		
		if(controls.BACK){
			stopGaming();
		}
		else if (controls.ACCEPT){
			CoolUtil.browserLoad('https://ko-fi.com/glasshatstudios');
		}

		super.update(elapsed);

		if(buttonHovered) theMouse.currentAction = POINTING;
		else theMouse.currentAction = NONE;
	}
}