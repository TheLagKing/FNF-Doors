package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class SustainSplash extends FlxSprite
{
	public static var startCrochet:Float;
	public static var frameRate:Int;

	public var destroyTimer:FlxTimer;

	public function new():Void
	{
		super();

		frames = Paths.getSparrowAtlas('holdSplashes');
		animation.addByPrefix("hold0", "holdCoverPurple", frameRate, true);
		animation.addByPrefix("hold1", "holdCoverBlue", frameRate, true);
		animation.addByPrefix("hold2", "holdCoverGreen", frameRate, true);
		animation.addByPrefix("hold3", "holdCoverRed", frameRate, true);
		animation.addByPrefix("holdEnd0", "holdCoverEndPurple", 24, false);
		animation.addByPrefix("holdEnd1", "holdCoverEndBlue", 24, false);
		animation.addByPrefix("holdEnd2", "holdCoverEndGreen", 24, false);
		animation.addByPrefix("holdEnd3", "holdCoverEndRed", 24, false);

		destroyTimer = new FlxTimer();
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupSusSplash(strum:StrumNote, daNote:Note, note:Int = 0, playbackRate:Float = 1):Void
	{
		scale.set(0.8, 0.8);

		final lengthToGet:Int = !daNote.isSustainNote ? daNote.tail.length : daNote.parent.tail.length;
		final timeToGet:Float = !daNote.isSustainNote ? daNote.strumTime : daNote.parent.strumTime;
		final timeThingy:Float = (startCrochet * lengthToGet + (timeToGet - Conductor.songPosition)) / playbackRate * .001;

		var tailEnd:Note = !daNote.isSustainNote ? daNote.tail[daNote.tail.length - 1] : daNote.parent.tail[daNote.parent.tail.length - 1];

		tailEnd.extraData['holdSplash'] = this;

		clipRect = new flixel.math.FlxRect(0, 0, frameWidth, frameHeight);

		setPosition(strum.x, strum.y - 10);
		offset.set(106.25, 100);

		animation.play('hold$note', true, false, 0);
		destroyTimer.start(timeThingy, (idk:FlxTimer) ->
		{
			if (tailEnd.mustPress && !(daNote.isSustainNote ? daNote.noteSplashDisabled : daNote.noteSplashDisabled))
			{
        		alpha = ClientPrefs.data.splashAlpha;
				animation.play('holdEnd$note', true, false, 0);
				clipRect = null;
				animation.finishCallback = (idkEither:Dynamic) ->
				{
					die(tailEnd);
				}
				return;
			}
			die(tailEnd);
		});
	}

	public function die(?end:Note = null):Void
	{
		kill();
		super.kill();
		if (FlxG.state is PlayState)
		{
			PlayState.instance.grpHoldSplashes.remove(this);
		}
		destroy();
		super.destroy();
		if (end != null)
		{
			end.extraData['holdSplash'] = null;
		}
	}
}
