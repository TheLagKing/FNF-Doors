package objects.ui;

import online.Leaderboards.LeaderboardSongScore;

enum abstract DoorsLeaderboardTextType(Int) {
    final SCORE = 0;
    final ACCURACY = 1;
    final MISSES = 2;
    final MODIFIERS = 3;
}

class DoorsLeaderboardText extends FlxSpriteGroup {
    public var textType:DoorsLeaderboardTextType = DoorsLeaderboardTextType.ACCURACY;

    public var bg:FlxSprite;
    public var buttonText:FlxText;

    public function new(x:Float, y:Float, text:String, type:DoorsLeaderboardTextType){
        super(x, y);
        this.textType = type;
        makeButton(text);
    }

    private function makeButton(text:String){
        var pathName = "small_box";

        switch(textType){
            case SCORE:
                pathName = "big_box";
            default:
        }

        bg = new FlxSprite(0,0).loadGraphic(Paths.image('ui/score/${pathName}'));
        add(bg);

        buttonText = new FlxText(0, 0, bg.width, text);
        buttonText.setFormat(FONT, 32, 0xFFFEDEBF, CENTER);
        buttonText.antialiasing = ClientPrefs.globalAntialiasing;
        buttonText.y = bg.height/2 - buttonText.height/2;
        add(buttonText);

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }
}