package states.storymechanics;

import flixel.sound.filters.FlxSoundFilter;
import flixel.sound.filters.FlxSoundFilterType;
import flixel.FlxSubState;
import backend.BaseSMMechanic.BaseSMMechanic;

class Hide extends BaseSMMechanic{
    public var isInCloset:Bool = false;
    
    //hide should kill you at 10.
    var hideValue:Float = -4;

    //hide will increment this per second on rush, x1.5 for ambush
    var hideIncrements:Float = 0.5;

    //whenever you hit spacebar, you lose this much hideValue
    final HIDE_DECREMENTS:Int = 1;

    var hideVignette:FlxSprite;
    var hideGetOut:FlxSprite;

    var hideWhispers:FlxSound;
    var hideScare:FlxSound;

    var isDead:Bool = false;

    override function create() { 
        hideIncrements *= (PlayState.storyDifficulty+1) / 2;
    }

    override function createPost() { 
        hideGetOut = new FlxSprite().loadGraphic(Paths.image("hideGetOut"));
        hideGetOut.alpha = 0.0001;
        hideGetOut.cameras = [StoryMenuState.instance.camHUD];
        add(hideGetOut);

        hideVignette = new FlxSprite().loadGraphic(Paths.image("hideVignette"));
        hideVignette.alpha = 0.0001;
        hideVignette.cameras = [StoryMenuState.instance.camHUD];
        add(hideVignette);

        hideWhispers = new FlxSound();
        hideWhispers.loadEmbedded(Paths.sound("HideWhispers"));
        hideWhispers.looped = true;
        hideWhispers.persist = false;
        hideWhispers.volume = 0;
        hideWhispers.play();
    }

    override function update(elapsed:Float) { 
        if(isDead) return;
        
        hideValue += hideIncrements * elapsed;

        hideVignette.alpha = hideValue/5;
        hideWhispers.volume = hideValue/3;
        hideGetOut.alpha = 0;
        
        if(!isInCloset) {
            hideValue = -4;
            hideWhispers.volume = 0;
            return;
        }

        var boolValue = Math.max(0.3 * Math.pow(2, hideValue), 0);

        if(FlxG.random.bool(boolValue) || !ClientPrefs.data.flashing){
            hideGetOut.alpha = hideValue/5;
            game.camHUD.shake(hideValue / 250, 0.1, null, true);
			MenuSongManager.playSound("shortStatic", 1);
        }

        if(hideValue >= 5) {
            isDead = true;
            isInCloset = false;
            hideGetOut.alpha = 0;
            hideWhispers.volume = 0;
            hideVignette.alpha = 0;
            StoryMenuState.instance.fuckingDie("VOID", "hide", function(){
                DoorsUtil.curRun.revivesLeft += 1;
            });
			MenuSongManager.playSound("HideScare", 1);
        }
    }

    override function onClosetEnter() {
        isInCloset = true;
        hideWhispers.volume = 0;
    }

    override function onClosetLeave() {
        isInCloset = false;
        hideWhispers.volume = 0;
    }
}