package states.mechanics;

class NoDeath extends MechanicsManager
{
    public var skipOnDeath:Bool = false;

    public function new()
    {
        super();
    }

    override function onDeath(){
        PlayState.instance.stopDeathEarly = true;
        PlayState.instance.health = DoorsUtil.maxHealth;
        
        if(skipOnDeath){
            PlayState.instance.startingSong = true;
            PlayState.instance.inCutscene = true;
            PlayState.instance.endSong();
        }
    }
}