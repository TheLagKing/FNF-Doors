package states.mechanics.modifiers;

class Overdrive extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function createPost(){
        
    }

    var curTime:Float = 0;
    var randomSpeed:Float;
    override function update(elapsed:Float)
    {
        curTime += elapsed;
        game.songSpeed = FlxMath.remapToRange(smoothNoise1D(curTime * 0.5 + noiseSeed), 0.0, 1.0, 2.6, 4.3);
        
    }
    
    var noiseSeed:Float = FlxG.random.float(0, 1000);
    function smoothNoise1D(t:Float):Float {
        var i:Int = Std.int(t);
        var f:Float = t - i;

        var a:Float = pseudoRandom(i);
        var b:Float = pseudoRandom(i + 1);

        var smoothF:Float = f * f * (3 - 2 * f);
        return a + smoothF * (b - a);
    }

    function pseudoRandom(x:Int):Float {
        function fract(x:Float):Float {
            return x - Math.floor(x);
        }

        return fract(Math.sin(x * 127.1) * 43758.5453);
    }
}