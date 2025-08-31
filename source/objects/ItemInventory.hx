package objects;

import objects.items.Item.DurabilityBar;
import backend.storymode.InventoryManager;
import haxe.Unserializer;
import haxe.Serializer;
import flixel.util.FlxSort;
import openfl.display.BlendMode;
import objects.items.*;

enum InvLayout {
    HORIZONTAL;
    VERTICAL;
}

class ItemInventory extends FlxSpriteGroup {
    public var items:FlxTypedSpriteGroup<Item>;
    public var layout:InvLayout;

    var itemsBG:FlxSprite;

    var state:Null<String>;

    public function new(type:InvLayout, state:MusicBeatState) {
        super();
        items = new FlxTypedSpriteGroup<Item>();
        layout = type;

        switch(type){
            case HORIZONTAL:
                itemsBG = new FlxSprite(400, 640).loadGraphic(Paths.image('storyItems/inventory_box'));
            case VERTICAL:
                itemsBG = new FlxSprite(-33, 120).loadGraphic(Paths.image('storyItems/inventory_box2'));
        }
        itemsBG.antialiasing = ClientPrefs.globalAntialiasing;
        add(itemsBG);
        add(items);

        if(Std.isOfType(state, PlayState)) this.state = "play";
        if(Std.isOfType(state, StoryMenuState)) this.state = "story";

        redrawItems();

        for(item in items.members){
            var map:Map<String, Array<String>> = item.preload();
            
            for(img in map.get("images")){
				Paths.image(img);
            }
            for(snd in map.get("sounds")){
				Paths.sound(snd);
            }
            for(mus in map.get("music")){
				Paths.music(mus);
            }
        }
    }

    override function update(elapsed:Float){
        super.update(elapsed);

        //TODO: Item Dragging & Removing
    }

    public function redrawItems(){
        items.forEach(function(it){
            it.kill();
            items.remove(it);
            it.destroy();
        });
        this.items.clear();

        for(i in 0...DoorsUtil.curRun.curInventory.items.length){
            if(DoorsUtil.curRun.curInventory.items[i] == null) continue;
            var item:Item = InventoryManager.fromItemIDtoItem(DoorsUtil.curRun.curInventory.items[i].itemID);
            item.itemData = DoorsUtil.curRun.curInventory.items[i];
            addItem(item, true, i);

            item.itemSprite = new FlxSprite().loadGraphic(Paths.image('storyItems/' + DoorsUtil.curRun.curInventory.items[i].itemID));
            item.itemSprite.antialiasing = ClientPrefs.globalAntialiasing;

            item.boxSprite = new FlxSprite().loadGraphic(Paths.image('storyItems/box'));
            item.boxSprite.antialiasing = ClientPrefs.globalAntialiasing;

            item.add(item.boxSprite);
            item.add(item.itemSprite);

            item.itemSprite.scale.set(0.125, 0.125);
            item.itemSprite.updateHitbox();
            item.boxSprite.scale.set(0.125, 0.125);
            item.boxSprite.updateHitbox();

            if(item.itemData.maxDurability > 1){
                item.durabilityBar = new DurabilityBar(0, item.boxSprite.height + 1, item);
                item.add(item.durabilityBar);
            }

            item.cameras = cameras;
            if(state != null && item.itemData.statesAllowed != null){
                if( (Std.isOfType(state, PlayState)      && !item.itemData.statesAllowed.contains("play")) || 
                    (Std.isOfType(state, StoryMenuState) && !item.itemData.statesAllowed.contains("story"))
                )
                    item.color = FlxColor.fromHSB(0, 0, 0.5);
            }

            if(state == "play"){
                item.onPlayState = true;
            } else item.onPlayState = false;

            if(layout == VERTICAL){
                item.setPosition(
                    -33 + 40,
                    120 + 20 + (77 * item.itemData.itemSlot)
                );
            } else if (layout == HORIZONTAL){
                item.setPosition(
                    414 + (79 * item.itemData.itemSlot),
                    654
                );
            }
        }
    }

    public function addItem(item:Item, ?fromRedraw:Bool = false, ?overrideItemSlot:Int = -1):Void {
        for(i in 0...DoorsUtil.curRun.curInventory.items.length){
            var itemData = DoorsUtil.curRun.curInventory.items[i];
            
            if(itemData == null){
                if(fromRedraw) item.itemData.itemSlot = overrideItemSlot;
                else item.itemData.itemSlot = i;
                items.add(item);
                return;
            }
        }

        if(items.members.length > 6){
            //Need to change items!
        } else {
            if(fromRedraw) item.itemData.itemSlot = overrideItemSlot;
            else item.itemData.itemSlot = items.length;
            items.add(item);
        }
    }

    public function removeItem(item:Item):Bool {
        items.remove(item);
        DoorsUtil.curRun.curInventory.removeItem(item.itemData);
        redrawItems();
        return true;
    }
}