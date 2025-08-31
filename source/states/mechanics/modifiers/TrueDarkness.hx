package states.mechanics.modifiers;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class TrueDarkness extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function createPost() {
        var eyesBlack = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
        eyesBlack.alpha = 0.2;
        eyesBlack.cameras = [PlayState.instance.camOther];

        var eyesVignette = new FlxSprite().loadGraphic(Paths.image('svignette'));
        eyesVignette.scale.set(1.2, 1);
        eyesVignette.updateHitbox();
        eyesVignette.antialiasing = ClientPrefs.globalAntialiasing;
        eyesVignette.alpha = 1;
        eyesVignette.cameras = [game.camHUD];

        add(eyesBlack);
        add(eyesVignette);

        if(ClientPrefs.data.shaders && PlayState.instance.vignetteShader != null){
            PlayState.instance.vignetteShader.extent = 0.5;
            PlayState.instance.vignetteShader.darkness = 15;
        }
    }
}