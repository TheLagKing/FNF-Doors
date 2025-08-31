package shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class GlitchShopShader extends FlxBasic{
    public var shader(default, null):GlitchShopShaderGLSL = new GlitchShopShaderGLSL();

    var iTime:Float = 0;

    public function new():Void{
        super();
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }
}

class GlitchShopShaderGLSL extends FlxShader{
    @:glFragmentSource('
        #pragma header

        uniform float iTime;
        #define iChannel0 bitmap
        #define texture flixel_texture2D
        #define fragColor gl_FragColor
        #define mainImage main

        void main()
        {
            vec2 uv = openfl_TextureCoordv;

            float x = uv.x;
            float y = uv.y;
            
            float xcir = x-0.5;
            float ycir = y-0.5;
            
            float circle = ((xcir*xcir)+(ycir*ycir)/3.0);
            float tunnel = sqrt(circle*0.25)/circle*4.0+iTime*8.0;
            float wally = sin(atan(xcir/ycir*1.5)*8.0+cos(iTime/2.0)*16.0*sin(tunnel+iTime)/4.0+sin(iTime/3.2)*32.0);

            float shade=clamp(circle*16.0,0.0,1.0);
            float full=(sin(tunnel)*wally);
            fragColor = vec4(full*shade*1.4,(full-0.25)*shade,abs(full+0.5)*shade,1.0);
        }
    ')

    public function new(){
        super();
    }
}