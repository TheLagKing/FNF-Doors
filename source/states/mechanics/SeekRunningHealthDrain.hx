package states.mechanics;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class SeekRunningHealthDrain extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function update(elapsed:Float)
    {
        var elapsedShit:Float = 60*elapsed;

        if(PlayState.currentStageObject.isRunning) //self explanatory
        {
            PlayState.healthGain = 1.8;
            var healthThingYeah:Float = PlayState.currentStageObject.isRunningFast ? 0.0035 : 0.00225; //health every second I think probably

            if(PlayState.instance.health > 0.4) PlayState.instance.health -= healthThingYeah * elapsedShit * PlayState.healthLoss;
        }
    }
}