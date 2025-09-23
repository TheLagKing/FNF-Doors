package mobile.controls;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

/**
 * ...
 * @author Idklool
 */
class HitBox extends FlxSpriteGroup
{
    public var buttonLeft:FlxButton;
    public var buttonDown:FlxButton;
    public var buttonUp:FlxButton;
    public var buttonRight:FlxButton;
    public var buttonExtraOne:FlxButton;
    public var buttonExtraTwo:FlxButton;

    public function new()
    {
        super();
        buttonLeft = buttonDown = buttonUp = buttonRight = buttonExtraOne = buttonExtraTwo = new FlxButton(0, 0);
        
        addButtons();
        scrollFactor.set();
    }

    function addButtons() {
        var canExtraButton:Bool = Options.extraControls >= 1;
        var canSecondExtraButton:Bool = Options.extraControls == 2;
        
        var buttonHeight:Int = canExtraButton ? Std.int(FlxG.height * 0.75) : FlxG.height;
        var x:Int = 0;
        var y:Int = canExtraButton ? (Options.extraControlsTop ? Std.int(FlxG.height / 4) : 0) : 0;
        var extraY:Int = canExtraButton ? (Options.extraControlsTop ? 0 : Std.int(FlxG.height * 0.75)) : 0;

        add(buttonLeft = createHitbox(x, y, Std.int(FlxG.width / 4), buttonHeight, '0xC24B99'));
        add(buttonDown = createHitbox(FlxG.width / 4, y, Std.int(FlxG.width / 4), buttonHeight, '0x00FFFF'));
        add(buttonUp = createHitbox(FlxG.width / 2, y, Std.int(FlxG.width / 4), buttonHeight, '0x12FA05'));
        add(buttonRight = createHitbox(FlxG.width * 3 / 4, y, Std.int(FlxG.width / 4), buttonHeight, '0xF9393F'));

        if (canExtraButton) {
            if (canSecondExtraButton) {
                buttonExtraOne = createHitbox(0, extraY, Std.int(FlxG.width / 2), Std.int(FlxG.height * 0.25), '0xFFFFFF');
                add(buttonExtraOne);
                buttonExtraTwo = createHitbox(FlxG.width / 2, extraY, Std.int(FlxG.width / 2), Std.int(FlxG.height * 0.25), '0xFFFF00');
                add(buttonExtraTwo);
            } else {
                buttonExtraOne = createHitbox(0, extraY, FlxG.width, Std.int(FlxG.height * 0.25), '0xFFFFFF');
                add(buttonExtraOne);
            }
        }
    }

    function createHitbox(x:Float, y:Float, width:Int, height:Int, color:String)
    {
        var button:FlxButton = new FlxButton(x, y);
        button.makeGraphic(width, height, FlxColor.fromString(color));
        
        var baseAlpha = Options.hitboxAlpha;
        var pressedAlpha = Math.min(baseAlpha + 0.149, 1.0);
        
        button.alpha = baseAlpha;

        button.onDown.callback = () -> button.alpha = pressedAlpha;
        button.onUp.callback = () -> button.alpha = baseAlpha;
        button.onOut.callback = button.onUp.callback;

        return button;
    }
    
    public function updateAlpha() {
        var baseAlpha = Options.hitboxAlpha;
        
        if (buttonLeft != null) buttonLeft.alpha = baseAlpha;
        if (buttonDown != null) buttonDown.alpha = baseAlpha;
        if (buttonUp != null) buttonUp.alpha = baseAlpha;
        if (buttonRight != null) buttonRight.alpha = baseAlpha;
        if (buttonExtraOne != null) buttonExtraOne.alpha = baseAlpha;
        if (buttonExtraTwo != null) buttonExtraTwo.alpha = baseAlpha;
    }

    public static function toggleExtraControls():Void {
        Options.extraControls = (Options.extraControls + 1) % 3;
        FlxG.resetState();
    }

    override public function destroy()
    {
        super.destroy();
        buttonLeft = buttonDown = buttonUp = buttonRight = buttonExtraOne = buttonExtraTwo = null;
    }
}
