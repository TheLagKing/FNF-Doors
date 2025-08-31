package states.mechanics;

class LeftSide extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function createPost()
    {
        PlayState.healthGain *= -1;
        PlayState.healthLoss *= -1;

        DoorsUtil.curRun.latestHealth = -DoorsUtil.curRun.latestHealth+DoorsUtil.maxHealth;
        game.health = -game.health+DoorsUtil.maxHealth;

        game.leftSideShit = true;

        game.iconP1.changeIcon(game.dad.healthIcon);
        game.iconP2.changeIcon(game.boyfriend.healthIcon);

        game.reloadHealthBarColors();

        if(!ClientPrefs.data.middleScroll)
        {
            for(strum in game.playerStrums)
            {
                strum.x -= 640;
            }

            for(strum in game.opponentStrums)
            {
                strum.x += 640;
            }
        }
    }

    override function triggerEventNote(eventName:String, value1:String, value2:String, strumTime:Float)
    {
        if(eventName == 'Change Character')
        {
            game.iconP1.changeIcon(game.dad.healthIcon);
            game.iconP2.changeIcon(game.boyfriend.healthIcon);
        }
    }

    override function endSong()
    {
        if(PlayState.isStoryMode)
        {
            DoorsUtil.curRun.latestHealth = -DoorsUtil.curRun.latestHealth+DoorsUtil.maxHealth;
            DoorsUtil.saveRunData();
        }
        return false;
    }
}