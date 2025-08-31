package objects.ui;

import flixel.math.FlxPoint;

class DoorsMenu extends FlxSpriteGroup {

    public var bg:FlxSprite;
    public var title:FlxText;
    var hasClose:Bool = true;
    var closeHitbox:StoryModeSpriteHoverable;

    public var closeFunction:Void->Void;
    public var whileHoveringClose:Void->Void;

    public function new(x:Float, y:Float, specificPath:String, menuName:String, ?hasClose:Bool = true, ?closePoint:FlxPoint){
        super(x, y);

        this.hasClose = hasClose;

        bg = new FlxSprite().loadGraphic(Paths.image('menus/${specificPath}/master'));
        add(bg);

        title = new FlxText(18, 14, menuName, 40);
        title.setFormat(FONT, 40, 0xFFFEDEBF);
        add(title);

        if(hasClose){
            if(closePoint != null) closeHitbox = cast new StoryModeSpriteHoverable(closePoint.x, closePoint.y, "").makeGraphic(50, 50);
            else closeHitbox = cast new StoryModeSpriteHoverable(606, 19, "").makeGraphic(50, 50);
            closeHitbox.alpha = 0.00001;
            add(closeHitbox);
        }

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

    override function update(elapsed:Float){
        if(hasClose){
            closeHitbox.checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);
            if(closeHitbox.isHovered){
                if(whileHoveringClose != null) whileHoveringClose();
                if(FlxG.mouse.justPressed && closeFunction != null) closeFunction();
            }
        }

        super.update(elapsed);
    }
}