package objects.ui;

import objects.items.Item;

enum abstract DoorsBuyableWeight(String) {
    final NORMAL = "normal";
    final LOCKED = "locked";
}

class DoorsBuyable extends FlxSpriteGroup {
    public var boundItem:Item;

    public var weight:DoorsBuyableWeight = DoorsBuyableWeight.NORMAL;

    public var bg:FlxSprite;
    public var title:FlxText;
    public var description:FlxText;
    public var price:FlxText;
    public var icon:FlxSprite;
    public var boxSprite:FlxSprite;

    public var whenClicked:Void->Void;
    public var whenHovered:Void->Void;
    public var whileHovered:Void->Void;

    public function new(x:Float, y:Float, itemRef:Item, weight:DoorsBuyableWeight,
        ?onClick:Void->Void, ?onHover:Void->Void, ?whileHover:Void->Void){
        super(x, y);
        this.boundItem = itemRef;
        this.weight = weight;

        whenClicked = onClick;
        whenHovered = onHover;
        whileHovered = whileHover;

        makeDisplay();
    }

    public dynamic function makeDisplay(){
        if(bg != null)          remove(bg);
        if(title != null)       remove(title);
        if(description != null) remove(description);
        if(price != null)       remove(price);
        if(icon != null)        remove(icon);

        bg = new FlxSprite(0,0).loadGraphic(Paths.image('ui/buyable/${weight}'));

        title = new FlxText(8, 8, 206, boundItem.itemData.displayName);
        title.setFormat(FONT, 36, 0xFFFEDEBF, LEFT);

        description = new FlxText(8, 69, 206, boundItem.itemData.displayDesc);
        description.setFormat(FONT, 24, 0xFFFEDEBF, LEFT);
        while(description.height > 75) {
            description.size -= 1;
        }

        price = new FlxText(214, 12, 46, Std.string(boundItem.itemData.itemKnobPrice));
        price.setFormat(FONT, 36, 0xFFFEDEBF, RIGHT);
        
        icon = new FlxSprite(229, 69).loadGraphicFromSprite(boundItem.returnGraphic());
        icon.scale.set(0.125, 0.125);
        icon.updateHitbox();
        icon.setPosition(229, 69);
        
        boxSprite = new FlxSprite().loadGraphic(Paths.image('storyItems/box'));
        boxSprite.antialiasing = ClientPrefs.globalAntialiasing;
        boxSprite.scale.set(0.125, 0.125);
        boxSprite.updateHitbox();
        boxSprite.setPosition(229, 69);

        var textAlpha:Float = 1.0;
        switch(weight){
            case LOCKED: 
                textAlpha = 0.2;
            default:
        }

        title.alpha = textAlpha;
        description.alpha = textAlpha;
        price.alpha = textAlpha;

        add(bg);
        add(title);
        add(description);
        add(price);
        add(boxSprite);
        add(icon);

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        justStoppedHovering = false;
        if  ((this.x + bg.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + bg.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            if(isHovered){
                justStoppedHovering = true;
            }
            isHovered = false;
        }
    }

    override function update(elapsed:Float){
        checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

        if(isHovered){
            if(whileHovered != null) whileHovered();
            if(FlxG.mouse.justPressed){
                if(whenClicked != null) whenClicked();
            }
        }

        super.update(elapsed);
    }
}