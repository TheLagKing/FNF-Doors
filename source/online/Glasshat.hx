package online;

import haxe.Json;
import flixel.addons.api.FlxGlasshat;
import lime.utils.Assets;
import flixel.util.FlxTimer;
import flixel.FlxG;
import PopUp;
import haxe.io.Bytes;

class Glasshat
{
    public static var fetchingData:Bool = false;

    public static var connectedToGame:Bool = false;
    public static var loggedIn:Bool = false;

    public static var connected(get, null):Bool;
    static function get_connected():Bool {
		return connectedToGame && loggedIn;
	}

    static var gotResponse:Bool = false;
    public static function initStuffs():String
    {
        if (FlxG.save.data.doorsUsername == null)
            return 'no login found';
        if (FlxG.save.data.doorsPassword == null)
            return 'no login found';

        #if !GLASSHAT
        Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", "Glasshat Online Disabled."));
        return 'disabled';
        #end

        new FlxTimer().start(10, function(timer:FlxTimer)
        {
            if (connected)
                return;

            if (!gotResponse)
            {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Couldn\'t connect to Glasshat Online servers'));
            }
        });

        FlxGlasshat.init(FlxG.save.data.doorsUsername, FlxG.save.data.doorsPassword, function(returnData:Dynamic) 
        {
            gotResponse = true;
            connectedToGame = true;
            if(returnData == false){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Error signing into Glasshat Online'));
            }
            loggedIn = (returnData.Code == 200);
            if (loggedIn)
            {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Signed into Glasshat Online'));
            }
            else 
            {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Error signing into Glasshat Online'));
            }
        });
        
        return 'trying to login';
    }

    public static function test()
    {
        //make tests if you need lmfao
    }

    public static function syncAchievements()
    {
                
    }
    

    /*public static function unlockAchievement(id:Int)
    {
        if (connected)
        {
            FlxGlasshat.addTrophy(id);
        }
    }

    public static function checkAchievement(id:Int, ?func:Map<String,String>->Void)
    {
        if (connected)
        {
            FlxGlasshat.fetchTrophy(id, function(mapThing:Map<String,String>)
            {
                if (func != null)
                    func(mapThing);
            });
        }
    }

    public static function getTimePlayed(func:Map<String,String>->Void)
    {
        if (connected)
        {
            FlxGlasshat.fetchData('Time', true, function(mapThing:Map<String,String>)
            {
                if (func != null)
                    func(mapThing);
            });
        }
    }*/

    public static function register()
    {
        FlxGlasshat.registerUser(FlxG.save.data.doorsUsername, FlxG.save.data.doorsDisplayName, FlxG.save.data.doorsPassword, function(returnData:Dynamic) 
        {
            if(returnData.Code == 200){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Account successfully created!'));
                login();
            } else if (returnData.Code == 409) {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'A user with the email ' + FlxG.save.data.doorsUsername + ' already exists... Try a new one!'));
            } else {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'There seems to be an unknown error... Try again soon.'));
            }
        });
    }

    public static function login()
    {
        FlxGlasshat.authUser(FlxG.save.data.doorsUsername, FlxG.save.data.doorsPassword, function(returnData:Dynamic) 
        {
            loggedIn = (returnData.Code == 200);
            if (loggedIn)
            {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Signed into Glasshat Online'));
            } else {
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Couldn\'t sign in as ' + FlxG.save.data.doorsUsername));
            }
        });
    }

    public static inline function getScores(song:String, diff:Int, ?limit:Int = 100, ?offset:Int = 0, callBack:Dynamic){
        return FlxGlasshat.fetchScore(song, CoolUtil.defaultDifficulties[diff], limit, offset, callBack);
    }

    public static function addScore(
        songname:String, diff:Int, hash:String, 
        acc:Float, score:Int, misses:Int, mods:Array<Int>
        )
    {
        FlxGlasshat.addScore(songname, CoolUtil.defaultDifficulties[diff], hash, score, acc, misses, mods, function(returnData2:Dynamic){
            if(returnData2.Code == "401"){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 
                    'You need to log into Glasshat to publish your scores to the Leaderboards.'
                ));
                return;
            }

            if(returnData2.Code == "404"){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 
                    'Score not uploaded. If you haven\'t modified game files, please report this issue.'
                ));
                return;
            }

            if(returnData2.Code == "406"){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 
                    'This was not your high score... You can do better than that ! Good luck !'
                ));
                return;
            }


            Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", 'Successfully uploaded your new highscore to Glasshat!'));
        }, true);
    }
}