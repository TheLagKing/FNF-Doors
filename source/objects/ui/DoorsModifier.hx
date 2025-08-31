package objects.ui;

import online.Leaderboards.LeaderboardSongScore;

enum abstract DoorsModifierType(Int) {
    final DEFAULT = 0;
    final HOVERED = 1;
    final SELECTED = 2;
    final LOCKED = 3;
    final RESERVED = 4;
}

class DoorsModifier extends FlxSpriteGroup {
    public var modType:DoorsModifierType = DoorsModifierType.DEFAULT;

    public var conflictedBy:Modifier;
    public var boundMod:Modifier;

    var bg:FlxSprite;
    var mainText:FlxText;
    var modText:FlxText;

    var _doUpdate:Bool = true;

    public function new(x:Float, y:Float, boundMod:Modifier, type:DoorsModifierType, ?doUpdate:Bool = true){
        super(x, y);
        this.modType = type;
        this.boundMod = boundMod;
        this._doUpdate = doUpdate;

        makeDisplay();

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

    public function makeDisplay(){
        var pathName = "default";
        var xPos = 14;
        var mainTextText = boundMod.name.toUpperCase();
        var unlockCondText = "";
        var color:FlxColor = 0xFFFEDEBF;
        var modtxt:String = "";
        if(boundMod.knobAddition > 1.0) modtxt = "+";
        if(boundMod.knobMultiplier != 1.0) modtxt = "x";
        modtxt += '${Math.round((boundMod.knobAddition-1) * boundMod.knobMultiplier * 100)}%';

        switch(modType){
            case DEFAULT:
                pathName = "default";
            case HOVERED:
                pathName = "hovered";
            case SELECTED:
                pathName = "selected";
                color = 0xFF452D25;
            case LOCKED:
                pathName = "locked";
                xPos = 56;
                switch(boundMod.unlockCondition:UnlockTypes){
                    case FINISHGAME:        unlockCondText = AwardsManager.getAwardFromID("youWin").name;
                    case FINISHGAME_HARD:   unlockCondText = AwardsManager.getAwardFromID("youWinHard").name;
                    case WORST_HOTEL_EVER:  unlockCondText = AwardsManager.getAwardFromID("hotelHell").name;
                    case SEEK_MASTERY:      unlockCondText = AwardsManager.getAwardFromID("neverTripped").name;
                    case FIGURE_MASTERY:    unlockCondText = AwardsManager.getAwardFromID("cardiacArrest").name;
                    case HALT_MASTERY:      unlockCondText = AwardsManager.getAwardFromID("onTheEdge").name;
                    default:
                }
                mainTextText = 'Unlock "${unlockCondText}".';
                color = 0xFFAD907E;
                modtxt = "+??%";
            case RESERVED:
                pathName = "conflict";
                mainTextText = 'Conflicts with "${conflictedBy.name.toUpperCase()}".';
                color = 0xFFAD907E;
        }

        if(bg != null) remove(bg);
        if(mainText != null) remove(mainText);
        if(modText != null) remove(modText);

        bg = new FlxSprite(0,0).loadGraphic(Paths.image('ui/modifiers/${pathName}'));

        mainText = new FlxText(xPos, 2, 0, mainTextText, 32);
        mainText.setFormat(FONT, 32, color, LEFT);

        modText = new FlxText(549, 0, 0, modtxt, 32);
        modText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT);
        
        add(bg);
        add(mainText);
        add(modText);

        while(mainText.width > 485 - xPos){
            mainText.size -= 1;
        }

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        justStoppedHovering = false;
        if  ((this.x + bg.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + bg.height > FlxG.mouse.getWorldPosition(camera).y)
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

    override function update(elapsed:Float){
        if(!_doUpdate) {
            super.update(elapsed);
            return;
        }
        
        checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

        if(modType != LOCKED && modType != RESERVED){
            if(justHovered && modType != SELECTED){
                modType = HOVERED;
                makeDisplay();
            }
            if(justStoppedHovering && modType != SELECTED){
                modType = DEFAULT;
                makeDisplay();
            }
            if(isHovered && FlxG.mouse.justPressed){
                if(modType == SELECTED) modType = HOVERED;
                else modType = SELECTED;
                makeDisplay();
            }
        }

        super.update(elapsed);
    }
}