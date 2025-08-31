package objects.ui;

class DoorsOption extends FlxSpriteGroup {
    public var bg:FlxSprite;

    public function new(x:Float, y:Float){
        super(x, y);
        makeButton();
    }

    private function makeButton(){
        var pathName = "Other";
        var xOffset = 18;

        bg = new FlxSprite(0,0).loadGraphic(Paths.image('ui/score/${pathName}'));
        add(bg);

        this.forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

    override function update(elapsed:Float){
        super.update(elapsed);
    }

    override function draw(){
        super.draw();
    }
}