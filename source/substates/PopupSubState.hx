package substates;

import objects.ui.DoorsMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PopupSubState extends MusicBeatSubstate
{
    private var messageText:FlxText;
    private var instructionText:FlxText;
    private var isAnimating:Bool = false; // Flag to track animation state

    private var popupId:String;
    private var bg:FlxSprite;

    var menuBG:DoorsMenu;
    
    public function new(popupId:String)
    {
        this.popupId = popupId;
        super();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.0;
        add(bg);

        menuBG = new DoorsMenu(300, 216, "popups", Lang.getText(popupId, "popups/titles"), false);
        menuBG.title.setFormat(FONT, 48, 0xFFB6CAC9, LEFT, OUTLINE, 0xFF47606C);
        add(menuBG);
        
        messageText = new FlxText(0, 84, 680, Lang.getText(popupId, "popups/messages"), 32);
        messageText.setFormat(FONT, 32, 0xFFB6CAC9, CENTER, OUTLINE, 0xFF47606C);
        messageText.antialiasing = ClientPrefs.globalAntialiasing;
        menuBG.add(messageText);
        
        instructionText = new FlxText(0, FlxG.height, FlxG.width, Lang.getText("leavePopup", "popups"), 48);
        instructionText.setFormat(FONT, 48, 0xFFFEDEBF, CENTER);
        instructionText.antialiasing = ClientPrefs.globalAntialiasing;
        add(instructionText);

        startGaming();
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (!isAnimating && (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed))
        {
            markPopupAsSeen(this.popupId);
            stopGaming();
        }
    }

    private function startGaming(){
        isAnimating = true;
        menuBG.y += FlxG.height;

        FlxTween.tween(bg, {alpha: 0.6}, 0.6, {ease: FlxEase.sineInOut});
        FlxTween.tween(menuBG, {y: menuBG.y - FlxG.height}, 0.6, {ease: FlxEase.backOut, onComplete: function(twn){
            isAnimating = false;
        }});
        FlxTween.tween(instructionText, {y: instructionText.y - instructionText.height}, 1.2, {ease: FlxEase.backOut});
    }

    private function stopGaming(){
        isAnimating = true;
        FlxTween.tween(bg, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut});
        FlxTween.tween(menuBG, {y: menuBG.y + FlxG.height}, 1.2, {ease: FlxEase.backOut, onComplete: function(twn){
            close();
        }});
        FlxTween.tween(instructionText, {y: instructionText.y + instructionText.height}, 1.2, {ease: FlxEase.backOut});
    }

    public static function hasSeenPopup(popupId:String):Bool {
        var data:String = FlxG.save.data.seenPopups;
        if (data == null) {
            data = '';
            FlxG.save.data.seenPopups = data;
        }
        
        var popups:Array<String> = data.split(',');
        return popups.contains(popupId);
    }

    public static function markPopupAsSeen(popupId:String):Void {
        var data:String = FlxG.save.data.seenPopups;
        if (data == null) {
            data = '';
        }
        
        var popups:Array<String> = data.split(',');
        if (!popups.contains(popupId)) {
            popups.push(popupId);
            FlxG.save.data.seenPopups = popups.join(',');
            FlxG.save.flush();
        }
    }
}