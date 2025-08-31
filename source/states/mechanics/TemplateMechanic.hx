package states.mechanics;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class TemplateMechanic extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function create()
    {

    }

    override function createPost() {

    }

    override function opponentNoteHit(note:Note)
    {

    }

    override function update(elapsed:Float)
    {

    }

    override function updatePost(elapsed:Float){
        
    }
    
    override function goodNoteHit(note:Note) { 

    }
    
    override function noteMissCommon(direction:Int, note:Note = null) { 

    }

    override function noteMissEarly(direction:Int, note:Note = null) { 

    }

    override function bfBop() { 

    } //only used on eyes I think
    override function bfAnim(anim:String, forced:Bool) { 

    } //same for this

    override function onBeatHit(curBeat:Int) { 

    }

    override function onStepHit(curStep:Int) { 

    }

    override function triggerEventNote(eventName:String, value1:String, value2:String, strumTime:Float) { 

    }

    override function endSong() { 

    }
}