package states.mechanics;

import shaders.SeekChromaticAberration;
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

class HealthDrain extends MechanicsManager
{
    public var healthDrainMult:Float = 0;
    public var chromashit:Float = 1.0;
    var seekChroma:SeekChromaticAberration;

    public function new(healthDrain:Float, typeOfDrain:String)
    {
        this.healthDrainMult = healthDrain;
        type = typeOfDrain;

        super();
    }

    override function create()
    {
        if(!game.generatedMusic) game.allowCountdown = false;

        if(ClientPrefs.data.shaders && type == 'seek')
        {
            seekChroma = new SeekChromaticAberration();
            add(seekChroma);
            var filter:ShaderFilter = new ShaderFilter(seekChroma.shader);
            game.camGameFilters.push(filter);
            game.updateCameraFilters('camGame');
        }
    }

    override function opponentNoteHit(note:Note)
    {
        var healthModifierLoss:Float = PlayState.healthLoss;

        switch(PlayState.SONG.song.toLowerCase())
        {
            case 'ready-or-not':
                healthModifierLoss = 0.9;

            case 'delve':
                healthModifierLoss = 1.1;
        }

		if(DoorsUtil.modifierActive(25))
        {
			healthModifierLoss /= 2;
		}
		else if(DoorsUtil.modifierActive(26))
        {
			healthModifierLoss *= 2;
		}

        var diff = PlayState.storyDifficulty == null ? 1 : PlayState.storyDifficulty;

        var multCalc:Float = (note.isSustainNote ? healthDrainMult/4 : healthDrainMult) * healthModifierLoss;
        if(game.health >= (diff <= 1 ? 0.6 : 0.3)) game.health -= (0.00425 * Math.pow(1.7, diff)) * multCalc;

        if(type == 'seek')
        {
            chromashit += diff == 0 ? 5 : 10;
            if (diff != 0)
            {
                game.camGame.shake(0.003, 0.1);
		        game.camGame.shake(0.003, 0.1);
            }
        }
    }

    override function update(elapsed:Float)
    {
        if(type == 'seek' && ClientPrefs.data.shaders)
        {
            chromashit = FlxMath.lerp(chromashit, (2 - game.health) * 5, CoolUtil.boundTo(elapsed * 10, 0, 1));
            seekChroma.ChromaticAberration = chromashit;
        }
    }
}