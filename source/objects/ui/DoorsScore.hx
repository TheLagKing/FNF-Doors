package objects.ui;

import online.Leaderboards.LeaderboardSongScore;

enum abstract DoorsScorePlacement(Int) {
    final OTHER = 0;
    final FIRST = 1;
    final SECOND = 2;
    final THIRD = 3;
}

class DoorsScore extends FlxSpriteGroup {
    public var placement:DoorsScorePlacement = DoorsScorePlacement.OTHER;

    public var bg:FlxSprite;
    public var buttonText:FlxText;

    public var scoreBox:DoorsLeaderboardText;
    public var accBox:DoorsLeaderboardText;
    public var missBox:DoorsLeaderboardText;
    public var modBox:DoorsLeaderboardText;

    public function new(x:Float, y:Float, score:LeaderboardSongScore, placement:DoorsScorePlacement){
        super(x, y);
        this.placement = placement;
        makeButton(score);
    }

    private function makeButton(boundScore:LeaderboardSongScore){
        var pathName = "Other";
        var xOffset = 18;

        switch(placement){
            case FIRST:
                pathName = "Gold";
                xOffset = 47;
            case SECOND:
                pathName = "Silver";
                xOffset = 47;
            case THIRD:
                pathName = "Copper";
                xOffset = 47;
            default:
        }

        bg = new FlxSprite(0,0).loadGraphic(Paths.image('ui/score/${pathName}'));
        add(bg);

        buttonText = new FlxText(0, 0, bg.width, boundScore.name);
        buttonText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT);
        buttonText.borderSize = 2;
        buttonText.antialiasing = ClientPrefs.globalAntialiasing;
        buttonText.offset.x = -xOffset;
        add(buttonText);

        scoreBox = new DoorsLeaderboardText(432, 5, 
            Std.string(boundScore.score), SCORE);
        add(scoreBox);

        accBox = new DoorsLeaderboardText(594, 5, 
            boundScore.acc <= 1 ? Std.string(CoolUtil.quantize(boundScore.acc*100, 100))+"%" : Std.string(boundScore.acc)+"%", 
            ACCURACY);
        add(accBox);

        missBox = new DoorsLeaderboardText(726, 5, 
            Std.string(boundScore.misses != 0 ? boundScore.misses : "FC"), MISSES);
        add(missBox);

        modBox = new DoorsLeaderboardText(857, 5, 
            Std.string(Math.isNaN(boundScore.scoreMod) ? "100" : CoolUtil.quantize(boundScore.scoreMod*100, 100))+"%", MODIFIERS);
        add(modBox);

        this.forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }
}