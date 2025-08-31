package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class FilmGrain extends FlxShader
{
  @:glFragmentSource('
    #pragma header
    
    // 0: Addition, 1: Screen, 2: Overlay, 3: Soft Light, 4: Lighten-Only
    #define BLEND_MODE 2
    #define SPEED 5.0
    #define INTENSITY 0.075
    // What gray level noise should tend to.
    #define MEAN 0.2
    // Controls the contrast/variance of noise.
    #define VARIANCE 0.5
    uniform float iTime;
    
    vec3 channel_mix(vec3 a, vec3 b, vec3 w) {
        return vec3(mix(a.r, b.r, w.r), mix(a.g, b.g, w.g), mix(a.b, b.b, w.b));
    }
    
    float gaussian(float z, float u, float o) {
      return (1.0 / (o * sqrt(2.0 * 3.1415))) * exp(-(((z - u) * (z - u)) / (2.0 * (o * o))));
    }
    
    vec3 overlay(vec3 a, vec3 b, float w) {
        return mix(a, channel_mix(
            2.0 * a * b,
            vec3(1.0) - 2.0 * (vec3(1.0) - a) * (vec3(1.0) - b),
            step(vec3(0.5), a)
        ), w);
    }
    
    void main() {
        vec2 ps = vec2(1.0) / openfl_TextureSize.xy;
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = flixel_texture2D(bitmap, uv);
        
        float t = iTime * float(SPEED);
        float seed = dot(uv, vec2(12.9898, 78.233));
        float noise = fract(sin(seed) * 43758.5453 + t);
        noise = gaussian(noise, float(MEAN), float(VARIANCE) * float(VARIANCE));
        
        float w = float(INTENSITY);
      
        vec3 grain = vec3(noise) * (1.0 - gl_FragColor.rgb);
        
        gl_FragColor.rgb = overlay(gl_FragColor.rgb, grain, w);
        gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;
    }
  ')

  public function new()
  {
    super();
    this.iTime.value = [0];

    StoryMenuState.instance.shaderUpdates.push(update);
  }

	public function update(elapsed:Float)
	{
		this.iTime.value[0] += elapsed;
	}
}