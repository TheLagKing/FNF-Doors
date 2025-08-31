package;

import flixel.text.FlxTextNew;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

class StoryModeTextHoverable extends FlxTextNew
{
	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;

    public function new(x:Float, y:Float, width:Float, text:String, size:Int, embedfont:Bool){
        super(x, y, width, text, size);
    }

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
}