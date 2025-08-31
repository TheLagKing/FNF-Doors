package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.FlxBasic;

class MosaicShader extends FlxBasic
{
	public var shader(default,null):MosaicShaderGLSL = new MosaicShaderGLSL();
	public var strength:Float = 0.0;

	public function new():Void
	{
        super();
		shader.strength.value = [0];
	}

	override public function update(elapsed:Float):Void
	{
		shader.strength.value[0] = strength;
	}
}

class MosaicShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float strength;

		void main()
		{
            if (strength == 0.0)
            {
                gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
                return;
            }

			vec2 blocks = openfl_TextureSize / vec2(strength,strength);
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new()
	{
		super();
	}
}