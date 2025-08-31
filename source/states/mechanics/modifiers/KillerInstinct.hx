package states.mechanics.modifiers;

class KillerInstinct extends MechanicsManager
{
    public function new()
    {
        super();
    }

    var timeUntilStop:Float = 0;
    override function noteMissCommon(direction:Int, note:Note = null)
    {
        timeUntilStop = 5;
    }

    override function goodNoteHit(note:Note)
    {
        if(timeUntilStop > 0)
        {
            var extraYeah:Float = note.hitHealth * PlayState.healthGain * note.ratingMod; //same, but removed the /1.5
            game.health += extraYeah;
        }
    }

    override function update(elapsed:Float)
    {
        timeUntilStop -= elapsed;
    }
}