package states.stages;

import shaders.Fisheye;
import openfl.filters.ShaderFilter;
import shaders.GlitchCorruption;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class MG extends BaseStage
{
	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["mg/mg-screech", "abuge_bg", "mg/Cellphone",
						"mg/phoneBlack"]
		];

		return theMap;
	}

	var glitchCorruptionShader:GlitchCorruption;
	var fisheye:Fisheye;

	var phone:FlxSprite;
	var phoneInnerBlack:FlxSprite;
	var phoneBlack:FlxSprite;

	override function create()
	{
		var abuse = new BGSprite('abuse_bg', -1000, -1000, 1, 1);
		abuse.setGraphicSize(Std.int(1920),Std.int(1080));
		abuse.screenCenter();
		add(abuse);

		var mg = new FlxSprite(0, 0);
		mg.frames = Paths.getSparrowAtlas("mg/mg-screech");
		mg.animation.addByPrefix("idle", "base instance 1", 24, true);
		mg.animation.play("idle", true, false);
		mg.antialiasing = ClientPrefs.globalAntialiasing;
		mg.screenCenter();
		add(mg);

		PlayState.instance.inIntro = true;
	}
	
	override function createPost()
	{
		phone = new FlxSprite(0, 0).loadGraphic(Paths.image("mg/Cellphone"));
		phone.antialiasing = ClientPrefs.globalAntialiasing;
		phone.screenCenter();
		phone.cameras = [PlayState.instance.camHUD];
		phone.scale.set(0.9, 0.9);
		phone.alpha = 0.0001;

		phoneInnerBlack = new FlxSprite(0, 0).loadGraphic(Paths.image("mg/phoneBlack"));
		phoneInnerBlack.cameras = [PlayState.instance.camHUD];
		phoneInnerBlack.alpha = 0.001;
		phoneInnerBlack.antialiasing = ClientPrefs.globalAntialiasing;

		phoneBlack = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000);
		phoneBlack.cameras = [PlayState.instance.camHUD];

		add(phoneBlack);
		add(phoneInnerBlack);
		add(phone);

		if(ClientPrefs.data.shaders){
			glitchCorruptionShader = new GlitchCorruption();
			add(glitchCorruptionShader);

			fisheye = new Fisheye();
			add(fisheye);

			var filter:ShaderFilter = new ShaderFilter(glitchCorruptionShader.shader);
			PlayState.instance.camGameFilters.push(filter);
			PlayState.instance.camHUDFilters.push(filter);
			var filter2:ShaderFilter = new ShaderFilter(fisheye.shader);
			PlayState.instance.camGameFilters.push(filter2);
		}

		FlxTween.tween(phone, {alpha: 1, "scale.x": 1, "scale.y": 1}, 0.8, {ease: FlxEase.sineInOut, onComplete:function(_){
			MenuSongManager.playSound("jingle", 1.0);
			FlxTween.tween(phoneInnerBlack, {alpha: 1}, 0.8, {ease: FlxEase.sineInOut, onComplete:function(_){
				FlxTween.tween(phoneInnerBlack, {alpha: 0}, 0.8, {startDelay: 1.2, ease: FlxEase.sineInOut, onComplete:function(_){
					FlxTween.tween(phone, {"scale.x": 1.5, "scale.y": 1.5}, 0.8, {ease: FlxEase.backIn, onComplete:function(_){
						FlxTween.tween(phoneBlack, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						PlayState.instance.inIntro = false;
						PlayState.instance.startCountdown();

						remove(phoneBlack);
						phoneBlack.kill();
						phoneBlack.destroy();
						
						remove(phone);
						phone.kill();
						phone.destroy();
					}});

					remove(phoneInnerBlack);
					phoneInnerBlack.kill();
					phoneInnerBlack.destroy();
					
					PlayState.instance.updateCameraFilters('camGame');
					PlayState.instance.updateCameraFilters('camHUD');
				}});
			}});
		}});
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 160);
		offsetY = Std.int(dad.getMidpoint().y - 100);
		bfoffsetX = Std.int(dad.getMidpoint().x + 60);
		bfoffsetY = Std.int(dad.getMidpoint().y - 300);

		//make shader lerp
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 2, 0, 1);
		if(ClientPrefs.data.shaders){
			if(glitchCorruptionShader.amount > 0.001){
				glitchCorruptionShader.amount = FlxMath.lerp(glitchCorruptionShader.amount, 0, lerpVal);
			}
		}
	}

	override function noteConvert(noteData:Dynamic, actualNote:Note){
		if(!ClientPrefs.data.shaders) return;
		if(!actualNote.assignedChars.contains(3)) return;

		if(actualNote.assignedChars.length == 1){
			// there's only glitch

			actualNote.alpha = 0.2;
			actualNote.copyAlpha = false;
		} 
		actualNote.shader = new shaders.GlitchEden();
	}
	
	override function onOppNoteHit(note:Note) {
		if(note.assignedChars != null && ClientPrefs.data.shaders){
			for(char in note.assignedChars){
				if(char == 3){
					if(note.isSustainNote){
						//do lesser shader effect
						glitchCorruptionShader.amount += 0.02;
					} else {
						//do normal shader effect
						glitchCorruptionShader.amount += 0.1;
					}
				}
			}
		}
	}
}