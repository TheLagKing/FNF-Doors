package states.mechanics.modifiers;

class Fading extends MechanicsManager
{
    public function new()
    {
        super();
    }

    var curTime:Float = 0;
    override function update(elapsed:Float)
    {
        game.notes.forEachAlive(function(note){
            note.copyAlpha = false;
            note.alpha = FlxMath.bound(FlxMath.fastSin(curTime), 0.2, 1);
        });
        for(note in game.unspawnNotes) {
            note.copyAlpha = false;
            note.alpha = FlxMath.bound(FlxMath.fastSin(curTime), 0.2, 1);
        }
        curTime += elapsed;
    }
}