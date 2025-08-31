package substates;

import objects.DoorsMouse.DoorsMouseActions;
import states.CreditsState.Socials;
import flixel.math.FlxPoint;
import objects.ui.DoorsMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class SocialsSubstate extends MusicBeatSubstate 
{
    private var socials:Socials;

    private var youTubeText:StoryModeTextHoverable;
    private var twitterText:StoryModeTextHoverable;
    private var instagramText:StoryModeTextHoverable;
    private var githubText:StoryModeTextHoverable;

    public function new(name:String, socials:Socials) {
        this.socials = socials;
        super();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var menu = new DoorsMenu(300, 40, "socials", name + (name.endsWith("S") ? "' " : "'S ")+Lang.getText("socials", "newUI", "value"));
        menu.closeFunction = function(){
            close();
        }
        add(menu);

        youTubeText = new StoryModeTextHoverable(158, 102, 0, socials.youtube != null ? socials.youtube.name : "---", 48, false);
        youTubeText.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
        youTubeText.antialiasing = ClientPrefs.globalAntialiasing;
        menu.add(youTubeText);

        instagramText = new StoryModeTextHoverable(158, 247, 0, socials.instagram != null ? socials.instagram.name : "---", 48, false);
        instagramText.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
        instagramText.antialiasing = ClientPrefs.globalAntialiasing;
        menu.add(instagramText);

        twitterText = new StoryModeTextHoverable(158, 392, 0, socials.twitter != null ? socials.twitter.name : "---", 48, false);
        twitterText.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
        twitterText.antialiasing = ClientPrefs.globalAntialiasing;
        menu.add(twitterText);

        githubText = new StoryModeTextHoverable(158, 537, 0, socials.github != null ? socials.github.name : "---", 48, false);
        githubText.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
        githubText.antialiasing = ClientPrefs.globalAntialiasing;
        menu.add(githubText);
    }

    override public function update(elapsed:Float) {
        // Haha im dumb
        if(socials.youtube != null) {
            youTubeText.checkOverlap(this.cameras[0]);
            if(youTubeText.justHovered) theMouse.currentAction = DoorsMouseActions.POINTING;
            if(youTubeText.justStoppedHovering) theMouse.currentAction = DoorsMouseActions.NONE;
            if(youTubeText.isHovered && FlxG.mouse.pressed) CoolUtil.browserLoad(socials.youtube.url);
        }
        if(socials.instagram != null) {
            instagramText.checkOverlap(this.cameras[0]);
            if(instagramText.justHovered) theMouse.currentAction = DoorsMouseActions.POINTING;
            if(instagramText.justStoppedHovering) theMouse.currentAction = DoorsMouseActions.NONE;
            if(instagramText.isHovered && FlxG.mouse.pressed) CoolUtil.browserLoad(socials.instagram.url);
        }
        if(socials.twitter != null) {
            twitterText.checkOverlap(this.cameras[0]);
            if(twitterText.justHovered) theMouse.currentAction = DoorsMouseActions.POINTING;
            if(twitterText.justStoppedHovering) theMouse.currentAction = DoorsMouseActions.NONE;
            if(twitterText.isHovered && FlxG.mouse.pressed) CoolUtil.browserLoad(socials.twitter.url);
        }
        if(socials.github != null) {
            githubText.checkOverlap(this.cameras[0]);
            if(githubText.justHovered) theMouse.currentAction = DoorsMouseActions.POINTING;
            if(githubText.justStoppedHovering) theMouse.currentAction = DoorsMouseActions.NONE;
            if(githubText.isHovered && FlxG.mouse.pressed) CoolUtil.browserLoad(socials.github.url);
        }
        
        super.update(elapsed);
    }
}