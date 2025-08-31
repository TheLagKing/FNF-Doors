package shaders;

import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class RainbowShader extends FlxBasic
{
    public var shader:RainbowShaderGLSL = new RainbowShaderGLSL();

    public function new():Void
    {
        super();
        shader.iTime.value = [0];
        shader.speed.value = [1.0]; // Rainbow scroll speed
        shader.frequency.value = [3.0]; // How many rainbow cycles across the text
        shader.saturation.value = [1.0]; // Color saturation
        shader.brightness.value = [1.0]; // Color brightness
        shader.alphaThreshold.value = [0.001]; // Minimum alpha to colorize
    }

    override function update(elapsed:Float):Void
    {
        shader.iTime.value[0] += elapsed;
    }

    // Helper methods to control the effect
    public function setSpeed(value:Float):Void
    {
        shader.speed.value[0] = value;
    }

    public function setFrequency(value:Float):Void
    {
        shader.frequency.value[0] = value;
    }

    public function setSaturation(value:Float):Void
    {
        shader.saturation.value[0] = value;
    }

    public function setBrightness(value:Float):Void
    {
        shader.brightness.value[0] = value;
    }

    public function setAlphaThreshold(value:Float):Void
    {
        shader.alphaThreshold.value[0] = value;
    }
}

class RainbowShaderGLSL extends FlxShader
{
    @:glFragmentSource('
#pragma header
uniform float iTime;
uniform float speed;
uniform float frequency;
uniform float saturation;
uniform float brightness;
uniform float alphaThreshold;

// HSV to RGB conversion
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    
    // Sample the original texture (text)
    vec4 originalColor = flixel_texture2D(bitmap, uv);
    
    // If the pixel is essentially transparent, don\'t apply rainbow
    if (originalColor.a < alphaThreshold) {
        gl_FragColor = originalColor;
        return;
    }
    
    // Calculate rainbow position based on horizontal position and time
    // uv.x ranges from 0 to 1 across the text width
    float rainbowPos = uv.x * frequency + iTime * speed;
    
    // Create hue value that cycles through the rainbow (0-1 maps to 0-360 degrees)
    float hue = fract(rainbowPos);
    
    // Create HSV color with full saturation and brightness (adjustable)
    vec3 hsv = vec3(hue, saturation, brightness);
    
    // Convert to RGB
    vec3 rainbowColor = hsv2rgb(hsv);
    
    // Apply rainbow color while preserving the original alpha and text shape
    // This multiplies the rainbow with the text, so black text becomes rainbow
    // and transparent areas stay transparent
    // vec3 finalColor = rainbowColor * originalColor.rgb;
    
    // Alternative approach: Replace text color entirely with rainbow
    // Uncomment this line and comment the one above for solid rainbow text
    vec3 finalColor = rainbowColor * originalColor.a;
    
    gl_FragColor = vec4(finalColor, originalColor.a);
}
    ')

    public function new()
    {
       super();
    }
}