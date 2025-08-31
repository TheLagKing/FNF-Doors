package backend.storymode;

import haxe.Unserializer;
import haxe.Serializer;
import backend.metadata.StoryModeMetadata;

typedef Painting = {
	side:String,
	data:PaintingData,
	pattern:String,
}

typedef Furniture = {
	name:String,
	?sprite:StoryModeSpriteHoverable,
	side:String,
	specificAttributes:Dynamic,
	?isDarkBlocked:Bool
}

typedef ClosetAttributes = {
	hasJack:Bool,
	isOpened:Bool,
	jackSong:String
}

typedef DrawerAttributes = {
	hasItem:Bool,
	theItem:String,
	itemDurability:Int,
	isOpened:Bool,
	hasTimothy:Bool,
	timSong:String,
	howMuchMoney:Int
}

typedef TableAttributes = {
	hasPaper:Bool,
	paperModel:Int,
	?paperSpr:StoryModeSpriteHoverable,
	hasBooks:Bool,
	booksModel:Int,
	?bookTopic:String,
	?bookSpr:StoryModeSpriteHoverable
}

typedef DoorAttributes = {
	doorNumber:Int,
	?doorSpr:StoryModeSpriteHoverable,
	?panelGroup:FlxSpriteGroup,
	side:String,
	isLocked:Bool,
	song:String,
	?hasBeenOpenedOnce:Int,
	?isDarkBlocked:Bool
}

typedef RoomAttributes = {
	bossType:String,
	roomType:String,
	roomColor:String,
	isDark:Bool,
	?seekData:Array<NearSeekData>,
}

typedef EntityData = {
	var name:String;
	var className:String;
}

class StoryRoom{
	public var room:RoomAttributes;

	public var roomPostfixes:Array<StoryRoom> = [];

	public var paintings:Array<Painting> = [];
	public var furniture:Array<Furniture> = [];

	public var leftDoor:DoorAttributes;
	public var rightDoor:DoorAttributes;

	public var entitiesInRoom:Array<EntityData> = [];

	public var musicData:Null<MusicData>;

	public function new(?map:Map<String, Dynamic>){
		if(map != null){
			for(att in map.keys()){
				Reflect.setField(this, att, map.get(att));
			}
		}
	}

	public function getSong(chosenDoor:Int){
		var arr:Array<Dynamic> = [];
		if(chosenDoor == 0){
			arr = [leftDoor.song, false];
		} else {
			arr = [rightDoor.song, false];
		}
		return arr;
	}

	public function gaySerialize(){
		var serializer = new Serializer();
		serializer.serialize(this);
		return serializer.toString();
	}

	public function gayUnserialize(obj:String){
		var unserializer = new Unserializer(obj);
		var gamer:Dynamic = unserializer.unserialize();
		
		applyNewRoom(gamer);
	}

	public function applyNewRoom(room:StoryRoom){
		for(att in Reflect.fields(room)){
			Reflect.setField(this, att, Reflect.field(room, att));
		}
	}

	public function toString(){
		var theString:String = "";

		theString += "["+room.bossType +" | ";
		theString += ""+room.roomType +"] - ";
		theString += "Furniture : ["+furniture +"] ";
		theString += "Paintings : ["+paintings +"] ";
		theString += leftDoor.doorNumber+" => ";
		theString += leftDoor.song+" | ";
		theString += rightDoor.doorNumber+" => ";
		theString += rightDoor.song;
		return theString;
	}
}