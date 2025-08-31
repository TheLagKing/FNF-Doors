package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class KysState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var debugText:FlxText;
	var ipText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width + 100, FlxG.height + 100, FlxColor.BLACK);
		bg.screenCenter();
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
"You're playing an outdated version!
Please contact leetram to get a new one.

If you're playing a leaked build,
go fuck yourself.",
			24);
		warnText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.y -= 200;
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}