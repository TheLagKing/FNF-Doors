package objects.ui;

enum abstract DoorsButtonState(String) {
    final NORMAL = "normal";
    final HOVERED = "hovered";
    final PRESSED = "pressed"; //only used in the options button size
}

enum abstract DoorsButtonWeight(String) {
    final DANGEROUS = "crit"; 
    final PRIORITY = "high";
    final NORMAL = "normal";
    final CUSTOM = "custom";
}

enum abstract DoorsButtonSize(String) {
    final SMALL = "small";
    final MEDIUM = "medium";
    final LARGE = "large";
    final OPTIONS = "options";
}

class DoorsButton extends FlxSpriteGroup {
    public var state:DoorsButtonState = DoorsButtonState.NORMAL;
    var weight:DoorsButtonWeight = DoorsButtonWeight.NORMAL;
    var size:DoorsButtonSize = DoorsButtonSize.MEDIUM;

    public var bg:StoryModeSpriteHoverable;
    public var buttonText:FlxText;

    public var whenClicked:Void->Void;
    public var whenHovered:Void->Void;
    public var whileHovered:Void->Void;

    public function new(x:Float, y:Float, btnText:String, size:DoorsButtonSize, weight:DoorsButtonWeight,
        ?onClick:Void->Void, ?onHover:Void->Void, ?whileHover:Void->Void){
        super(x, y);
        this.weight = weight;
        this.size = size;

        whenClicked = onClick;
        whenHovered = onHover;
        whileHovered = whileHover;

        if(weight != CUSTOM) makeButton(btnText);
    }

    public dynamic function makeButton(btn_txt:String){
        if(bg != null) remove(bg);
        if(buttonText != null) remove(buttonText);

        bg = cast new StoryModeSpriteHoverable(0,0,"","").loadGraphic(Paths.image('ui/buttons/${size}_${weight}_${state}'));
        bg.scale.set(0.5, 0.5);
        bg.updateHitbox();

        buttonText = new FlxText(0, 6, bg.width, btn_txt);

        var targetSize:Int = 32;
        var targetColor:FlxColor = 0xFFFEDEBF;
        var outlineColor:FlxColor = 0xFF452D25;

        switch(weight){
            case PRIORITY: 
                targetColor = 0xFF452D25;
                outlineColor = 0xFFFEDEBF;
            default:
        }

        switch(size){
            case LARGE | MEDIUM:
                targetSize = 36;
            case OPTIONS:
                buttonText.y -= 4;
            default:
                targetSize = 32;
        }

        switch(state){
            case PRESSED:
                targetColor = 0xFF452D25;
                outlineColor = FlxColor.TRANSPARENT;
            default:
        }

        buttonText.setFormat(FONT, targetSize, targetColor, CENTER, OUTLINE, outlineColor);
        buttonText.borderSize = 2;
        buttonText.antialiasing = ClientPrefs.globalAntialiasing;

        add(bg);
        add(buttonText);

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
        checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

        if(state != PRESSED){
            if(justHovered){
                this.state = DoorsButtonState.HOVERED;
                makeButton(buttonText.text);
                if(whenHovered != null) whenHovered();
            } 
    
            if(justStoppedHovering){
                this.state = DoorsButtonState.NORMAL;
                makeButton(buttonText.text);
            }
        }

        if(isHovered){
            if(whileHovered != null) whileHovered();
            if(FlxG.mouse.justPressed){
                if(whenClicked != null) whenClicked();
            }
        }

        super.update(elapsed);
    }

    override function draw(){
        super.draw();
    }
}