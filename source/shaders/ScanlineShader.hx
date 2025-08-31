package shaders;

import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class ScanlineShader extends FlxBasic
{
	public var shader(default,null):ScanlineShaderGLSL = new ScanlineShaderGLSL();
    public var strength:Float = 0.0;
    public var pixelsBetweenEachLine:Float = 15.0;
    public var smooth:Bool = false;

	public function new():Void
	{
        super();
        shader.strength.value = [strength];
        shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
        shader.smoothVar.value = [smooth];
	}

	override public function update(elapsed:Float):Void
	{
        shader.strength.value = [strength];
        shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
        shader.smoothVar.value = [smooth];
	}
}

class ScanlineShaderGLSL extends FlxShader
{
	@:glFragmentSource('
        #pragma header
            
        uniform float strength;
        uniform float pixelsBetweenEachLine;
        uniform bool smoothVar;

        float m(float a, float b) //was having an issue with mod so i did this to try and fix it
        {
            return a - (b * floor(a/b));
        }

        void main()
        {	
            vec2 iResolution = vec2(1280.0,720.0);
            vec2 uv = openfl_TextureCoordv.xy;
            vec2 fragCoordShit = iResolution*uv;

            vec4 col = flixel_texture2D(bitmap, uv);

            if (smoothVar)
            {
                float apply = abs(sin(fragCoordShit.y)*0.5*pixelsBetweenEachLine);
                vec3 finalCol = mix(col.rgb, vec3(0.0, 0.0, 0.0), apply);
                vec4 scanline = vec4(finalCol.r, finalCol.g, finalCol.b, col.a);
    	        gl_FragColor = mix(col, scanline, strength);
                return;
            }

            vec4 scanline = flixel_texture2D(bitmap, uv);
            if (m(floor(fragCoordShit.y), pixelsBetweenEachLine) == 0.0)
            {
                scanline = vec4(0.0,0.0,0.0,1.0);
            }
            
            gl_FragColor = mix(col, scanline, strength);
        }

        ')
	public function new()
	{
		super();
	}
}
