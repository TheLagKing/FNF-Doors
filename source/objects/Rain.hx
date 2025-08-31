package objects;

import flixel.math.FlxAngle;

class Rain extends FlxSpriteGroup {
    public var actualRain:FlxBackdrop;
    public var bgGradient:FlxSprite;

    public var hasBack(default, set):Bool;
    public function set_hasBack(v:Bool){
        hasBack = v;
        bgGradient.visible = hasBack;
        return hasBack;
    }

    public var rainSpeed(default, set):Float;
    public function set_rainSpeed(v:Float){
        rainSpeed = v;
        actualSpeed = v * 1000;
        actualRain.angle = -rainAngle;
        actualRain.velocity.set(FlxMath.fastSin(FlxAngle.TO_RAD * rainAngle) * actualSpeed, FlxMath.fastCos(FlxAngle.TO_RAD * rainAngle) * actualSpeed);
        return rainSpeed;
    }
    private var actualSpeed:Float;

    public var rainAngle(default, set):Float = 0;
    public function set_rainAngle(v:Float){
        rainAngle = v;
        actualRain.angle = -rainAngle;
        actualRain.velocity.set(FlxMath.fastSin(FlxAngle.TO_RAD * rainAngle) * actualSpeed, FlxMath.fastCos(FlxAngle.TO_RAD * rainAngle) * actualSpeed);
        return v;
    }

    public function new(x:Float, y:Float, width:Int, height:Int, colors:Array<FlxColor>){
        super(x, y);

        bgGradient = CoolUtil.makeGradient(width, height, colors, 1, 90, true);
        bgGradient.antialiasing = ClientPrefs.globalAntialiasing;
        add(bgGradient);

        actualRain = new FlxBackdrop(Paths.image("rain", "preload"));
        actualRain.antialiasing = ClientPrefs.globalAntialiasing;
        add(actualRain);
    }

    inline public static function toRadians(deg:Float):Float {
      return deg * Math.PI / 180;
    }
}