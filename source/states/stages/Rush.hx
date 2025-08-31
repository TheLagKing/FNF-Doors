package states.stages;

import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class Rush extends BaseStage
{
	public static var altID:Int = 0;

	public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => switch(altID){
				default: ["rush/lit/GreenBG Addition", "rush/dark/GreenBG AdditionD", 
				"rush/lit/Closet1", "rush/lit/Closet2", "rush/lit/Closet3",
				"rush/lit/Closet4", "rush/lit/Closet5 addition",
				"rush/dark/Closet1D", "rush/dark/Closet2D", "rush/dark/Closet3D",
				"rush/dark/Closet4D", "rush/dark/Closet5 additionD",
				"rush/lit/ShadowFrontCamera", "rush/dark/DoubleShadowFrontCamera",
				"rush_fog"];
				case 1: ["rush/alt/lit", "rush/alt/dark"];
				case 2: ["rush/alt2/darkbg", "rush/alt2/lightbg", "rush/alt2/darkShade"];
				case 3: ["rush/alt3/darkbg", "rush/alt3/lightbg"];
			}
		];
	

		return theMap;
	}

	
	override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [],
			"foreground" => [],
			"special" => [[fog, 0.6]]
		];

		for(i in 0...realLit.length){
			if(i == 0){
				map.get("background").push(realLit[i]);
				map.get("background").push(realDark[i]);
			} else {
				map.get("foreground").push(realLit[i]);
				map.get("foreground").push(realDark[i]);
			}
		}

		return map;
	}

	var realLit:Array<FlxSprite>;
	var realDark:Array<FlxSprite>;
	var fog:BGSprite;

	override function create()
	{
		var i:Int = 1;
		var litArr:Array<FlxSprite> = [];
		var darkArr:Array<FlxSprite> = [];

		switch(altID){
			case 1:
				var stage:BGSprite = new BGSprite('rush/alt/lit', -750, -140, 1, 1);
		
				var stageD:BGSprite = new BGSprite('rush/alt/dark', -750, -140, 1, 1);
	
				realLit = [stageD];
				realDark = [stage];
			case 2:
				var stage:BGSprite = new BGSprite('rush/alt2/darkbg', -750, -140, 1, 1);
		
				var stageD:BGSprite = new BGSprite('rush/alt2/lightbg', -750, -140, 1, 1);
				
				var shadow:BGSprite = new BGSprite('rush/alt2/darkShade', -750, -140, 1, 1);
	
				realLit = [stageD];
				realDark = [stage, shadow];
			case 3:
				var stage:BGSprite = new BGSprite('rush/alt3/lightbg', -750, -140, 1, 1);
		
				var stageD:BGSprite = new BGSprite('rush/alt3/darkbg', -750, -140, 1, 1);
	
				realLit = [stage];
				realDark = [stageD];
			default:
				var stage:BGSprite = new BGSprite('rush/lit/GreenBG Addition', -750, -140, 1, 1);
				litArr.push(stage);
		
				var stageD:BGSprite = new BGSprite('rush/dark/GreenBG AdditionD', -750, -140, 1, 1);
				darkArr.push(stageD);
		
				while(i < 5){
					var closet:BGSprite = new BGSprite('rush/lit/Closet' + i, -750, -140, 1, 1);
					litArr.push(closet);
		
					var closetD:BGSprite = new BGSprite('rush/dark/Closet' + i + 'D', -750, -140, 1, 1);
					darkArr.push(closetD);
					i++;
				}
				var closet5:BGSprite = new BGSprite('rush/lit/Closet5 addition', -750, -140, 1, 1);
				litArr.push(closet5);
				var uncloset5:BGSprite = new BGSprite('rush/dark/Closet5 additionD', -750 + 1546, -140, 1, 1);
				darkArr.push(uncloset5);
				
				var shadow:BGSprite = new BGSprite('rush/lit/ShadowFrontCamera', -750, -140, 1, 1);
				litArr.push(shadow);
				var unshadow:BGSprite = new BGSprite('rush/dark/DoubleShadowFrontCamera', -750, -140, 1, 1);
				darkArr.push(unshadow);
				
				realLit = [];
				realDark = [];
				for (i in 0...litArr.length){
					var rBool = new FlxRandom().bool(50);
					if(rBool || i == litArr.length - 1 || i == 0){
						realLit.push(litArr[i]);
						realDark.push(darkArr[i]);
					}
				}
		}

		for(thing in realLit){
			add(thing);
		}
		for(thing in realDark){
			add(thing);
			thing.kill();
		}

		boyfriendGroup.visible = false;

		fog = new BGSprite('rush_fog', 0, 0, 1.0, 1.0,['Occurrence Symbole 1 1'], true);
		fog.alpha = 1;
		fog.scale.set(0.64, 0.64);
		fog.updateHitbox();
		fog.screenCenter();
		fog.x -= 500;
		fog.y -= 20;
		fog.color = 0xFF000000;
		add(fog);
	}

	override function createPost(){
		comboPosition = [84, 341]; //average of the two characters
		comboPosition[0] -= 400;
		comboPosition[1] -= 100;
	}

	override function update(elapsed:Float){
		offsetX = Std.int(dad.getMidpoint().x + 305);
		offsetY = Std.int(dad.getMidpoint().y);
		bfoffsetX = Std.int(dad.getMidpoint().x + 305);
		bfoffsetY = Std.int(dad.getMidpoint().y);
	}
	override function stepHit()
	{
		if(curStep <= 10 && curStep != 0){
			if(curStep % 2 == 0){
				for(thing in realLit){
					thing.revive();
				}
				
				for(thing in realDark){
					thing.kill();
				}
			} else {
				for(thing in realLit){
					thing.kill();
				}
				
				for(thing in realDark){
					thing.revive();
				}
			}
		} if (curStep == 11){
			for(thing in realLit){
				thing.kill();
			}
			
			for(thing in realDark){
				thing.revive();
			}
		}
	}
}