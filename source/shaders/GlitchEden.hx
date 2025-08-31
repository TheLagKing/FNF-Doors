package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class GlitchEden extends FlxShader
{
  @:glFragmentSource('
    #pragma header
    // ---- gllock required fields -----------------------------------------------------------------------------------------

    uniform float iTime;
    uniform float end;
    uniform sampler2D imageData;
    uniform vec2 screenSize;
    // ---------------------------------------------------------------------------------------------------------------------

    float rand(vec2 co){
      return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
    }

    float offset(float blocks, vec2 uv) {
      return rand(vec2(iTime, floor(uv.y * blocks)));
    }

    void main(void) {
      vec2 uv = openfl_TextureCoordv;
      gl_FragColor.rgba = flixel_texture2D(bitmap, uv + vec2(offset(64.0, uv) * 0.03, 0.0)).rgba;
    }
  ')

  public function new()
  {
    super();
    this.iTime.value = [0];

    if(PlayState.instance != null) PlayState.instance.shaderUpdates.push(update);
  }

	public function update(elapsed:Float)
	{
		this.iTime.value[0] += elapsed;
	}
}