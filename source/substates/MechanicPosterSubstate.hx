package substates;

import flixel.input.keyboard.FlxKey;
import flxgif.FlxGifSprite;
import flxgif.FlxGifSpriteAsync;
import flxanimate.FlxAnimate;
import flixel.FlxSubState;
import animateatlas.AtlasFrameMaker;

class MechanicPosterSubstate extends FlxSubState{

    public var mechanicsPosters:Array<String> = [];
    public var curPoster:Int = 0;
    public var curKey:String = "";
    public var canYouRemove:Bool = true;

    var currentMechanicFolder:String = "";

    public static var isOff:Bool = false;

    var clickAnywhereToLeave:FlxText;

    var posterGroup:FlxSpriteGroup;

    public function new(){
        super();
        isOff = false;
        currentMechanicFolder = getFromSongName(PlayState.SONG.song);

        if(currentMechanicFolder == ""){
            exitState();
            return;
        }

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 2]];

        createPoster();

        canYouRemove = true;

        var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get("accept");
        var key = InputFormatter.getKeyName(savKey[0] != null ? savKey[0] : NONE);
        var key2 = InputFormatter.getKeyName(savKey[1] != null ? savKey[1] : NONE);

		clickAnywhereToLeave = new FlxText(0, FlxG.height * 0.9, FlxG.width, (Lang.getText("pressOffMult", "newUI"):String).replace("{0}", key).replace("{1}", key2));
		clickAnywhereToLeave.antialiasing = ClientPrefs.globalAntialiasing;
		clickAnywhereToLeave.setFormat(FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		clickAnywhereToLeave.alpha = 0;
		add(clickAnywhereToLeave);
		FlxTween.tween(clickAnywhereToLeave, {alpha: 0.4}, 0.6, {ease: FlxEase.quadOut, startDelay: 3.0});
    }
    
    override function update(elapsed){

        if(!isOff && canYouRemove){
            if(FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE){
                FlxG.sound.play(Paths.sound("lock"));
                removeCurPoster();
            }
        }

        super.update(elapsed);
    }

    private function removeCurPoster(){
        canYouRemove = false;
        FlxTween.tween(posterGroup, {alpha: 0}, 0.6, {ease: FlxEase.quadIn, onComplete: function(twn){
            canYouRemove = true;

            exitState();
        }});
    }

    private function exitState(){
        PlayState.instance.allowCountdown = true;
        PlayState.instance.startCountdown();
        isOff = true;
        close();
    }

    private function getFromSongName(songName:String, ?darkRoom:Bool):Dynamic{
        var folder = "";
        switch(songName.toLowerCase().replace("-hell", "")){
            case "halt" | "onward":
                folder = "halt";

            case "stare" | "always-watching" | "watch-out" | "eye-spy":
                folder = "eyes";

            case "not-a-sound" | "tranquil" | "imperceptible" | "hyperacusis":
                folder = "figure";
        }

        return folder;
    }

    private function createPoster(){
        posterGroup = new FlxSpriteGroup(0,0);

        var flatColor:FlxColor = switch(currentMechanicFolder){
            case "halt": 0xFF28393C;
            case "figure": 0xFF3C2D27;
            case "eyes": 0xFF2F273C;
            default: 0xFF000000;
        }
        var flatBg:FlxSprite = new FlxSprite(0,0).makeSolid(1280, 720, flatColor);
        posterGroup.add(flatBg);

        var text:FlxText = new FlxText(0,0,0,switch(currentMechanicFolder){
            case "halt": Lang.getText("bg", "mechanics/"+currentMechanicFolder);
            case "figure": Lang.getText("bg", "mechanics/"+currentMechanicFolder);
            case "eyes": Lang.getText("bg", "mechanics/"+currentMechanicFolder);
            default: "";
        }, 96, 0);
        text.setFormat(FONT, 96, switch(currentMechanicFolder){
            case "halt": 0xFF869A9A;
            case "figure": 0xFFAC8171;
            case "eyes": 0xFF8B75AE;
            default: 0xFF000000;
        });
        text.draw();
        var scrollText:FlxBackdrop = new FlxBackdrop(text.graphic, XY, 5, 5);
        scrollText.angle = 30;
        scrollText.alpha = 0.2;
        scrollText.velocity.set(100, 100);
        posterGroup.add(scrollText);

        var dots:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("mechanics/"+currentMechanicFolder+"/dots"));
        FlxTween.tween(dots, {alpha: 0.6}, 4.0, {ease: FlxEase.sineInOut, type: PINGPONG});
        posterGroup.add(dots);

        var illu:FlxSprite = new FlxSprite(0,-70).loadGraphic(Paths.image("mechanics/"+currentMechanicFolder+"/illu"));
        posterGroup.add(illu);
        FlxTween.tween(illu, {y: -10}, 6.0, {ease: FlxEase.sineInOut, type: PINGPONG});

        var add:FlxSprite = new FlxSprite(0,-66).loadGraphic(Paths.image("mechanics/"+currentMechanicFolder+"/additional"));
        posterGroup.add(add);

        //NOW ADD THE MOTHAFUCKIN TEXT RAHHHHHHHH

        switch(currentMechanicFolder){
            case "halt":
                var titleText:FlxText = new FlxText(571, 99, 0, Lang.getText("title", "mechanics/halt"));
                titleText.setFormat(FONT, 96, 0xFFB0D3D3, CENTER, OUTLINE, 0xFF435252);
                titleText.borderSize = 4;
                posterGroup.add(titleText);

                var majorText:FlxText = new FlxText(571, 420, 641, Lang.getText("major", "mechanics/halt"));
                majorText.setFormat(FONT, 64, 0xFFB0D3D3, CENTER, OUTLINE, 0xFF435252);
                majorText.borderSize = 2;
                posterGroup.add(majorText);

                var minorText:FlxText = new FlxText(571, 515, 641, (Lang.getText("minor", "mechanics/halt"):String).replace("{0}", "SPACE"));
                minorText.setFormat(FONT, 32, 0xFFB0D3D3, CENTER, OUTLINE, 0xFF435252);
                minorText.borderSize = 2;
                posterGroup.add(minorText);
            case "eyes":
                var titleText:FlxText = new FlxText(571, 99, 0, Lang.getText("title", "mechanics/eyes"));
                titleText.setFormat(FONT, 96, 0xFFAA8ED8, CENTER, OUTLINE, 0xFF1F1829);
                titleText.borderSize = 4;
                posterGroup.add(titleText);

                var majorText:FlxText = new FlxText(571, 276, 589, Lang.getText("major", "mechanics/eyes"));
                majorText.setFormat(FONT, 64, 0xFFAA8ED8, CENTER, OUTLINE, 0xFF1F1829);
                majorText.borderSize = 4;
                posterGroup.add(majorText);

                var minorText:FlxText = new FlxText(571, 371, 589, (Lang.getText("minor", "mechanics/eyes"):String).replace("{0}", "SPACE"));
                minorText.setFormat(FONT, 32, 0xFFAA8ED8, CENTER, OUTLINE, 0xFF1F1829);
                minorText.borderSize = 4;
                posterGroup.add(minorText);
            case "figure":
                var titleText:FlxText = new FlxText(515, 99, 0, Lang.getText("title", "mechanics/figure"));
                titleText.setFormat(FONT, 96, 0xFFDFBBAD, CENTER, OUTLINE, 0xFF2E1911);
                titleText.borderSize = 4;
                posterGroup.add(titleText);

                var majorText:FlxText = new FlxText(515, 313, 718, Lang.getText("major", "mechanics/figure"));
                majorText.setFormat(FONT, 64, 0xFFDFBBAD, CENTER, OUTLINE, 0xFF2E1911);
                majorText.borderSize = 4;
                posterGroup.add(majorText);

                var hbL:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get("heartbeat_left");
                var hbR:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get("heartbeat_right");
                var heartLeft = InputFormatter.getKeyName(hbL[0] != null ? hbL[0] : NONE);
                var heartRight = InputFormatter.getKeyName(hbR[0] != null ? hbR[0] : NONE);

                var minorText:FlxText = new FlxText(559, 408, 630, (Lang.getText("minor", "mechanics/figure"):String).replace("{0}", heartLeft).replace("{1}", heartRight));
                minorText.setFormat(FONT, 32, 0xFFDFBBAD, CENTER, OUTLINE, 0xFF2E1911);
                minorText.borderSize = 2;
                posterGroup.add(minorText);

                illu.x -= 81;
        }

        posterGroup.forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
        this.add(posterGroup);
    }
}