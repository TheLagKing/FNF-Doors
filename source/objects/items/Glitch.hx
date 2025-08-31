package objects.items;

import shaders.GlitchPosterize;
import flixel.math.FlxRandom;

class Glitch extends Item{

    //holy fuck the glitch item is now ONLY ONE ITEM!!!!!
    public var songToGoTo:String = "";
    public var glitchedShader:GlitchPosterize;

    override function create(){
        this.itemData = {
            itemID: "error",
            displayName: lp("error")[0],
            displayDesc: lp("error")[1],
            isPlural: lp("error")[2],
            itemCoinPrice: new FlxRandom().int(100, 800),
            itemKnobPrice: new FlxRandom().int(2, 40),
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: ["story"]
        }

        glitchedShader = new GlitchPosterize();
        glitchedShader.amount = 0.1;

        this.shader = glitchedShader.shader;
    }

    override function update(elapsed:Float){
        this.itemData.itemCoinPrice = new FlxRandom().int(100, 800);
        this.itemData.itemKnobPrice = new FlxRandom().int(2, 40);
        
        glitchedShader.update(elapsed);
        super.update(elapsed);
    }

    override function onSongUse() { 
        cannotUse();
    }

    override function onStoryUse(){
        if(songToGoTo == ""){
            songToGoTo = new FlxRandom().getObject(["left-behind", "404"]);
        }
        PlayState.storyPlaylist = [songToGoTo];
        PlayState.SONG = Song.loadFromJson(Highscore.formatSong(songToGoTo, CoolUtil.defaultDifficulties.indexOf(DoorsUtil.curRun.runDiff)), songToGoTo);
        PlayState.isStoryMode = true;
        PlayState.targetDoor = DoorsUtil.curRun.curDoor;
        PlayState.storyDifficulty = CoolUtil.defaultDifficulties.indexOf(DoorsUtil.curRun.runDiff);
        LoadingState.loadAndSwitchState(new PlayState());
        DoorsUtil.curRun.curInventory.removeItem(itemData);
        super.onStoryUse();
    }
}