package states.mechanics.modifiers;

class JackShit extends MechanicsManager
{
    var goBackMap:Map<String, Array<Int>> =
    [
        'invader' => [264]
    ];

    public function new()
    {
        super();
    }

    override function onBeatHit(curBeat:Int)
    {
        if(goBackMap.exists(song))
            if(goBackMap.get(song).contains(curBeat)) PlayState.instance.health = DoorsUtil.maxHealth/2;
    }
}