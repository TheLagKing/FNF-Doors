package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

class StoryModeSpriteHoverable extends FlxSprite
{
    public var type:String;
    public var name:String;

    public function new(x, y, name:String, ?type:String = ""){
        super(x,y);
        this.x = x;
        this.y = y;
        this.type = type;
        this.name = name;

        this.antialiasing = ClientPrefs.globalAntialiasing;

        if(name != ""){
            loadGraphic(Paths.image(name));
        }
    }

	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        justStoppedHovering = false;
        if  ((this.x + this.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + this.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            if(isHovered){
                justStoppedHovering = true;
            }
            isHovered = false;
        }
    }

    public function onClick(){
        if(type != ""){
            switch(type){
                case 'tree':
                    StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFF224826, 40);
                    StoryMenuState.particleEmitter.lifespan.set(0.1, 0.5);
                    StoryMenuState.particleEmitter.alpha.set(0.7, 0.9);
                    StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
                    StoryMenuState.particleEmitter.start(true, 0.1, 40);

                    FlxG.sound.play(Paths.sound('tree'));

                case 'light':
                    FlxG.sound.play(Paths.sound('light'));

                case 'spider':
                    FlxG.sound.play(Paths.sound('spider'));

                case 'bell':
                    FlxG.sound.play(Paths.sound('salamanca'));

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
                    FlxG.sound.play(Paths.sound("painting"));

                    StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFF5F5DC, 10);
                    StoryMenuState.particleEmitter.lifespan.set(0.4, 0.8);
                    StoryMenuState.particleEmitter.alpha.set(0.2, 0.4);
                    StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
                    StoryMenuState.particleEmitter.start(true, 0.1, 10);
                    

                case 'dust':
                    StoryMenuState.particleEmitter.makeParticles(2, 2, 0xFFF5F5DC, 10);
                    StoryMenuState.particleEmitter.lifespan.set(0.4, 0.8);
                    StoryMenuState.particleEmitter.alpha.set(0.2, 0.4);
                    StoryMenuState.particleEmitter.acceleration.start.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.start.max.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.min.y = 0;
                    StoryMenuState.particleEmitter.acceleration.end.max.y = 0;
                    StoryMenuState.particleEmitter.start(true, 0.1, 10);
            }
        }
    }
}