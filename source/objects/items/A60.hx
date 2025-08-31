package objects.items;

import flixel.math.FlxRandom;

class A60 extends Item{
    override function create(){
        this.itemData = {
            itemID: "a60",
            displayName: lp("a60")[0],
            displayDesc: lp("a60")[1],
            isPlural: lp("a60")[2],
            itemCoinPrice: 200,
            itemKnobPrice: -1,
            itemSlot: -1,
            durabilityRemaining: 1,
            maxDurability: 1,

            statesAllowed: []
        }
    }

    override function onSongUse() { 
        cannotUse();
    }

    override function onStoryUse(){
        /*PlayState.SONG = Song.loadFromJson('workloud', 'workloud');
        PlayState.isStoryMode = true;
        PlayState.storyDifficulty = CoolUtil.defaultDifficulties.indexOf(DoorsUtil.curRun.runDiff);
        LoadingState.loadAndSwitchState(new PlayState());*/
        cannotUse();
    }
}