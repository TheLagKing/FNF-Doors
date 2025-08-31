package backend.metadata;

import haxe.Json;
import sys.FileSystem;

import backend.metadata.DeathMetadata;
import backend.metadata.PerDiffMetadata;

class SongMetadata {
	public var artists:Array<String>;
	public var music:Array<String>;
	public var easyCharters:Array<String>;
	public var normalCharters:Array<String>;
	public var hardCharters:Array<String>;
	public var coders:Array<String>;

	public var displayName:String;
	public var internalName:String;
	public var category:String;
	public var hasHellDiff:Bool;
    public var useDoorsFontInCredit:Bool;

	public var forceUnlock:Bool;
	public var cost:Int;
	public var unlockMethod:String;

	public var difficulties:PerDiffMetadata;
	public var mechanicDifficulties:PerDiffMetadata;

	public var ostArtPath:String = null;
	public var songLengths:PerDiffMetadata = null;

    // METADATA 1.1 - Death sprites, Death speaker types & Death tip categories
    public var deathMetadata:DeathMetadata;

    public function new(songPath:String){
        var path = Paths.getPreloadPath('data/${songPath}/metadata.json');
        
        this.artists = [];
        this.music = [];
        this.easyCharters = [];
        this.normalCharters = [];
        this.hardCharters = [];
        this.coders = [];
        
        this.displayName = songPath;
        this.internalName = songPath;
        this.category = "freeplay";
        this.hasHellDiff = false;
        this.useDoorsFontInCredit = false;
        
        this.forceUnlock = false;
        this.cost = 0;
        this.unlockMethod = "freeplay";
        
        this.difficulties = {
            easy: -2,
            normal: -2,
            hard: -2,
            hell: -2
        };
        this.mechanicDifficulties = {
            easy: -2,
            normal: -2,
            hard: -2,
            hell: -2
        };
        
        this.ostArtPath = null;
        this.songLengths = {
            easy: 20,
            normal: 20,
            hard: 20,
            hell: 20
        };
        
        this.deathMetadata = new DeathMetadata();
        
        if (FileSystem.exists(path)) {
            var json:Dynamic = Json.parse(sys.io.File.getContent(path));
            
            if (json.artists != null) this.artists = json.artists;
            if (json.music != null) this.music = json.music;
            if (json.easyCharters != null) this.easyCharters = json.easyCharters;
            if (json.normalCharters != null) this.normalCharters = json.normalCharters;
            if (json.hardCharters != null) this.hardCharters = json.hardCharters;
            if (json.coders != null) this.coders = json.coders;
            
            if (json.displayName != null) this.displayName = json.displayName;
            if (json.internalName != null) this.internalName = json.internalName;
            if (json.category != null) this.category = json.category;
            if (json.hasHellDiff != null) this.hasHellDiff = json.hasHellDiff;
            if (json.useDoorsFontInCredit != null) this.useDoorsFontInCredit = json.useDoorsFontInCredit;
            
            if (json.forceUnlock != null) this.forceUnlock = json.forceUnlock;
            if (json.cost != null) this.cost = json.cost;
            if (json.unlockMethod != null) this.unlockMethod = json.unlockMethod;
            
            if (json.difficulties != null) this.difficulties = json.difficulties;
            if (json.mechanicDifficulties != null) this.mechanicDifficulties = json.mechanicDifficulties;
            
            if (json.ostArtPath != null) this.ostArtPath = json.ostArtPath;
            if (json.songLengths != null) this.songLengths = json.songLengths;

            if (json.deathMetadata != null) {
                if(json.deathMetadata.deathSpriteType != null) 
                    this.deathMetadata.deathSpriteType = json.deathMetadata.deathSpriteType;

                if(json.deathMetadata.deathSpeaker != null) 
                    this.deathMetadata.deathSpeaker = json.deathMetadata.deathSpeaker;

                if(json.deathMetadata.deathTipCategory != null) 
                    this.deathMetadata.deathTipCategory = json.deathMetadata.deathTipCategory;
            } 
        } else {
            trace('WARNING: No metadata.json found for ${songPath}');
        }
    }
}