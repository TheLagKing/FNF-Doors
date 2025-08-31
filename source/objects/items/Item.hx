package objects.items;

import backend.storymode.InventoryManager;
import haxe.Unserializer;
import haxe.Serializer;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Item extends FlxSpriteGroup
{
    public var onPlayState:Bool = false;
    public var game:Dynamic;
    public var itemData:ItemData;
    
    public var justHovered:Bool = false;
    public var isHovered:Bool = false;

    public var inactive:Bool = false;

    public var boxSprite:FlxSprite;
    public var itemSprite:FlxSprite;
    public var durabilityBar:DurabilityBar;

    public var shake1:Null<FlxTween>;
    public var shake2:Null<FlxTween>;

    public function new(){
        super(0, 0);
        game = MusicBeatState.getState();

        this.itemData = {
            itemID: "placeholder",
            displayName: "placeholder",
            displayDesc: "placeholder",
            isPlural: false,
            itemCoinPrice: 200,
            itemKnobPrice: 30,
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: ["story", "play"]
        }

        create();
    }

    function lp(type):Dynamic{
        return Lang.getItemText(type);
    }
    
    public function create() {

    }
    
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        if  ((this.boxSprite.x + this.boxSprite.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.boxSprite.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.boxSprite.y + this.boxSprite.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.boxSprite.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            isHovered = false;
        }
    }

    public function returnGraphic(){
        var pepsi:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('storyItems/' + itemData.itemID));
        pepsi.antialiasing = ClientPrefs.globalAntialiasing;
        pepsi.scale.set(0.125, 0.125);
        return pepsi;
    }

    override function update(elapsed:Float) { super.update(elapsed); }

    //default shit is gonna be in it, if you use default shit just don't override or call super
    //but if you wanna overwrite the default shit, just don't call super lmao

    //If you item is not usable in Songs, just override the onSongUse and don't call super
    //Same thing with onStoryUse if you don't want the item usable in story mode
    //But try to minimize those, items are much more fun if you can use them everywhere

    public function preload() {
        var theMap:Map<String, Array<String>> = [
			"images" => [],
            "sounds" => [],
            "music" => []
		];

		return theMap;
	}

    //playstate shit
    public function onSongUse() {
        useCommon();
    }
    public function onSongDeath() { }

    //story specific shit
    public function onStoryUse() { 
        useCommon();
    }
    public function onStoryDeath() { }

    public function cannotUse(){
        if(shake1 != null){
            shake1.cancelChain();
            shake1.destroy();
        }
        if(shake2 != null){
            shake2.cancelChain();
            shake2.destroy();
        }
        shake1 = FlxTween.shake(itemSprite, 0.05, 0.3, XY);
        shake2 = FlxTween.shake(boxSprite, 0.05, 0.3, XY);
    }

    public function useCommon(){
        try{
            this.visible = false;
            this.active = false;
            this.kill();
        } catch(e){}
    }

    override function toString(){
		var theString = '${this.itemData.itemID} : ${this.itemData.displayName}';
		return theString;
    }
}

class DurabilityBar extends FlxSpriteGroup {
    public var barBackground:FlxSprite;
    public var barForeground:FlxSprite;
    public var divider:FlxSprite;

    private var _boundItem:Item;

    public function new(x:Float, y:Float, item:Item) {
        super(x, y);
        _boundItem = item;

        barBackground = new FlxSprite().loadGraphic(Paths.image("storyItems/durabilityBar"));
        barForeground = new FlxSprite(2, 2).makeGraphic(51, 6, 0xFFFEDEBF);
        barForeground.alpha = 0.7;
        divider = new FlxSprite(2, 2).makeGraphic(2, 6, 0xFFFEDEBF);

        barBackground.antialiasing = ClientPrefs.globalAntialiasing;
        barForeground.antialiasing = ClientPrefs.globalAntialiasing;
        divider.antialiasing = ClientPrefs.globalAntialiasing;

        add(barForeground);
        add(divider);
        add(barBackground);
    }

    override function update(elapsed:Float) {
        barForeground.scale.x = FlxMath.remapToRange(_boundItem.itemData.durabilityRemaining, 0, _boundItem.itemData.maxDurability, 0, 1);
        barForeground.origin.set(0, 3);
        updateDividerPosition();

        super.update(elapsed);
    }

    private function updateDividerPosition() {
        if(barForeground.scale.x > 0.96) divider.visible = false;
        else divider.visible = true;
        divider.x = barForeground.x + barForeground.width * barForeground.scale.x - divider.width / 2;
    }
}
