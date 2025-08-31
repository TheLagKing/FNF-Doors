package online;

import flixel.math.FlxMath;
import flixel.addons.api.FlxGameJolt;
import flixel.FlxG;

using StringTools;

typedef RunLeaderboard = {
    var floor:Int; //only floor 1 for now but later what about floor 2 and rooms
    var diff:String;
    var scores:Array<LeaderboardRunScore>;
}

typedef LeaderboardRunScore = {
    var name:String;
    var score:Int;
    var acc:Float;
    var misses:Int;
    var knobModifier:Float;
    var modifiers:Array<String>;
}

typedef SongLeaderboard = {
    var song:String;
    var diff:String;
    var scores:Array<LeaderboardSongScore>;
} 

typedef LeaderboardSongScore = {
    var name:String;
    var acc:Float;
    var score:Int;
    var misses:Int;
    var scoreMod:Float;
}

//ty voiid chronicles, i'm changing this up a lot but it's a good starting point
class Leaderboards
{
    /**
     * Converts a string to a leaderboard song score.
     * 
     * @param data The string to convert.
     * @return The leaderboard song score.
     */
    public static function convertToLeaderboardScore(data:Dynamic):LeaderboardSongScore
    {
        var scoreMod = 1.0;
        for(mod in (data.modifiers : Array<Int>)){
            for(modifier in ModifierManager.defaultModifiers){
                if(modifier.ID == mod){
                    scoreMod += (modifier.knobAddition - 1) * modifier.knobMultiplier;
                    break;
                }
            }
        }

        return { 
            name: data.displayName, 
            acc: data.accuracy, 
            score: data.score, 
            misses: data.misses, 
            scoreMod: scoreMod};
    }

    /**
     * Adds a high score to the leaderboard.
     * @param isRun Whether the score is a run or a song.
     * @param songname The name of the song.
     * @param songdiff The difficulty of the song.
     * @param acc The accuracy of the score.
     * @param score The score achieved.
     * @param misses The number of misses during the score attempt.
     */
    public static function addHighScore(songname:String, songdiff:String, hash:String, acc:Float, score:Int, misses:Int, mods:Array<Int>)
    {        
        if(Glasshat.connected){
            Glasshat.addScore(
                songname, CoolUtil.defaultDifficulties.indexOf(CoolUtil.capitalize(songdiff)), hash, 
                acc, score, misses, mods
            );
        }
    }

    /**
     * Parses a leaderboard string.
     * 
     * @param str The string to parse.
     */
    public static function parseLeaderboard(data:Array<Dynamic>) //displayName, score, accuracy, misses
    {
        var scoreList:SongLeaderboard = {song: "", diff: "", scores: []};
        for (scr in data)
        {
            var score:LeaderboardSongScore = convertToLeaderboardScore(scr);
            scoreList.scores.push(score);
        }
        return scoreList;
    }

    /**
     * Retrieves the leaderboard for a given song and difficulty.
     * @param songname The name of the song.
     * @param songdiff The difficulty of the song.
     * @param callBack The callback function to be executed with the retrieved leaderboard data.
     */
    public static function getLeaderboard(songname:String, songdiff:String, callBack:Dynamic->Void)
    {
        if (Glasshat.connected)
        {
            Glasshat.getScores(songname, CoolUtil.defaultDifficulties.indexOf(CoolUtil.capitalize(songdiff)), 100, 0, function(returnData:Dynamic){
                if(returnData.Data == null){
                    callBack('error');
                } else if(returnData.Data.length == 0){
                    callBack('noScores');
                } else {
                    callBack(returnData.Data);
                }
            });
        }
        else 
        {
            callBack('notLoggedIn');
        }
    }
}