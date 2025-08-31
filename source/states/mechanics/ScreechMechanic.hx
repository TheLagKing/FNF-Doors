package states.mechanics;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class ScreechMechanic extends MechanicsManager
{
    public function new()
    {
        super();
    }

    var eyesVignette:FlxSprite;
    override function createPost() {
        eyesVignette = new FlxSprite().loadGraphic(Paths.image('svignette-easy'));
        eyesVignette.scale.set(1.2, 1);
        eyesVignette.updateHitbox();
        eyesVignette.antialiasing = ClientPrefs.globalAntialiasing;
        eyesVignette.alpha = 1;
        eyesVignette.cameras = [game.camHUD];
        if(!ClientPrefs.data.downScroll){
            eyesVignette.angle = 180;
        }
        FlxTween.tween(eyesVignette, {alpha: 0.4}, Conductor.crochet / 1000 * 16, {ease:FlxEase.sineInOut, type:PINGPONG});

        add(eyesVignette);

        if(ClientPrefs.data.shaders){
            PlayState.instance.vignetteShader.extent = 0.5;
            PlayState.instance.vignetteShader.darkness = 15;
        }
    }

    public function onLight(){
        FlxTween.cancelTweensOf(eyesVignette);
        if(ClientPrefs.data.shaders){
            FlxTween.cancelTweensOf(PlayState.instance.vignetteShader);
        }
        FlxTween.tween(eyesVignette, {alpha: 0}, Conductor.crochet / 1000, {ease:FlxEase.expoOut});

        if(ClientPrefs.data.shaders){
            FlxTween.tween(PlayState.instance.vignetteShader, {extent: 0.25, darkness: 25}, Conductor.crochet / 1000, {ease:FlxEase.expoOut});
        }
    }

    public function onDark(){
        FlxTween.cancelTweensOf(eyesVignette);
        if(ClientPrefs.data.shaders){
            FlxTween.cancelTweensOf(PlayState.instance.vignetteShader);
        }
        FlxTween.tween(eyesVignette, {alpha: 1}, Conductor.crochet / 1000, {ease:FlxEase.sineInOut, onComplete: function(twn){
            FlxTween.tween(eyesVignette, {alpha: 0.4}, Conductor.crochet / 1000 * 16, {ease:FlxEase.sineInOut, type:PINGPONG});
        }});

        if(ClientPrefs.data.shaders){
            FlxTween.tween(PlayState.instance.vignetteShader, {extent: 0.5, darkness: 15}, Conductor.crochet / 1000, {ease:FlxEase.sineInOut});
        }
    }
}