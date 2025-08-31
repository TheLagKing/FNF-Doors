package objects;

import states.FreeplayState.RequireType;

class FreeplaySong extends FlxSprite{

    public var realX:Float;
    public var realY:Float;

    public var songName:String;
    public var renderName:String;
    public var fileSong:String;

    public var unlockType:RequireType;
    public var price:Int = 0;
    public var isLocked:Bool = true;
    var overlapUpdate:Bool = false;

    public var elevatorBackground:FlxSprite;
    public var elevatorGate1:FlxSprite;
    public var elevatorGate2:FlxSprite;
    public var elevatorGate3:FlxSprite;
    public var nameTxt:FlxText;

    public var knobIcon:FlxSprite;
    public var priceTxt:FlxText;

	//["Song name", "render name", method of unlock, ['song name in files'], price, startUnlocked],


    public function new(_x:Float, _y:Float, songName:String, renderName:String, unlockType:RequireType, songFile:String, price:Int, startUnlocked:Bool = false){
        super(_x, _y);
        this.songName = songName;
        this.renderName = renderName;
        this.fileSong = songFile;
        this.unlockType = unlockType;
        this.price = price;

        elevatorBackground = new FlxSprite(x, y).loadGraphic(Paths.image("freeplay/elevator"));
        elevatorBackground.scale.set(1280/1920, 720/1080);
        elevatorBackground.updateHitbox();
        elevatorBackground.antialiasing = ClientPrefs.globalAntialiasing;

        elevatorGate1 = new FlxSprite(x, y).loadGraphic(Paths.image("freeplay/gate"));
        elevatorGate1.scale.set(1280/1920, 720/1080);
        elevatorGate1.updateHitbox();
        elevatorGate1.antialiasing = ClientPrefs.globalAntialiasing;

        elevatorGate2 = new FlxSprite(x - 20, y).loadGraphic(Paths.image("freeplay/gate2"));
        elevatorGate2.scale.set(1280/1920, 720/1080);
        elevatorGate2.updateHitbox();
        elevatorGate2.antialiasing = ClientPrefs.globalAntialiasing;

        elevatorGate3 = new FlxSprite(x + 150, y).loadGraphic(Paths.image("freeplay/gate3"));
        elevatorGate3.scale.set(1280/1920, 720/1080);
        elevatorGate3.updateHitbox();
        elevatorGate3.antialiasing = ClientPrefs.globalAntialiasing;

        nameTxt = new FlxText(x, y, elevatorBackground.width, songName, 64);
        nameTxt.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        nameTxt.borderSize = 3;
        nameTxt.antialiasing = ClientPrefs.globalAntialiasing;

        knobIcon = new FlxSprite(x + 120, y + 80).loadGraphic(Paths.image("Knob"));
        knobIcon.setGraphicSize(200);
        knobIcon.updateHitbox();
        knobIcon.setPosition(elevatorBackground.width/2 - knobIcon.width/2, elevatorBackground.height/2 - knobIcon.height/2);
        knobIcon.antialiasing = ClientPrefs.globalAntialiasing;

        priceTxt = new FlxText(x, knobIcon.y + knobIcon.height + 10, elevatorBackground.width, Std.string(price), 64);
        priceTxt.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        priceTxt.borderSize = 3;
        priceTxt.antialiasing = ClientPrefs.globalAntialiasing;

        checkLocked(this.unlockType, this.fileSong, startUnlocked);

        if(this.price == 0){
            knobIcon.alpha = 0;
            priceTxt.alpha = 0;
        }

        if(!isLocked){
            elevatorGate1.visible = false;
            elevatorGate2.visible = false;
            elevatorGate3.visible = false;
            knobIcon.alpha = 0;
            priceTxt.alpha = 0;
        }
    }

    public function unlockAnim(){
        FlxG.sound.play(Paths.sound('dingding'), 1);
        overlapUpdate = true;
        isLocked = false;
        new FlxTimer().start(0.1, function(tmr){
            FlxTween.tween(knobIcon, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
            FlxTween.tween(priceTxt, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
            FlxTween.tween(elevatorGate3, {x: elevatorGate3.x + 300}, 1.5, {ease: FlxEase.quintInOut, onComplete: function(twn){
                elevatorGate3.visible = false;
            }});
            FlxTween.tween(elevatorGate2, {x: elevatorGate2.x - 300}, 1.5, {ease: FlxEase.quintInOut, startDelay: 0.2, onComplete: function(twn){
                elevatorGate2.visible = false;
            }});
            new FlxTimer().start(1.3, function(tmr){
                FlxTween.tween(elevatorGate1, {y: elevatorGate1.y - 800}, 1.5, {ease: FlxEase.quintInOut, onComplete: function(twn){
                    elevatorGate1.visible = false;
                    overlapUpdate = false;
                }});
            });
        });
    }

    function checkLocked(requirement:RequireType, song:String, forceUnlock:Bool){
        isLocked = false;
        if(forceUnlock){
            return;
        }

        if(requirement == FROM_STORY_MODE){
            for(i in 0...3){
                if(Highscore.getScore(song, i) == 0){
                    isLocked = true;
                } else {
                    isLocked = false;
                    return;
                }
            }
        }

        if(requirement == KNOBS){
            for(i in 0...3){
                if(Highscore.getScore(song, i) == 0){
                    isLocked = true;
                } else {
                    isLocked = false;
                    return;
                }
            }
        }

        if(requirement == SPECIAL){
            for(i in 0...3){
                if(Highscore.getScore(song, i) == 0){
                    isLocked = true;
                } else {
                    isLocked = false;
                    return;
                }
            }
        }

        if(requirement == HELL){
            for(i in 0...3){
                if(Highscore.getScore(song, i) == 0){
                    isLocked = true;
                } else {
                    isLocked = false;
                    return;
                }
            }
        }

        if(requirement == ACHIEVEMENT){
            switch(song){
                case 'daddy-issues':
                    isLocked = false;
            }
        }
    }

    override function update(elapsed:Float){
        if(!overlapUpdate){
            elevatorBackground.setPosition(realX, realY);
            elevatorGate1.setPosition(realX, realY);
            elevatorGate2.setPosition(realX - 20, realY);
            elevatorGate3.setPosition(realX + 150, realY);
            nameTxt.setPosition(realX, realY + 300 - (Math.floor(nameTxt.height / 70) * 80));
            knobIcon.setPosition(realX + (elevatorBackground.width/2 - knobIcon.width/2), realY + (elevatorBackground.height/2 - knobIcon.height/2) - 50);
            priceTxt.setPosition(realX, knobIcon.y + knobIcon.height + 10);
        }

        super.update(elapsed);
    }
}