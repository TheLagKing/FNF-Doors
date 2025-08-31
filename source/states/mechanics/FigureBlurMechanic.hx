package states.mechanics;

import shaders.FigureBlur;
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

class FigureBlurMechanic extends MechanicsManager
{
    var figureBlurr:FigureBlur;

    public function new()
    {
        super();
    }

    override function create()
    {
        if(ClientPrefs.data.shaders)
        {
            figureBlurr = new FigureBlur();
            figureBlurr.cx = 0.5;
            figureBlurr.cy = 0.5;
            figureBlurr.blurWidth = 0.02;
            add(figureBlurr);
            var filter:ShaderFilter = new ShaderFilter(figureBlurr.shader);
            game.camGameFilters.push(filter);
            game.updateCameraFilters('camGame');
            game.camHUDFilters.push(filter);
            game.updateCameraFilters('camHUD');
        }
    }

    override function opponentNoteHit(note:Note)
    {
        if(!note.isSustainNote)
        {
            var easyMode:Bool = PlayState.storyDifficulty == 0;
            if(ClientPrefs.data.shaders) figureBlurr.blurWidth += easyMode ? 0.02 : 0.03;

            if(!easyMode)
            {
                game.camHUD.shake(0.005, 0.1);
                game.camGame.shake(0.005, 0.1);
            }
        }
    }

    override function update(elapsed:Float)
    {
        if(ClientPrefs.data.shaders)
            figureBlurr.blurWidth = FlxMath.lerp(0, figureBlurr.blurWidth, CoolUtil.boundTo(1 - elapsed * 5, 0, 1));
    }
}