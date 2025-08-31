package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class VignetteShader extends FlxBasic{
    public var shader(default, null):VignetteShaderGLSL = new VignetteShaderGLSL();

    public var darkness(default, set):Float = 15.0;
    public var extent(default, set):Float = 0.25;
    public var red:Float = 0.0;
    public var green:Float = 0.0;
    public var blue:Float = 0.0;

    public function new():Void{
        super();
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
    }

    public function set_darkness(v:Float):Float{
        darkness = v;
        shader.darkness.value = [v];
        return darkness;
    }

    public function set_extent(v:Float):Float{
        extent = v;
        shader.extent.value = [v];
        return extent;
    }
}

class VignetteShaderGLSL extends FlxShader{
    @:glFragmentSource('
		#pragma header
		
		uniform float darkness;
        uniform float extent;

        uniform float red;
        uniform float green;
        uniform float blue;

		void main()
        {
            vec2 uv = openfl_TextureCoordv.xy;
            uv *= 1.0 - uv.yx;
            
            float vignette = uv.x*uv.y * darkness;
            vignette = pow(vignette, extent);
            
            vec4 color = texture2D(bitmap, openfl_TextureCoordv);
            color.rgb *= vignette;
            
            gl_FragColor = color;
        }
    ')

    public function new(){
        super();
    }
}