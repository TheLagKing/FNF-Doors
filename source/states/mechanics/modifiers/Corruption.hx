package states.mechanics.modifiers;

class Corruption extends MechanicsManager
{
    public function new()
    {
        super();
    }

    var timeUntilStop:Float = 0; //this is dumb honestly, will change later
    override function onBeatHit(beat:Int)
    {
        if(beat % FlxG.random.int(4,8,[7]) == 0) timeUntilStop = 0.1 + PlayState.storyDifficulty*0.25;
    }

    override function updatePost(elapsed:Float)
    {
        PlayState.instance.camHUD.alpha = timeUntilStop > 0 ? 0.0001 : 1;
        timeUntilStop -= elapsed;
    }
}