package objects;

import flixel.math.FlxRect;
import backend.metadata.SongMetadata;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;

enum CreditTemplate {
    SONG;
    STORY;
}

class NewCredit extends FlxSpriteGroup{
    var artists:Array<String> = [];
    var composers:Array<String> = [];
    var easyCharters:Array<String> = [];
    var normalCharters:Array<String> = [];
    var hardCharters:Array<String> = [];
    var coders:Array<String> = [];

    var songMetadata:SongMetadata;

    var loadedTweens:Array<FlxTween> = [];
    var disappearTimer:FlxTimer;

    var whiteBar:FlxSprite;
    var textOver:FlxText;
    var textUnder:FlxText;

    var template:CreditTemplate;

    //songs
    var songName:String;
    var art:String;
    var music:String;
    var chart:String;

    //story
    var text:String;

    private function makeNewTween(tween:FlxTween, ?onComplete:FlxTween->Void = null){
        tween.onComplete = function(twn){
            if(onComplete != null) onComplete(twn);
            loadedTweens.remove(twn);
        }
        loadedTweens.push(tween);
    }

    public function new(template:CreditTemplate, ?_song:String = "", ?_identificator:Int = -1){
        super(0,0);

        this.template = template;

        var addToPath = "";
        if(_identificator != -1){
            addToPath = "" + _identificator;
        }

        var path = 'assets/data/' + _song.toLowerCase().replace(' ', '-') + '/' + 'metadata' + addToPath + '.json';

        songMetadata = new SongMetadata(_song.toLowerCase().replace(' ', '-'));
        assignValues(songMetadata);

        whiteBar = new FlxSprite(0, 0).makeGraphic(1, 10, FlxColor.WHITE, true);
        whiteBar.alpha = 0.00001;
        whiteBar.screenCenter();

        if(template == SONG){
            makeSongTexts();

            textOver = new FlxText(0, 0, FlxG.width, songMetadata.displayName, 64);
            textOver.setFormat((songMetadata.useDoorsFontInCredit ? DOORS_FONT : FONT), (songMetadata.useDoorsFontInCredit ? 96 : 64), FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            textOver.y = whiteBar.y + 10;
            textOver.antialiasing = ClientPrefs.globalAntialiasing;
            textOver.alpha = 0.00001;
            add(textOver);
            
            textUnder = new FlxText(0, 0, FlxG.width, "", 24);
            textUnder.text = art + "\n" + music + "\n" + chart;
            textUnder.setFormat(FONT, 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            textUnder.y = whiteBar.y - textUnder.height - 10; //default position
            textUnder.antialiasing = ClientPrefs.globalAntialiasing;
            textUnder.alpha = 0.00001;
            add(textUnder);
        } else if (template == STORY){
            textOver = new FlxText(0, 0, FlxG.width, getDoorText(DoorsUtil.curRun.curDoor), 64);
            textOver.setFormat(FONT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            textOver.y = whiteBar.y + 10;
            add(textOver);
        }
        
        add(whiteBar);

        this.alpha = 0.00001;
    }

    private function assignValues(metadata:SongMetadata){
        this.artists = metadata.artists;
        this.composers = metadata.music;
        this.easyCharters = metadata.easyCharters;
        this.normalCharters = metadata.normalCharters;
        this.hardCharters = metadata.hardCharters;
        this.coders = metadata.coders;
    }

    public function start(?instant:Bool = false)
    {
        this.alpha = 1;
        if(template == SONG){
            if(instant){
                PlayState.instance.camOther.flash(0xA0FFFFFF, Conductor.crochet/1000 * 4, null, true);
                whiteBar.alpha = 1;
                whiteBar.scale.x = 600;
                textOver.y = whiteBar.y - textOver.height;
                textUnder.y = whiteBar.y + whiteBar.height + 10;
            } else {
                textOver.y = whiteBar.y - textOver.height - 15;
                textUnder.y = whiteBar.y + whiteBar.height + 25;
                whiteBar.scale.x = 1;
                makeNewTween(FlxTween.tween(whiteBar, {alpha: 1}, Conductor.crochet/1000, {ease: FlxEase.quadOut}));
                makeNewTween(FlxTween.tween(whiteBar, {"scale.x": 600}, Conductor.crochet/1000 * 4, {ease: FlxEase.quadOut}));
                makeNewTween(FlxTween.tween(textOver, {alpha: 1, y: textOver.y + 15}, Conductor.crochet/1000 * 4, {ease: FlxEase.quadOut}));
                makeNewTween(FlxTween.tween(textUnder, {alpha: 1, y: textUnder.y - 15}, Conductor.crochet/1000 * 4, {ease: FlxEase.quadOut}), function(twn){
                    makeNewTween(FlxTween.tween(whiteBar, {alpha: 0}, Conductor.crochet/1000 * 4, {ease: FlxEase.quadOut, startDelay: Conductor.crochet/1000 * 12}));
                    makeNewTween(FlxTween.num(600, 1, Conductor.crochet/1000 * 2, {ease: FlxEase.quadOut, startDelay: Conductor.crochet/1000 * 12}, function(num){
                        whiteBar.scale.x = num;
                    }));
                    makeNewTween(FlxTween.tween(textOver, {alpha: 0, y: textOver.y - 15}, Conductor.crochet/1000 * 2, {ease: FlxEase.quadOut, startDelay: Conductor.crochet/1000 * 12}));
                    makeNewTween(FlxTween.tween(textUnder, {alpha: 0, y: textUnder.y + 15}, Conductor.crochet/1000 * 2, {ease: FlxEase.quadOut, startDelay: Conductor.crochet/1000 * 12}));
                });
            }
        } else if (template == STORY){
            makeNewTween(FlxTween.tween(whiteBar, {alpha: 1}, 0.4, {ease: FlxEase.quintInOut}));
            makeNewTween(FlxTween.num(1, 450, 1, {ease: FlxEase.quintInOut}, function(num){
                whiteBar.scale.x = num;
            }));
            makeNewTween(FlxTween.tween(textOver, {y: whiteBar.y - textOver.height}, 1, {ease: FlxEase.quintInOut, startDelay: 0.5}));
        }
    }

    private function makeSongTexts(){
        art = Lang.getText("art", "newCredit") + ": ";
        if(artists != null){
            for(artist in artists){
                art += artist + " - ";
            }
            if(artists.length > 0) art = art.substr(0, art.length-3);
        }

        music = Lang.getText("music", "newCredit") + ": ";
        if(composers != null){
            for(m in composers){
                music += m + " - ";
            }
            if(composers.length > 0) music = music.substr(0, music.length-3);
        }

        chart = Lang.getText("chart", "newCredit") + ": ";
        var chosenDiff:Array<String> = [];
        switch(PlayState.storyDifficulty){
            case 3: //Hell
                chosenDiff = normalCharters.copy();
            case 2: //Hard
                chosenDiff = hardCharters.copy();
            case 1: //Normal
                chosenDiff = normalCharters.copy();
            case 0: //Easy
                chosenDiff = easyCharters.copy();
            default:
                chosenDiff = normalCharters.copy();
        }
        if(chosenDiff != null){
            for(c in chosenDiff){
                chart += c + " - ";
            }
            if(chosenDiff.length > 0) chart = chart.substr(0, chart.length-3);
        }
    }

    private function getDoorText(num:Int){
        switch(num){
            case 0:
                return "The Hotel";
            case 47|48|49:
                return "The Library";
            case 52:
                return "Jeff's Shop";
            case 90:
                return "The Courtyard";
            case 99:
                return "A Way Out?";
            default:
                return null;
        }
    }
}