package shaders;

import haxe.xml.Access;
import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class GlitchPosterize extends FlxBasic{
    public var shader(default, null):GlitchPosterizeGLSL = new GlitchPosterizeGLSL();

    var iTime:Float = 0;
    public var amount(default, set):Float = 0.0;

    public function new():Void{
        super();
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }

    public function set_amount(v:Float):Float{
        amount = v;
        shader.GlitchAmount.value = [v];
        return amount;
    }
}

class GlitchPosterizeGLSL extends FlxShader{
    @:glFragmentSource('
        #pragma header
        
        uniform float iTime;
        uniform float GlitchAmount = 0.6;

        vec4 posterize(vec4 color, float numColors)
        {
            return floor(color * numColors - 0.5) / numColors;
        }

        vec2 quantize(vec2 v, float steps)
        {
            return floor(v * steps) / steps;
        }

        float dist(vec2 a, vec2 b)
        {
            return sqrt(pow(b.x - a.x, 2.0) + pow(b.y - a.y, 2.0));
        }

        void main()
        {   
            float theAlpha = flixel_texture2D(bitmap,openfl_TextureCoordv.xy).a;
            float amount = pow(GlitchAmount, 2.0);
            vec2 pixel = 1.0 / openfl_TextureSize.xy;
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
            float t = mod(mod(iTime, amount * 100.0 * (amount + 0.5)) * 109.0, 1.0);
            vec4 postColor = posterize(color, 16.0);
            vec4 a = posterize(flixel_texture2D(bitmap, quantize(openfl_TextureCoordv.xy, 64.0 * t) + pixel * (postColor.rb + vec2(.5)) * 100.0), 5.0).rbga;
            vec4 b = posterize(flixel_texture2D(bitmap, quantize(openfl_TextureCoordv.xy, 32.0 - t) + pixel * (postColor.rg + vec2(.5)) * 1000.0), 4.0).gbra;
            vec4 c = posterize(flixel_texture2D(bitmap, quantize(openfl_TextureCoordv.xy, 16.0 + t) + pixel * (postColor.rg + vec2(.5)) * 20.0), 16.0).bgra;
            gl_FragColor = mix(
                            flixel_texture2D(bitmap, 
                                    openfl_TextureCoordv.xy + amount / (quantize((a * t - b + c - (t + t / 2.0) / 10.0).rg, 16.0) - vec2(.5)) * pixel * 100.0),
                            (a + b + c) / 3.0,
                            (0.5 - (dot(color, postColor) - 1.5)) * amount);
                            
            gl_FragColor.a = theAlpha;
        }
    ')

    public function new(){
        super();
    }
}