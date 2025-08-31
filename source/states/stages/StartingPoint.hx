package states.stages;

import flixel.group.FlxGroup;
import backend.BaseStage;
import backend.BaseStage.Countdown;

class StartingPoint extends BaseStage
{
    public static function getPreloadShit():Null<Map<String, Array<String>>> {
		var theMap:Map<String, Array<String>> = [
			"images" => ["startingpoint/bg", "startingpoint/GoldGate", 
						"startingpoint/IronGate1", "startingpoint/IronGate2", 
                        "startingpoint/LobbyBG"]
		];

		return theMap;
	}

    override function getBadAppleShit():Null<Map<String, Array<Dynamic>>>{
		var map:Map<String, Array<Dynamic>> = [
			"background" => [],
			"foreground" => [],
			"special" => [[]]
		];

		return map;
	}

    var gold:FlxSprite;
    var bg:FlxSprite;
    var iron1:FlxSprite;
    var iron2:FlxSprite;
    var lobby:FlxSprite;
    var titleCard:FlxSprite;

    override function create() {
        game.camZooming = true;
        dadGroup.visible = false;
        boyfriendGroup.visible = false;
        gfGroup.visible = false;

        var bg = new FlxSprite(0, 0).loadGraphic(Paths.image('startingpoint/bg'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;

        iron1 = new FlxSprite(728, 178).loadGraphic(Paths.image('startingpoint/IronGate1'));
        iron1.antialiasing = ClientPrefs.globalAntialiasing;

        iron2 = new FlxSprite(957, 178).loadGraphic(Paths.image('startingpoint/IronGate2'));
        iron2.antialiasing = ClientPrefs.globalAntialiasing;

        gold = new FlxSprite(728, 182).loadGraphic(Paths.image('startingpoint/GoldGate'));
        gold.antialiasing = ClientPrefs.globalAntialiasing;

        var lobby = new FlxSprite(350, 0).loadGraphic(Paths.image('startingpoint/LobbyBG'));
        lobby.scale.set(0.8, 0.8);
        lobby.antialiasing = ClientPrefs.globalAntialiasing;

        camBars.fade(FlxColor.BLACK, 0.00001, false, true);
        
		camGame.shake(0.003, 160, null, true, Y);
        
		titleCard = new FlxSprite(0,0).loadGraphic(Paths.image("titlecards/f1"));
		titleCard.cameras = [camHUD];
		titleCard.alpha = 0;
		titleCard.screenCenter();
		titleCard.antialiasing = ClientPrefs.globalAntialiasing;

        add(lobby);
        add(iron1);
        add(iron2);
        add(gold);
        add(bg);
    }

    override function createPost() {

        comboPosition = [850, 641];
        comboPosition[0] -= 400;
        comboPosition[1] -= 100;
    }

    override function update(elapsed:Float){
        PlayState.instance.iconP2.visible = false;
		offsetX = Std.int(dad.getMidpoint().x - 871);
		offsetY = Std.int(dad.getMidpoint().y - 200);
		bfoffsetX = Std.int(dad.getMidpoint().x - 871);
		bfoffsetY = Std.int(dad.getMidpoint().y - 200);
	}

    override function stepHit() {
        switch (curStep)
        {
            case 16:
                camBars.fade(FlxColor.BLACK, 9.6, true, true);
            case 496:
                camBars.fade(FlxColor.BLACK, 1.3, false, true);	
                FlxTween.tween(camGame, {zoom: 1.1}, 1.3, {
                    ease: FlxEase.smoothStepInOut,
                    onComplete: 
                    function (twn:FlxTween)
                    {
                        defaultCamZoom = 0.75;
                    }
                });
            case 512:
                camBars.fade(FlxColor.BLACK, 0.0001, true, true);
                if (ClientPrefs.data.flashing) {
                    camBars.flash(0xFFFFFFFF, 1, null, true);
                }      	
            case 640:
                camBars.fade(FlxColor.BLACK, 0.5, false, true);	
                FlxTween.tween(camGame, {zoom: 1.1}, 0.5, {
                    ease: FlxEase.smoothStepInOut,
                    onComplete: 
                    function (twn:FlxTween)
                    {
                        defaultCamZoom = 0.75;
                    }
                });
            case 648:
                camBars.fade(FlxColor.BLACK, 0.0001, true, true);
                if (ClientPrefs.data.flashing) {
                    camBars.flash(0xFFFFFFFF, 1, null, true);
                }
            case 744:
                camBars.fade(FlxColor.BLACK, 1.6, false, true);	
                FlxTween.tween(camGame, {zoom: 1.1}, 1.6, {
                    ease: FlxEase.smoothStepInOut,
                    onComplete: 
                    function (twn:FlxTween)
                    {
                        defaultCamZoom = 0.75;
                    }
                });
            case 764:
                camBars.fade(FlxColor.BLACK, 0.5, true, true);
            case 896:
                camBars.fade(FlxColor.BLACK, 0.5, false, true);	
                FlxTween.tween(camGame, {zoom: 1.1}, 0.5, {
                    ease: FlxEase.smoothStepInOut,
                    onComplete: 
                    function (twn:FlxTween)
                    {
                        defaultCamZoom = 0.75;
                    }
                });
            case 904:
                camBars.fade(FlxColor.BLACK, 0.0001, true, true);
                if (ClientPrefs.data.flashing) {
                    camBars.flash(0xFFFFFFFF, 1, null, true);
                }
            case 1001:
                camBars.fade(FlxColor.BLACK, 1.2, false, true);	
                FlxTween.tween(camGame, {zoom: 1.1}, 1.2, {
                    ease: FlxEase.smoothStepInOut,
                    onComplete: 
                    function (twn:FlxTween)
                    {
                        defaultCamZoom = 0.75;
                    }
                });
            case 1021:
                camBars.fade(FlxColor.BLACK, 0.5, true, true);
            case 1274:
                camGame.shake(0.003, 0.001, null, true, Y);
                FlxTween.tween(camGame, {zoom: 1.4}, 4, {ease: FlxEase.smoothStepInOut});
                FlxTween.tween(iron2, {x: iron2.x + 300}, 1.5, {ease: FlxEase.quintInOut, onComplete: function(twn){
                    iron2.visible = false;
                }});
                FlxTween.tween(iron1, {x: iron1.x - 300}, 1.5, {ease: FlxEase.quintInOut, startDelay: 0.2, onComplete: function(twn){
                    iron1.visible = false;
                }});
                new FlxTimer().start(1, function(tmr){
                    FlxTween.tween(gold, {y: gold.y - 800}, 1.5, {ease: FlxEase.quintInOut, onComplete: function(twn){
                        gold.visible = false;
					    add(titleCard);
                        if(FlxG.random.int(0, 2000) == 5) MenuSongManager.playSound("titlecard/hotel_fart", 1);
                        else MenuSongManager.playSound("titlecard/hotel", 1);

                        MenuSongManager.changeSongVolume(0.1, 0.6);
                        FlxTween.tween(titleCard, {"scale.x": 1.15, "scale.y": 1.15}, 8, {ease:FlxEase.linear});
                        FlxTween.tween(titleCard, {alpha: 1}, 0.6, {ease:FlxEase.quartIn, onComplete: function(twn){
                            camBars.fade(FlxColor.BLACK, 4, false, true);	
                        }});
                    }});
                });
        }
    }
}