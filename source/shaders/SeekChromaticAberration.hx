package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class SeekChromaticAberration extends FlxBasic{
    public var shader(default, null):SeekChromaticAberrationGLSL = new SeekChromaticAberrationGLSL();

    var iTime:Float = 0;
    
    public var ChromaticAberration(default, set):Float = 10.0;

    public function new():Void{
        super();
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }

    public function set_ChromaticAberration(v:Float):Float{
        ChromaticAberration = v;
        shader.ChromaticAberration.value = [v];
        return ChromaticAberration;
    }

}

class SeekChromaticAberrationGLSL extends FlxShader{
    @:glFragmentSource('
        #pragma header

        vec2 uv = openfl_TextureCoordv.xy;
        vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
        vec2 iResolution = openfl_TextureSize;
        uniform float iTime;
        #define iChannel0 bitmap
        #define texture flixel_texture2D
        #define fragColor gl_FragColor
        #define mainImage main
        
        uniform float ChromaticAberration = 10.0;
        void mainImage()
        {
            float theAlpha = flixel_texture2D(bitmap,uv).a;
            vec2 uv = fragCoord.xy / iResolution.xy;
        
            vec2 texel = 1.0 / iResolution.xy;
            
            vec2 coords = (uv - 0.5) * 2.0;
            float coordDot = dot (coords, coords);
            
            vec2 precompute = ChromaticAberration * coordDot * coords;
            vec2 uvR = uv - texel.xy * precompute;
            vec2 uvB = uv + texel.xy * precompute;
            
            vec3 color;
            color.r = texture(iChannel0, uvR).r;
            color.g = texture(iChannel0, uv).g;
            color.b = texture(iChannel0, uvB).b;
            
            fragColor = vec4(color, theAlpha);
        }
    ')

    public function new(){
        super();
    }
}