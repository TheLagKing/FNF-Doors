package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var VTransition:BGSprite;

	public static var finished:Bool = false;

	public function new(duration:Float, isTransIn:Bool, ?isShaky:Bool = false) {
		super();

		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);

		var scalein =  Std.int(24);

		if(isShaky){
			VTransition = new BGSprite("transitions/VTransitionShake", 0, 0, 0, 0, ["VignetteShake0"], false);
			VTransition.animation.addByPrefix("out", "VignetteShake0", scalein, false);
		} else {
			VTransition = new BGSprite("transitions/trans", 0, 0, 0, 0, ["TransitionIn_"], false);
			VTransition.animation.addByPrefix("out", "TransitionIn_", scalein, false);
		}
	
		this.isTransIn = isTransIn;

		add(VTransition);
		if(isTransIn){
			VTransition.animation.play("out",true, true, 0);
			VTransition.flipX = true;
			var timer = new FlxTimer().start(duration, function(tmr:FlxTimer) {
				close();
			}, 0);
		}
		else{
			VTransition.animation.play("out",true, false, 0);
			VTransition.flipX = false;
			var timer = new FlxTimer().start(duration, function(tmr:FlxTimer) {
				if(finishCallback != null && !finished) {
					finished=true;
					finishCallback();
				}
			}, 0);
		}

		if(isShaky){
			VTransition.scale.set(width/VTransition.width*2.7, height/VTransition.height*2.7);
		} else {
			VTransition.scale.set(width/VTransition.width, height/VTransition.height);
		}
		VTransition.updateHitbox();
		VTransition.screenCenter();

		VTransition.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		nextCamera = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function destroy()
	{
		if(finishCallback != null && !finished) {
			finished=true;
			finishCallback();
		}

		super.destroy();
	}
}