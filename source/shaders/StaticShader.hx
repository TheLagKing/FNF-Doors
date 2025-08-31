package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class StaticShader extends FlxBasic{
    public var shader(default, null):StaticShaderGLSL = new StaticShaderGLSL();

    public var alpha(default, set):Float = 0.0;
    public var iTime:Float = 0.0;

    public function new():Void{
        super();
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }

    public function set_alpha(v:Float):Float{
        alpha = v;
        shader.alpha.value = [v];
        return alpha;
    }
}

class StaticShaderGLSL extends FlxShader{
    @:glFragmentSource('
        #pragma header
        uniform float iTime;
        vec2 uv = openfl_TextureCoordv.xy;
        const float PHI = 1.61803398874989484820459;
        uniform float alpha;
      
        float gold_noise(in vec2 xy, in float seed)
        {
          return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
        }
      
        void main()
        {
            float seed  = fract(iTime);
            gl_FragColor= vec4 (gold_noise(uv, seed+0.1),
                                gold_noise(uv, seed+0.2),
                                gold_noise(uv, seed+0.3),
                                alpha);
        }
    ')

    public function new(){
        super();
    }
}