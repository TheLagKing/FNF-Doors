package backend.storymode;

import haxe.Unserializer;
import haxe.Serializer;
import flixel.util.FlxSort;
import openfl.display.BlendMode;
import objects.items.*;

typedef ItemData = {
    var itemID:String;

    var displayName:String;
    var displayDesc:String;
    var isPlural:Bool;
    var itemCoinPrice:Int;
    var itemKnobPrice:Int;
    var itemSlot:Int;

    var durabilityRemaining:Float;
    var maxDurability:Float;

    var ?statesAllowed:Array<String>;
}

class InventoryManager {
    public var items:Array<Null<ItemData>> = [];

    public function new(){
        if(items == null) items = [];
    }

    public function addItem(item:Dynamic):Bool {
        if(item == null || item.itemData == null || items.filter(function(x) {return x != null;}).length >= 6) return false;

        for(i in items){
            if(i == null){
                item.itemData.itemSlot = items.indexOf(i);
                items[items.indexOf(i)] = item.itemData;
                return true;
            }
        }

        item.itemData.itemSlot = items.length;
        items.push(item.itemData);
        return true;
    }

    public function removeItem(item:Dynamic):Bool {
        for(it in items){
            if(it == null) continue;
            if(it.itemID == item.itemID && it.itemSlot == item.itemSlot){
                items[items.indexOf(it)] = null;
                return true;
            }
        } return false;
    }

    public function getItemByStringID(name:String):Null<Dynamic> {
        for (item in items) {
            if (item.itemID == name) {
                return item;
            }
        }
        return null;
    }

	public function toString(){
		var theString = "";
		for(i in 0...6){
			theString += 'Item Slot ${i + 1} : ${items[i] == null ? "None" : items[i].itemID} \n';
		}
		return theString;
	}

    public static function fromItemIDtoItem(id:String):Dynamic{
        switch(id){
            case "bandages":
                return new Bandage();
            case "a60":
                return new A60();
            case "candle":
                return new Candle();
            case "crucifix":
                return new Crucifix();
            case "flashlight":
                return new Flashlight();
            case "error":
                return new Glitch();
            case "lighter":
                return new Lighter();
            case "vitamins":
                return new Vitamins();
            default:
                return new Item();
        }
    }
}