package objects;

import openfl.display.BlendMode;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxPieDial;
import openfl.display.BitmapData;
import objects.items.A60;
import openfl.display.Sprite;
import flixel.input.mouse.FlxMouse;
import flixel.addons.display.FlxRadialGauge;

enum DoorsMouseActions {
    NONE;
    LOOKING;
    POINTING;
}

class DoorsMouse extends FlxSpriteGroup{
    var _bitmapDataMap:Map<String, FlxGraphic> = [];

    public var _cursor:FlxSprite;
    var _circularPieDialThing:FlxRadialGauge;

    public var longActionTween:FlxTween;
    
    public var longActionEnd2Tween:FlxTween;
    public var longActionEndTween:FlxTween;

    var canDoLongAction:Bool = true;

    public var currentAction:DoorsMouseActions = NONE;


    public var isTransparent:Bool = false;
    
    public function new(){
        super(0,0);
        this.scrollFactor.set(0,0);

        for(str in [
            "idle", "look", "pressed", "point",
            "idle-trans", "look-trans", "pressed-trans", "point-trans",
        ]){
            var sprite = new FlxSprite().loadGraphic(Paths.image('mouse/${str}'));
            Paths.excludeBitmap(sprite.graphic);
            sprite.antialiasing = ClientPrefs.globalAntialiasing;

            _bitmapDataMap.set(str, sprite.graphic);
        }

        _cursor = new FlxSprite(-21,-16);
        _cursor.loadGraphic(_bitmapDataMap.get("idle").bitmap);

        _circularPieDialThing = new FlxRadialGauge(0,0, Paths.image("mouse/mouseCircle"));
        Paths.excludeBitmap(_circularPieDialThing.graphic);
        add(_circularPieDialThing);
        _circularPieDialThing.alpha = 0.00001;
        _circularPieDialThing.antialiasing = ClientPrefs.globalAntialiasing;
        _circularPieDialThing.blend = BlendMode.ADD;
    }

    public function setCursorType(bitmapName:String){
        if(isTransparent) bitmapName += "-trans";
        _cursor.loadGraphic(_bitmapDataMap.get(bitmapName).bitmap);
    }

    public function startLongAction(duration:Float, callback:Void->Void){
        if(longActionEndTween != null) longActionEndTween.cancel();
        if(longActionEnd2Tween != null) longActionEnd2Tween.cancel();
        longActionTween = FlxTween.num(0.0, 1.0, duration, {ease: FlxEase.sineInOut, onComplete: function(twn){
            callback();
            onStopLongAction();
        }}, function(flt) {
            _circularPieDialThing.amount = flt;
            _circularPieDialThing.alpha = FlxMath.bound(flt*5, 0, 1);
        });
    }

    public function onStopLongAction(){
        longActionEndTween = FlxTween.tween(_circularPieDialThing, {alpha: 0.00001}, 0.4 * _circularPieDialThing.amount, {ease: FlxEase.circOut, onComplete: function(twn){
            canDoLongAction = true;
        }});
        longActionEnd2Tween = FlxTween.num(_circularPieDialThing.amount, 0.0, 0.4 * _circularPieDialThing.amount, {ease: FlxEase.circOut}, function(flt) {
            if(_circularPieDialThing != null) _circularPieDialThing.amount = flt;
        });
    }

    override function update(elapsed:Float) {
        switch(currentAction){
            case NONE:
                if(FlxG.mouse.pressed){
                    setCursorType("pressed");
                    FlxG.mouse.load(_cursor.pixels, 1, -21, -16);
                } else {
                    setCursorType("idle");
                    FlxG.mouse.load(_cursor.pixels, 1, -21, -16);
                }
            case LOOKING:
                setCursorType("look");
                FlxG.mouse.load(_cursor.pixels, 1, -21, -16);
            case POINTING:
                setCursorType("point");
                FlxG.mouse.load(_cursor.pixels, 1, -4, -12);
        }
        _circularPieDialThing.setPosition(
            FlxG.mouse.getScreenPosition(this.cameras[0]).x - 30,
            FlxG.mouse.getScreenPosition(this.cameras[0]).y - 25
        );
        if(FlxG.mouse.justReleased && longActionTween != null){
            longActionTween.cancel();
            onStopLongAction();
        }

        super.update(elapsed);
    }
}