package substates;

import states.AchievementsState.ScrollBar;
import states.CreditsState.SpecialThanks;
import flixel.math.FlxPoint;
import objects.ui.DoorsMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class SpecialThanksSubState extends MusicBeatSubstate
{
    var specialTextGroup:FlxSpriteGroup;
    var scroll:Float = 0.0;
    var listHeight:Float = 0;
    public function new(specialThanks:Array<SpecialThanks>)
    {
        super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var menu = new DoorsMenu(99, 40, "specialThanks", Lang.getText("specialThanks", "newUI", "value"), true, FlxPoint.get(1044, 18));
        menu.closeFunction = function(){
            close();
        }
        add(menu);

        specialTextGroup = new FlxSpriteGroup(27, 84);
        menu.add(specialTextGroup);

        var lastGroup:String = "";
        var groupCounter = 0;
        for(i=>specialThank in specialThanks){
            var isNewGroup = false;
            if(specialThank.group != lastGroup){
                groupCounter++;
                isNewGroup = true;
                lastGroup = specialThank.group;
            }

            if(isNewGroup) {
                var groupText:FlxText = new FlxText(0, (80*i) + (80*(groupCounter-1)), 0, specialThank.group.toUpperCase());
                groupText.setFormat(FONT, 48, 0xFFFEDEBF, LEFT);
                groupText.antialiasing = ClientPrefs.globalAntialiasing;
                specialTextGroup.add(groupText);
                groupText.clipRect = CoolUtil.calcRectByGlobal(groupText, FlxRect.get(126, 124, 1032, 550));
                listHeight += 80;
            }

            var text = "";
            text = specialThank.name;
            if(specialThank.message != ""){
                text += " - " + specialThank.message;
            }

            var r:EReg = new EReg("[^\x00-\x7F]", "ug");
            var useUnicodeFont:Bool = r.match(text);


            var specialThankText:FlxText = new FlxText(0, (80*i) + (80*groupCounter), 0, text);
            specialThankText.setFormat(useUnicodeFont ? Paths.font("noto-chinese.ttf") : FONT, 40, 0xFFFEDEBF, LEFT);
            specialThankText.antialiasing = ClientPrefs.globalAntialiasing;
            specialTextGroup.add(specialThankText);
            listHeight += 80;
        }

        var scrollBar:ScrollBar = new ScrollBar(1075, 94, this, "scroll", listHeight);
        scrollBar.scrollBar.loadGraphic(Paths.image("menus/specialThanks/scrollBar"));
        scrollBar.scrollBG.loadGraphic(Paths.image("menus/specialThanks/scrollBG"));
        menu.add(scrollBar);
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.ESCAPE)
        {
            close();
        }

        for(specialThankText in specialTextGroup.members){
            specialThankText.clipRect = CoolUtil.calcRectByGlobal(specialThankText, FlxRect.get(126, 124, 1032, 550));
        }

        scroll -= FlxG.mouse.wheel*50*elapsed*240;
        if (controls.UI_DOWN)
            scroll += 320*elapsed;
        if (controls.UI_UP)
            scroll -= 320*elapsed;
        specialTextGroup.y = FlxMath.lerp(specialTextGroup.y, 124 - scroll, elapsed*12);

        scroll = FlxMath.bound(scroll, 0, listHeight);
        super.update(elapsed);
    }
}