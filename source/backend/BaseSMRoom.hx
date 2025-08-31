package backend;

import flixel.FlxSubState;
import flixel.FlxBasic;
import objects.Note;
import backend.storymode.StoryRoom;

class BaseSMRoom extends FlxBasic //most of this is copied from baseStage
{
    private var game(default, set):StoryMenuState = StoryMenuState.instance;
    
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;

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
            this.game.rooms.push(this);
            super();
            create();
        }
    }

    inline private function set_game(value:StoryMenuState)
    {
        game = value;
        return value;
    }
    
	public var camGame(get, never):FlxCamera;
	inline private function get_camGame():FlxCamera return game.camGame;
	public var camHUD(get, never):FlxCamera;
	inline private function get_camHUD():FlxCamera return game.camHUD;

	public var health(get, never):Float;
	inline private function get_health():Float return DoorsUtil.curRun.latestHealth;
    public var door(get, never):Int;
    inline private function get_door():Int return StoryMenuState.door;
    
	public var room(get, never):StoryRoom;
	inline private function get_room():StoryRoom return game.room;

    @:isVar public var furniture(get, set):Array<Furniture> = [];
    inline private function get_furniture() return game.furniture;
    inline private function set_furniture(arr:Array<Furniture>) {
        furniture = arr;
        game.furniture = furniture;
        return furniture;
    }

    @:isVar public var doors(get, set):Array<DoorAttributes> = [];
    inline private function get_doors() return game.doors;
    inline private function set_doors(arr:Array<DoorAttributes>) {
        doors = arr;
        game.doors = doors;
        return doors;
    }
    
	var clickableThings(get, set):Array<StoryModeSpriteHoverable>;
    inline private function get_clickableThings() return game.clickableThings;
    inline private function set_clickableThings(arr:Array<StoryModeSpriteHoverable>) {
        game.clickableThings = clickableThings;
        return game.clickableThings;
    }
    
	@:isVar var itemInventory(get, set):ItemInventory;
    inline private function get_itemInventory() return game.itemInventory;
    inline private function set_itemInventory(arr:ItemInventory) {
        itemInventory = arr;
        game.itemInventory = itemInventory;
        return itemInventory;
    }
    
	inline private function add(object:FlxBasic) game.add(object);
	inline private function remove(object:FlxBasic) game.remove(object);
	inline private function insert(position:Int, object:FlxBasic) game.insert(position, object);

    // This one needs to be overriden !! It's used by the darkness system.
    // If returns false, then assume there is no door, otherwise return a FlxSprite containing the dark door at the correct x/y position.
    public function getDarkDoor(?side:String):Dynamic { return false; }

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
    public function onDoorOpenPost(selectedDoor:DoorAttributes) { }
    public function onItemActivate(item:String) { }

    public function darkCreate() { }
    public function darkCreatePost() { }
    public function onHandleFurniture(furSprite:Dynamic, furName:String, side:String, specificAttributes:Dynamic, elapsed:Float) {}
    public function onAmbiance(justEntered:Bool) {}
}