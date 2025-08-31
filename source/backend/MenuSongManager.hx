package backend;

import openfl.events.Event;
import flixel.math.FlxRandom;
import flixel.sound.filters.FlxFilteredSound;

class MenuSongManager{
    public static var curMusic:String = "";
    private static var curPitchTween:FlxTween;
    private static var curVolTween:FlxTween;

    private static var fadingOutSounds:Array<FlxFilteredSound> = [];
    
    public static function init():Void {
        FlxG.stage.addEventListener(Event.DEACTIVATE, onFocusLost);
        FlxG.stage.addEventListener(Event.ACTIVATE, onFocusGained);
    }
    
    private static function onFocusLost(?_):Void {
        for (sound in fadingOutSounds) {
            if (sound != null && sound.playing) {
                sound.pause();
            }
        }
    }
    
    private static function onFocusGained(?_):Void {
        for (sound in fadingOutSounds) {
            if (sound != null && !sound.playing) {
                sound.resume();
            }
        }
    }

    public static function changeMusic(songName:String, ?volume:Float = 1, ?bpm:Float = 140){
        @:privateAccess(FlxSound){
            if(curMusic != songName){
                if(songName == ""){
                    FlxG.sound.music.stop();
                } else {
                    FlxG.sound.playMusic(Paths.music(songName), volume, true);
                    Conductor.changeBPM(bpm);
                    curMusic = songName;
                    FlxTween.tween(FlxG.sound.music, {pitch:1.0}, 0.3);
                }
            }
        }
    }

    public static function crossfade(songName:String, volume:Float, bpm:Int, ?crossfade:Bool = true){
        if(songName == "") { 
            cleanupFadingSounds();
            changeMusic(songName, 0, 140);
            return;
        }

        if(songName != curMusic){
            if(crossfade && FlxG.sound.music != null){
                cleanupFadingSounds();
                
                var oldMusic:FlxFilteredSound = FlxG.sound.music;
                oldMusic.persist = true;
                
                fadingOutSounds.push(oldMusic);
                
                var newMusic:FlxFilteredSound = new FlxFilteredSound();
                newMusic.loadEmbedded(Paths.music(songName), true);
                newMusic.volume = 0;
                newMusic.persist = true;
                newMusic.play();
                
                oldMusic.fadeOut(1.5, 0, function(_){
                    oldMusic.stop();
                    oldMusic.destroy();
                    fadingOutSounds.remove(oldMusic);
                });
                
                newMusic.fadeIn(1.5, 0, volume);
                
                // Set as main music
                FlxG.sound.music = newMusic;
                Conductor.changeBPM(bpm);
                curMusic = songName;
            } else {
                cleanupFadingSounds();
                changeMusic(songName, volume, bpm);
            }
        }
    }

    private static function cleanupFadingSounds():Void {
        for(sound in fadingOutSounds) {
            sound.stop();
        }
        fadingOutSounds = [];
    }

    public static function changeSongPitch(to:Float, duration:Float){
        if(curMusic != null || curMusic != ""){
            if(curPitchTween != null) curPitchTween.cancel();
            curPitchTween = FlxTween.tween(FlxG.sound.music, {pitch:to}, duration);
        }
    }

    public static function changeSongVolume(to:Float, duration:Float){
        if(curMusic != null || curMusic != ""){
            if(curVolTween != null) curVolTween.cancel();
            if(duration == 0){
                FlxG.sound.music.volume = to;
            } else {
                curVolTween = FlxTween.tween(FlxG.sound.music, {volume:to}, duration);
            }
        }
    }

    public static var trackedSounds:Array<FlxSound> = [];
    public static function playSound(soundName:String, ?volume:Float, ?callback:Void->Void, ?delay:Float = 0.0){
        if(delay == 0.0){
            var sound:FlxSound = new FlxSound();
            sound.loadEmbedded(Paths.sound(soundName));
            sound.volume = volume;
            sound.onComplete = function(){
                if(callback != null) callback();
                trackedSounds.remove(sound);
            };
            sound.persist = true;
            trackedSounds.push(sound);
            sound.play();
            FlxG.sound.list.add(sound);
        } else {
            new FlxTimer().start(delay, function(tmr){
                var sound:FlxSound = new FlxSound();
                sound.loadEmbedded(Paths.sound(soundName));
                sound.volume = volume;
                sound.onComplete = function(){
                    if(callback != null) callback();
                    trackedSounds.remove(sound);
                };
                sound.persist = true;
                trackedSounds.push(sound);
                sound.play();
                FlxG.sound.list.add(sound);
            });
        }
    }

    public static function playSoundWithRandomPitch(soundName:String, pitchRange:Array<Float>, ?volume:Float){
        var sound:FlxSound = new FlxSound();
        sound.loadEmbedded(Paths.sound(soundName));
        sound.volume = volume;
        sound.persist = true;
        sound.pitch = new FlxRandom().float(pitchRange[0], pitchRange[1]);
        trackedSounds.push(sound);
        sound.onComplete = function(){
            trackedSounds.remove(sound);
        };
        sound.play();
    }
}