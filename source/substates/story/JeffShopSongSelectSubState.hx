package substates.story;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class JeffShopSongSelectSubState extends MusicBeatSubstate
{
    var goblino:FlxSprite;
    var bob:FlxSprite;
    var divider:FlxSprite;

    var curSelected:String = "none";

    var canChoose:Bool = false;

	public function new()
	{
		super();

        goblino = new FlxSprite(0,0).loadGraphic(Paths.image("story_mode_backgrounds/shop/select/goblino"));
        goblino.antialiasing = ClientPrefs.globalAntialiasing;
        goblino.color = 0xFFFFFFFF;

        bob = new FlxSprite(0,0).loadGraphic(Paths.image("story_mode_backgrounds/shop/select/bob"));
        bob.antialiasing = ClientPrefs.globalAntialiasing;
        bob.color = 0xFFFFFFFF;

        divider = new FlxSprite(0,0).loadGraphic(Paths.image("story_mode_backgrounds/shop/select/divider"));
        divider.antialiasing = ClientPrefs.globalAntialiasing;
        divider.alpha = 0.0001;

        add(goblino);
        add(bob);
        add(divider);
        
        startGaming();
	}

	function startGaming()
	{
        goblino.y = bob.y = -19;
        goblino.x = 1920;
        bob.x = -1920;

        FlxTween.tween(bob, {x: 0}, Conductor.crochet/1000, {ease: FlxEase.expoOut, onComplete: function(twn){
            FlxTween.shake(bob, 0.005, Conductor.crochet/1000, XY, {ease: FlxEase.circIn, onComplete: function(twn){
                canChoose = true;
            }});
        }});
        FlxTween.tween(goblino, {x: 0}, Conductor.crochet/1000, {ease: FlxEase.expoOut, onComplete: function(twn){
            FlxTween.shake(goblino, 0.005, Conductor.crochet/1000, XY, {ease: FlxEase.circIn});
        }});
        FlxTween.tween(divider, {alpha: 1}, Conductor.crochet/1000, {ease: FlxEase.expoIn, onComplete: function(twn){
            FlxTween.shake(divider, 0.0004, Conductor.crochet/1000, X, {type: FlxTweenType.LOOPING});
        }});
	}

	function stopGaming()
	{
        FlxTween.cancelTweensOf(goblino);
        FlxTween.cancelTweensOf(bob);
        FlxTween.cancelTweensOf(divider);
        FlxTween.tween(bob, {x: -1920}, Conductor.crochet/1000, {ease: FlxEase.expoOut});
        FlxTween.tween(goblino, {x: 1920}, Conductor.crochet/1000, {ease: FlxEase.expoOut});
        FlxTween.tween(divider, {alpha: 0}, Conductor.crochet/1000, {ease: FlxEase.expoIn, onComplete: function(twn){
            close();
        }});
	}

    override function beatHit(){
        this.cameras[0].zoom += 0.025;
    }

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

        var lerpVal:Float = CoolUtil.boundTo(elapsed * 4, 0, 1);

        this.cameras[0].zoom = FlxMath.lerp(this.cameras[0].zoom, 0.7, lerpVal);

        if(controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            stopGaming();
        }

        if(canChoose){
            if(FlxG.mouse.getWorldPosition().x < 960){
                if(curSelected != "dead-serious"){
                    FlxTween.cancelTweensOf(bob);
                    FlxTween.cancelTweensOf(goblino);
                    FlxTween.color(bob, Conductor.crochet/1000, bob.color, 0xFFFFFFFF, {ease: FlxEase.expoOut});
                    FlxTween.color(goblino, Conductor.crochet/1000, goblino.color, 0xFF505050, {ease: FlxEase.expoOut});    
                }

                curSelected = "dead-serious";
                if(FlxG.mouse.justPressed) chooseSong();
            } else if (FlxG.mouse.getWorldPosition().x >= 960){
                if(curSelected != "bargain"){
                    FlxTween.cancelTweensOf(bob);
                    FlxTween.cancelTweensOf(goblino);
                    FlxTween.color(bob, Conductor.crochet/1000, bob.color, 0xFF505050, {ease: FlxEase.expoOut});
                    FlxTween.color(goblino, Conductor.crochet/1000, goblino.color, 0xFFFFFFFF, {ease: FlxEase.expoOut});
                }
    
                curSelected = "bargain";
                if(FlxG.mouse.justPressed) chooseSong();
            }
        }
	}

    private function chooseSong(){
        CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
        PlayState.isStoryMode = true;

        PlayState.storyDifficulty = StoryMenuState.instance.curDifficulty;
        StoryMenuState.instance.selectedWeek = true;
        PlayState.storyPlaylist = [curSelected];
        
        var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), StoryMenuState.instance.curDifficulty);

        var songSelectedName = PlayState.storyPlaylist[0].toLowerCase();
        if(Song.checkChartExists(poop, songSelectedName)){
            PlayState.SONG = Song.loadFromJson(poop, songSelectedName);
        }
        else{
            PlayState.SONG = Song.loadFromJson(songSelectedName, songSelectedName);
        }
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        PlayState.targetDoor = 53;

        cameras[0].fade(FlxColor.BLACK, 1, false, function(){
            FlxTween.cancelTweensOf(bob);
            FlxTween.cancelTweensOf(goblino);
            FlxTween.cancelTweensOf(divider);
            LoadingState.loadAndSwitchState(new PlayState(), true);
        });
    }
}