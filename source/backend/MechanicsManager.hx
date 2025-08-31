package backend;

import flixel.FlxBasic;
import objects.Note;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;

class MechanicsManager //most of this is copied from baseStage
{
    public var onPlayState:Bool = false;
    private var game(default, set):PlayState = PlayState.instance;
    private var song:String; //prob just going to be used on eyes
    private var type:String;
    public var debugMechanicsManager:Bool = true;

    public function new()
    {
        this.game = PlayState.instance;
        if(this.game == null)
        {
            FlxG.log.warn('Invalid state for the event added!');
        }
        else 
        {
            var scriptStringToAdd:String = Std.string(Type.getClass(this));
            var i:Int = 0;

            while(this.game.activeMechanics.exists(scriptStringToAdd))
            {
                i++;
                if(!this.game.activeMechanics.exists(scriptStringToAdd + Std.string(i)))
                {
                    scriptStringToAdd = scriptStringToAdd + Std.string(i);
                    break;
                }
            }

            this.game.activeMechanics.set(scriptStringToAdd, this);
            this.song = PlayState.SONG.song;

            if(debugMechanicsManager)
            {
                trace(Std.string(scriptStringToAdd + ' loaded!'));
            }

            create();
        }
    }

    inline private function set_game(value:PlayState)
    {
        onPlayState = (Std.isOfType(value, states.PlayState));
        game = value;
        return value;
    }
    
	function add(object:FlxBasic) game.add(object);
	function remove(object:FlxBasic) game.remove(object);
	function insert(position:Int, object:FlxBasic) game.insert(position, object);
    function getScript(path:String) return game.activeMechanics.get(path);
    //function pushShader(shader:FlxShader, cameraToDoItOn:FlxCamera) game.pushShader(shader, cameraToDoItOn);

    public function create() { }
    public function createPost() { }
    public function update(elapsed:Float) { }
    public function updatePost(elapsed:Float) { }
    public function opponentNoteHit(note:Note) { }
    public function goodNoteHit(note:Note) { }
    public function noteMissCommon(direction:Int, note:Note = null) { }
    public function noteMissEarly(direction:Int, note:Note = null) { }
    public function bfBop() { }
    public function bfAnim(anim:String, forced:Bool) { }
    public function onBeatHit(curBeat:Int) { }
    public function onStepHit(curStep:Int) { }
    public function triggerEventNote(eventName:String, value1:String, value2:String, strumTime:Float) { }
    public function endSong():Bool { return false; } //if you returns true the ending stops
    public function onCountdownStarted() { }
    public function onSongStart() { }
    public function noteSpawn(note:Note) { }
    public function onDeath() { }

    //Functions that do something
    public function playAnim(object:FlxSprite, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
    {
        object.animation.play(name, forced, reverse, startFrame);
    }

    public function triggerEvent(name:String, arg1:String, arg2:String)
    {
        PlayState.instance.triggerEventNote(name, arg1, arg2, 0);
    }
}