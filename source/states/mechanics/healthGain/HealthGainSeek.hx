package states.mechanics.healthGain;

class HealthGainSeek extends MechanicsManager
{
    public var healthDrainMult:Float = 0;

    public function new(healthDrain:Float)
    {
        this.healthDrainMult = healthDrain;

        super();
    }

    override function createPost()
    {
        PlayState.healthGain = 0;
    }

    override function goodNoteHit(note:Note)
    {
        var healthModifierLoss:Float = 1;

		if(DoorsUtil.modifierActive(25))
        {
			healthModifierLoss *= 2;
		}
		else if(DoorsUtil.modifierActive(26))
        {
			healthModifierLoss /= 2;
		}

        var multCalc:Float = (note.isSustainNote ? healthDrainMult/4 : healthDrainMult) * healthModifierLoss;
        game.health += 0.0085 * multCalc;
    }
}