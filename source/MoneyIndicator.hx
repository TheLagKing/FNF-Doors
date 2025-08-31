package;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxTextNew as FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;

class MoneyIndicator extends FlxSpriteGroup{
    public var moneyIcon:FlxSprite;
    public var moneyCounter:FlxText;

    var isKnobs:Bool = false;

    public function new(x, y, knobs:Bool){
        super(x,y);
        moneyIcon = new FlxSprite(0, 0).loadGraphic(Paths.image(knobs ? "smallKnob" : "smallGold"));
        moneyIcon.antialiasing = ClientPrefs.globalAntialiasing;
        add(moneyIcon);
    
        moneyCounter = new FlxText(moneyIcon.width+10, 3, 0, Std.string(knobs ? DoorsUtil.knobs : DoorsUtil.curRun.runMoney), 32);
        moneyCounter.setFormat(FONT, 24, FlxColor.WHITE);
        moneyCounter.antialiasing = ClientPrefs.globalAntialiasing;
        add(moneyCounter);

        isKnobs = knobs;
    }

    public function fadeOut(){
        FlxTween.tween(moneyIcon, {alpha: 0.00001}, 1.0, {ease: FlxEase.quartOut, startDelay: 2.0});
        FlxTween.tween(moneyCounter, {alpha: 0.00001}, 1.0, {ease: FlxEase.quartOut, startDelay: 2.0});
    }

    public function fadeIn(){
        FlxTween.tween(moneyIcon, {alpha: 1}, 1.0, {ease: FlxEase.quartOut});
        FlxTween.tween(moneyCounter, {alpha: 1}, 1.0, {ease: FlxEase.quartOut});
    }

    public function addMoney(?amount:Int){
        if(isKnobs){
            FlxTween.num(DoorsUtil.knobs-amount, DoorsUtil.knobs, 1, {ease:FlxEase.quartOut}, function(f:Float){
                this.moneyCounter.text = Std.string(Math.round(f));
            });
        } else {
            FlxTween.num(DoorsUtil.curRun.runMoney-amount, DoorsUtil.curRun.runMoney, 1, {ease:FlxEase.quartOut}, function(f:Float){
                this.moneyCounter.text = Std.string(Math.round(f));
            });
        }
    }
}

class MoneyPopup extends FlxSpriteGroup{
    public var onFinish:Void->Void = null;
    public var moneyCounter:FlxText;
    var isKnobs:Bool = false;
    var canLerp:Bool = false;
    var attachedCounter:Dynamic;
    var amt:Int;

    public function new(x:Float, y:Float, amount:Int, ?attachedCounter:MoneyIndicator = null, ?knobs:Bool =false, ?applyKnobModifier:Bool = true, ?cam:FlxCamera=null) {
        super(x, y);
        isKnobs = knobs;
        this.attachedCounter = attachedCounter;
        amt = amount;

        if(knobs){
            DoorsUtil.addKnobs(amt, applyKnobModifier ? (DoorsUtil.curRun.runKnobModifier) : 1);
        } else {
            DoorsUtil.spendMoney(-amount);
        }

        moneyCounter = new FlxText(50, 3, 0, Std.string(amount), 32);
        moneyCounter.setFormat(FONT, 24, 0xFF00FF00);
        if(amount != 0){
            add(moneyCounter);
        }
        moneyCounter.text = (amt < 0 ? "- " : "+ ") + Std.string(amount);
        moneyCounter.antialiasing = ClientPrefs.globalAntialiasing;

        if(camera != null){
		    this.cameras = [cam];
        } else {
            cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        }
        alpha = 0;

        startTweens();
    }

    function startTweens(){
        new FlxTimer().start(2.3, function(tmr:FlxTimer)
            {
                MenuSongManager.playSound(('GoldIncrease'), 0.9);
            });

        if(isKnobs){
            this.y += 35;
        } else {
            this.y -= 35;
        }
        FlxTween.tween(this, {alpha:1}, 0.5, {onComplete: function(twn){
            FlxTween.tween(this, {y: attachedCounter.y, alpha: 0.00001}, 0.5, {
                startDelay: 2.0,
                ease: FlxEase.quartOut,
                onComplete: function (t){
                    remove(this);
                    if(onFinish != null) onFinish();
                }
            });
            FlxTween.color(moneyCounter, 3.0, 0xFF00FF00, 0xFFFFFFFF, {startDelay: 1.0, ease: FlxEase.quartOut});
            new FlxTimer().start(2.0, function(tmr){
                attachedCounter.addMoney(amt);
            });
        }});
    }
}