package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.display.BitmapData;
import openfl.display.BlendMode;
import editors.ChartingState;

using StringTools;

class EffectZone extends FlxSprite
{
    public var type:String;
    public var clicked:Bool = false;
    public var hovered:Bool = false;

    var particleEmitter:FlxTypedEmitter<FlxParticle>;

    public function new(type:String, x:Int, y:Int, width:Int, height:Int){
        super();

        this.type = type;

        this.x = x;
        this.y = y;

        makeGraphic(1,1,FlxColor.BLACK);
        this.scale.set(width,height);
        this.updateHitbox();
        this.alpha = 0.00001;
    }

    override function update(elapsed:Float){
        super.update(elapsed);
        clicked = false;
        hovered = FlxG.mouse.overlaps(this);
        if (hovered) {
            clicked=FlxG.mouse.justPressed;
            if (clicked){
                clickEffects(this.type);
            }
        }
    }

    public function clickEffects(type:String){
		switch (type){
			case 'tree':
				StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFF224826, 40);
				StoryMenuState.particleEmitter.lifespan.set(0.1, 0.5);
				StoryMenuState.particleEmitter.alpha.set(0.7, 0.9);
                StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
				StoryMenuState.particleEmitter.start(true, 0.1, 40);

				MenuSongManager.playSound('tree', 1);

            case 'light':
				MenuSongManager.playSound('light', 1);

            case 'spider':
				MenuSongManager.playSound('spider', 1);

			case 'bell':
				MenuSongManager.playSound('salamanca', 1);

				StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFFFBF00, 4);
				StoryMenuState.particleEmitter.lifespan.set(0.3, 0.7);
				StoryMenuState.particleEmitter.alpha.set(0.6, 0.7);
                StoryMenuState.particleEmitter.acceleration.start.min.y = 800;
                StoryMenuState.particleEmitter.acceleration.start.max.y = 1000;
                StoryMenuState.particleEmitter.acceleration.end.min.y = 800;
                StoryMenuState.particleEmitter.acceleration.end.max.y = 1000;
				StoryMenuState.particleEmitter.start(true, 0.1, 4);

            case 'gold':
                StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFFFBF00, 10);
                StoryMenuState.particleEmitter.lifespan.set(0.3, 0.7);
                StoryMenuState.particleEmitter.alpha.set(0.6, 0.7);
                StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
                StoryMenuState.particleEmitter.start(true, 0.1, 10);

			case 'painting':
				MenuSongManager.playSound('painting', 1);

				StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFF5F5DC, 10);
				StoryMenuState.particleEmitter.lifespan.set(0.1, 0.3);
				StoryMenuState.particleEmitter.alpha.set(0.2, 0.4);
                StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
				StoryMenuState.particleEmitter.start(true, 0.1, 10);
                

			case 'dust':
				StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFF5F5DC, 10);
				StoryMenuState.particleEmitter.lifespan.set(0.1, 0.3);
				StoryMenuState.particleEmitter.alpha.set(0.2, 0.4);
                StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
				StoryMenuState.particleEmitter.start(true, 0.1, 10);
		}
	}
}