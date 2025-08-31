package substates;

import flixel.addons.display.FlxGridOverlay;

class WarningSubState extends MusicBeatSubstate {

    var gamer:String;

    public var theWarningText:FlxText;
    public var revivesReminder:FlxText;
    public var acceptText:StoryModeTextHoverable;
    public var denyText:StoryModeTextHoverable;

    var grid:FlxBackdrop;

    var doUpdate:Bool;

    public function new(gamer:String){
        this.gamer = gamer;
        super();

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x80432004, 0x80400415));
		grid.velocity.set(80, 80);
		grid.alpha = 0;
		add(grid);

        theWarningText = new FlxText(0, FlxG.height * 0.1, FlxG.width, Lang.getText("warning", "states/pause"));
        theWarningText.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        theWarningText.antialiasing = ClientPrefs.globalAntialiasing;

        revivesReminder = new FlxText(0, theWarningText.y + theWarningText.height + 10, FlxG.width, (Lang.getText("reviveWarning", "death"):String).replace("{0}", Std.string(DoorsUtil.curRun.revivesLeft)));
        revivesReminder.setFormat(Paths.font('Oswald.ttf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        revivesReminder.antialiasing = ClientPrefs.globalAntialiasing;

        if(DoorsUtil.curRun.revivesLeft <= 0){
            theWarningText.text = Lang.getText("warningtwo", "states/pause");
        } 

        acceptText = new StoryModeTextHoverable(FlxG.width * 0.65, FlxG.height * 0.7, FlxG.width * 0.2, Lang.getText("yes", "states/pause"), 64, false);
        acceptText.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        acceptText.antialiasing = ClientPrefs.globalAntialiasing;

        denyText = new StoryModeTextHoverable(FlxG.width * 0.15, FlxG.height * 0.7, FlxG.width * 0.2, Lang.getText("no", "states/pause"), 64, false);
        denyText.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        denyText.antialiasing = ClientPrefs.globalAntialiasing;

        add(theWarningText);
        if(DoorsUtil.curRun.revivesLeft > 0) add(revivesReminder);
        add(acceptText);
        add(denyText);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        startGaming();
    }

    function startGaming(){
        theWarningText.alpha = 0.0001;
		theWarningText.y -= 15;
		acceptText.alpha = 0.0001;
		acceptText.y -= 15;
		denyText.alpha = 0.0001;
		denyText.y -= 15;
		revivesReminder.alpha = 0.0001;
		revivesReminder.y -= 15;

        PauseSubState.instance.TweenHandler(grid, {alpha: 1, x: grid.x + FlxG.height, y: grid.y + FlxG.height}, 0.6, {ease: FlxEase.quintOut});
    	PauseSubState.instance.TweenHandler(theWarningText, {y: theWarningText.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0});
		PauseSubState.instance.TweenHandler(revivesReminder, {y: revivesReminder.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.1});
		PauseSubState.instance.TweenHandler(acceptText, {y: acceptText.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.5, onComplete: function(twn){
            doUpdate = true;
        }});
		PauseSubState.instance.TweenHandler(denyText, {y: denyText.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.5});
	}

    function stopGaming(accepted:Bool){
        doUpdate = false;
        PauseSubState.instance.TweenHandler(grid, {alpha: 0, x: grid.x + FlxG.height, y: grid.y + FlxG.height}, 0.6, {ease: FlxEase.quadIn});
    	PauseSubState.instance.TweenHandler(theWarningText, {y: theWarningText.y + 15, alpha: 0}, 0.5, {ease: FlxEase.quadIn, startDelay: 0});
		PauseSubState.instance.TweenHandler(revivesReminder, {y: revivesReminder.y + 15, alpha: 0}, 0.5, {ease: FlxEase.quadIn, startDelay: 0.0, onComplete: function(twn){
            close();
            if(accepted) {
                switch(gamer){
                    case "RESTART": PauseSubState.restartSong();
                    case "QUIT": PauseSubState.performQuit();
                }
            }
        }});
		PauseSubState.instance.TweenHandler(acceptText, {y: acceptText.y + 15, alpha: 0}, 0.5, {ease: FlxEase.quadIn, startDelay: accepted ? 2.0 : 0.0});
		PauseSubState.instance.TweenHandler(denyText, {y: denyText.y + 15, alpha: 0}, 0.5, {ease: FlxEase.quadIn, startDelay: !accepted ? 2.0 : 0.0});
	}

    override function update(elapsed){
        if(doUpdate){
            if (controls.BACK) stopGaming(false);

            acceptText.checkOverlap(this.cameras[0]);
            denyText.checkOverlap(this.cameras[0]);
    
            if(acceptText.justHovered) FlxTween.color(acceptText, 0.2, acceptText.color, 0xFF00FF00);
            if(acceptText.justStoppedHovering) FlxTween.color(acceptText, 0.2, acceptText.color, 0xFFFFFFFF);
            if(denyText.justHovered) FlxTween.color(denyText, 0.2, denyText.color, 0xFFFF0000);
            if(denyText.justStoppedHovering) FlxTween.color(denyText, 0.2, denyText.color, 0xFFFFFFFF);
    
            if(acceptText.isHovered && FlxG.mouse.pressed) stopGaming(true);
            if(denyText.isHovered && FlxG.mouse.pressed) stopGaming(false);
        }

        super.update(elapsed);
    }
}