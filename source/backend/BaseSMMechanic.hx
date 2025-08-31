package backend;

import flixel.FlxSubState;
import flixel.FlxBasic;
import objects.Note;

class BaseSMMechanic extends FlxBasic //most of this is copied from baseStage
{
    private var game(default, set):StoryMenuState = StoryMenuState.instance;
    
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;

    public var debugMechanicsManager:Bool = true;

    public function new()
    {
        this.game = StoryMenuState.instance;
        if(this.game == null)
        {
            FlxG.log.warn('Invalid state for the event added!');
            destroy();
        }
        else 
        {
            var scriptStringToAdd:String = Std.string(Type.getClass(this));
            var i:Int = 0;

            while(this.game.activeEntities.exists(scriptStringToAdd))
            {
                i++;
                if(!this.game.activeEntities.exists(scriptStringToAdd + Std.string(i)))
                {
                    scriptStringToAdd = scriptStringToAdd + Std.string(i);
                    break;
                }
            }

            this.game.activeEntities.set(scriptStringToAdd, this);

            if(debugMechanicsManager)
            {
                trace(Std.string(scriptStringToAdd + ' loaded!'));
            }
            
            this.game.entities.push(this);
            super();
            create();
        }
    }

    inline private function set_game(value:StoryMenuState)
    {
        game = value;
        return value;
    }

    function getScript(path:String) return game.activeEntities.get(path);
    
	public var camGame(get, never):FlxCamera;
	inline private function get_camGame():FlxCamera return game.camGame;
	public var camHUD(get, never):FlxCamera;
	inline private function get_camHUD():FlxCamera return game.camHUD;

	public var health(get, never):Float;
	inline private function get_health():Float return DoorsUtil.curRun.latestHealth;
    public var door(get, never):Int;
    inline private function get_door():Int return StoryMenuState.door;
    
	inline private function add(object:FlxBasic) game.add(object);
	inline private function remove(object:FlxBasic) game.remove(object);
	inline private function insert(position:Int, object:FlxBasic) game.insert(position, object);

    public function create() { }
    public function createPost() { }
    override function update(elapsed:Float) { }
    public function updatePost(elapsed:Float) { }
    
	// Substate close/open, for pausing Tweens/Timers
	public function closeSubState() {}
	public function openSubState(SubState:FlxSubState) {}
    public function onFocus() { }
    public function onFocusLost() { }
    public function changeState() { }

    public function beatHit(curBeat:Int) { }
    public function stepHit(curStep:Int) { }
    
    public function onDoorOpen(selectedDoor:DoorAttributes) { }
    public function onItemActivate(item:String) { }
    public function onClosetEnter() { }
    public function onClosetLeave() { }
}