package states.mechanics.modifiers;

import flixel.math.FlxRandom;
#if !flash 
import openfl.filters.ShaderFilter;
#end

class HideMechanic extends MechanicsManager
{
    //hide should kill you at 10.
    var hideValue:Float = 0;

    //hide will increment this per second on rush, x1.5 for ambush
    var hideIncrements:Float = 0.5;

    //whenever you hit spacebar, you lose this much hideValue
    final HIDE_DECREMENTS:Int = 1;

    var hideVignette:FlxSprite;
    var hideGetOut:FlxSprite;

    var hideWhispers:FlxSound;
    var hideScare:FlxSound;

    var isDead:Bool = false;

    var isAmbush:Bool = false;
    public function new(?isAmbush:Bool)
    {
        this.isAmbush = isAmbush;
        super();
    }

    override function create()
    {
        if(isAmbush) hideIncrements *= 1.5;

        hideIncrements *= (PlayState.storyDifficulty+1) / 2;
    }

    override function createPost() {
        hideGetOut = new FlxSprite().loadGraphic(Paths.image("hideGetOut"));
        hideGetOut.alpha = 0.0001;
        hideGetOut.cameras = [game.camOther];
        add(hideGetOut);

        hideVignette = new FlxSprite().loadGraphic(Paths.image("hideVignette"));
        hideVignette.alpha = 0.0001;
        hideVignette.cameras = [game.camOther];
        add(hideVignette);

        hideWhispers = new FlxSound();
        hideWhispers.loadEmbedded(Paths.sound("HideWhispers"));
        hideWhispers.looped = true;
        hideWhispers.persist = false;
        hideWhispers.volume = 0;
        hideWhispers.play();
    }

    override function update(elapsed:Float)
    {
        if(isDead) return;
        
        hideValue += hideIncrements * elapsed;

        hideVignette.alpha = hideValue/5;
        hideWhispers.volume = hideValue/3;
        
        if(FlxG.keys.justPressed.SPACE)
        {
            hideValue -= HIDE_DECREMENTS;
            hideValue = Math.max(0, hideValue);
        }

        var boolValue = 0.3 * Math.pow(2, hideValue);

        if(FlxG.random.bool(boolValue) || !ClientPrefs.data.flashing){
            hideGetOut.alpha = hideValue/5;
            game.camHUD.shake(hideValue / 250, 0.1, null, true);
			MenuSongManager.playSound("shortStatic", 1);
        } else {
            hideGetOut.alpha = 0;
        }

        if(hideValue >= 5 && PlayState.healthLoss > 0.01) {
            isDead = true;
            game.health = -1;
            hideWhispers.volume = 0;
            hideVignette.alpha = 0;
        }
    }
}