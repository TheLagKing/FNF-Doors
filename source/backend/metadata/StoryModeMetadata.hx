package backend.metadata;

import backend.system.NativeAPI;
import haxe.Json;
import sys.FileSystem;

// Basic data types
typedef RarityData = {
    var name:String;
    var weight:Float;
    var items:Array<String>;
}

typedef FurnitureData = {
    var name:String;
    var weight:Float;
    var sides:Array<String>;
    var canHavePainting:Bool;
}

typedef PaintingData = {
    var side:String;
    var isWindow:Bool;
    var ?patterns:Null<Array<String>>;
    var chance:Float;
}

typedef NearSeekData = {
    var id:Int;
    var weight:Float;
    var windowBlockedSides:Array<String>;
    var paintingBlockedSides:Array<String>;
    var furnitureBlockedSides:Array<String>;
}

typedef Puzzle = {
    var name:String;
    var type:String;
    var spawnType:String;
    var spawnArgs:Array<Dynamic>;
    var ?musicOverride:String;
}

// Music-related types
typedef MusicVariantData = {
    var name:String;
    var bpm:Int;
    var conditions:Array<String>;
    var conditionsData:Array<Dynamic>;
    var variantPriority:Int;
}

typedef MusicData = {
    var name:String;
    var bpm:Int;
    var doorInterval:Array<Int>;
    var variants:Array<MusicVariantData>;
}

// Song pool related types
typedef EntitySongCollection = {
    var name:String;
    var weight:Float;
    var songs:Array<String>;
}

typedef SongPool = {
    var doorInterval:Dynamic;
    var entities:Array<EntitySongCollection>;
}

// Room and spawning related types
typedef IntervalSpawningInfo = {
    var interval:Array<Int>;
    var minimumPerInterval:Int;
    var additionalSpawnChance:Float;
}

typedef SpecificDoorData = {
    var name:String;
    var attracts:Bool;
    var ?attractionInterval:Array<Int>;
    var spawnsAt:Int;
    var leavesAt:Int;
    var ?modifiesDoors:Array<Int>;
    var ?modificationID:String;
    var ?musicOverride:String;
}

typedef EntityToEncounterData = {
    var entityName:String;
    var encounterType:String; // SONG or MECHANIC
}

typedef RoomData = {
    var name:String;
    var spawnInterval:Array<Int>;
    var preBossViable:Bool;
    var colors:Array<String>;
    var weight:Float;
    var furnitureSides:Array<String>;
    var furniture:Array<FurnitureData>;
    var paintings:Array<PaintingData>;
    var seekData:Array<NearSeekData>;
    var canSpawn:Array<String>;
    var ?musicOverride:String;
    var entitiesToEncounter:Array<EntityToEncounterData>;
}

enum RunRanking {
    P;
    S;
    A;
    B;
    C;
    D;
    F;
}

class StoryModeMetadata {
	public var reviveAmount:Int;
	public var difficulty:String;
	public var specificDoors:Array<SpecificDoorData>;
	public var intervals:Array<Int>;
	public var startingRoom:Int;
	public var maxRooms:Int;
	public var roomTypes:Array<RoomData>;
	public var itemValues:Array<RarityData>;
	public var songPools:Array<SongPool>;
	public var puzzlePool:Array<Puzzle>;
    public var musicData:Array<MusicData>;
    public var entitiesToEncounter:Array<EntityToEncounterData>;

    public function new(type:String, difficulty:String){
		var path = 'assets/storymode/${type}/normal.json';
        if(!FileSystem.exists(path)){
            NativeAPI.showMessageBox(
                'Missing story mode file!',
                'The file assets/storymode/${type}/${difficulty}.json wasn\' found.'
            );
            return;
        }
        var rawJson:String = sys.io.File.getContent(path);
        var data:Dynamic = Json.parse(rawJson);

        this.difficulty = difficulty;
        this.reviveAmount = data.reviveAmount;
        this.intervals = data.intervals;
        this.startingRoom = data.startingRoom;
        this.maxRooms = data.maxRooms;

        this.specificDoors = data.specificDoors;
        this.roomTypes = data.roomTypes;
        this.itemValues = data.itemValues;
        this.songPools = data.songPools;
        this.puzzlePool = data.puzzlePool;
        this.musicData = data.musicData;
        this.entitiesToEncounter = data.entitiesToEncounter;
        
        // If difficulty isn't normal, try to load and override with difficulty-specific data
        if (difficulty == "normal") return;

        var diffPath = 'assets/storymode/${type}/${difficulty}.json';
        if (!FileSystem.exists(diffPath)) {
            NativeAPI.showMessageBox(
                'Missing story mode file!',
                'The file assets/storymode/${type}/${difficulty}.json wasn\' found.'
            );
            return;
        }
        var diffRawJson:String = sys.io.File.getContent(diffPath);
        var diffData:Dynamic = Json.parse(diffRawJson);
        
        // Override basic properties if they exist in the difficulty file
        if (Reflect.hasField(diffData, "reviveAmount")) this.reviveAmount = diffData.reviveAmount;
        if (Reflect.hasField(diffData, "intervals")) this.intervals = diffData.intervals;
        if (Reflect.hasField(diffData, "startingRoom")) this.startingRoom = diffData.startingRoom;
        if (Reflect.hasField(diffData, "maxRooms")) this.maxRooms = diffData.maxRooms;
        if (Reflect.hasField(diffData, "difficulty")) this.difficulty = diffData.difficulty;
        
        // Override complex properties if they exist in the difficulty file
        if (Reflect.hasField(diffData, "specificDoors")) {
            overrideSpecificDoors(cast diffData.specificDoors);
        }
        
        if (Reflect.hasField(diffData, "roomTypes")) {
            overrideRoomTypes(cast diffData.roomTypes);
        }

        if (Reflect.hasField(diffData, "puzzlePool")) {
            overridePuzzlePoolData(cast diffData.puzzlePool);
        }
        
        if (Reflect.hasField(diffData, "itemValues")) {
            overrideItemValues(cast diffData.itemValues);
        }
        
        if (Reflect.hasField(diffData, "songPools")) {
            overrideSongPools(cast diffData.songPools);
        }

        if (Reflect.hasField(diffData, "musicData")) {
            overrideMusicData(cast diffData.musicData);
        }

        if (Reflect.hasField(diffData, "entitiesToEncounter")) {
            overrideEntitiesToEncounter(cast diffData.entitiesToEncounter);
        }
    }
        
    private function overrideSpecificDoors(specificDoors:Array<SpecificDoorData>):Void {
        for (specificDiffDoor in specificDoors) {
            if (!Reflect.hasField(specificDiffDoor, "name")) continue;

            var overridenDoor = this.specificDoors.filter(door -> door.name == specificDiffDoor.name)[0];
            if (overridenDoor == null) {
                this.specificDoors.push(specificDiffDoor);
            }

            var index = this.specificDoors.indexOf(overridenDoor);
            
            // Update each field if present in the difficulty-specific data
            var fields = ["attracts", "spawnsAt", "leavesAt", "attractionInterval", 
                 "modifiesDoors", "modificationID", "musicOverride"];
            
            for (field in fields) {
                if (Reflect.hasField(specificDiffDoor, field))
                    Reflect.setField(this.specificDoors[index], field, Reflect.field(specificDiffDoor, field));
            }
        }
    }
        
    private function overrideRoomTypes(roomTypes:Array<RoomData>):Void {
        for (roomType in roomTypes) {
            if (!Reflect.hasField(roomType, "name")) continue;

            var overridenType = this.roomTypes.filter(type -> type.name == roomType.name)[0];
            if (overridenType == null) {
                this.roomTypes.push(roomType);
            } 

            var index = this.roomTypes.indexOf(overridenType);
            
            // Update basic room properties
            var basicFields = ["spawnInterval", "preBossViable", "colors", 
                     "weight", "furnitureSides", "canSpawn", "musicOverride"];
            
            for (field in basicFields) {
                if (Reflect.hasField(roomType, field))
                    Reflect.setField(this.roomTypes[index], field, Reflect.field(roomType, field));
            }
            
            // Override nested objects
            if (Reflect.hasField(roomType, "furniture")) {
                overrideFurniture(index, cast roomType.furniture);
            }
            
            if (Reflect.hasField(roomType, "paintings")) {
                overridePaintings(index, cast roomType.paintings);
            }
            
            if (Reflect.hasField(roomType, "seekData")) {
                overrideSeekData(index, cast roomType.seekData);
            }
        }
    }
        
    private function overrideFurniture(roomIndex:Int, furnitures:Array<FurnitureData>):Void {
        for (furniture in furnitures) {
            if (!Reflect.hasField(furniture, "name")) continue;
            
            var overridenFurniture = this.roomTypes[roomIndex].furniture.filter(f -> f.name == furniture.name)[0];
            if (overridenFurniture == null) {
                this.roomTypes[roomIndex].furniture.push(furniture);
            } 
            
            var index = this.roomTypes[roomIndex].furniture.indexOf(overridenFurniture);
            
            // Update furniture fields
            var fields = ["weight", "sides", "canHavePainting"];
            
            for (field in fields) {
                if (Reflect.hasField(furniture, field))
                    Reflect.setField(this.roomTypes[roomIndex].furniture[index], field, Reflect.field(furniture, field));
            }
        }
    }
        
    private function overridePaintings(roomIndex:Int, paintings:Array<PaintingData>):Void {
        for (painting in paintings) {
            if (!Reflect.hasField(painting, "side") || !Reflect.hasField(painting, "isWindow")) continue;
            
            var overridenPainting = this.roomTypes[roomIndex].paintings.filter(
            p -> p.side == painting.side && p.isWindow == painting.isWindow
            )[0];
            
            if (overridenPainting == null) {
                this.roomTypes[roomIndex].paintings.push(painting);
            } 
            
            var index = this.roomTypes[roomIndex].paintings.indexOf(overridenPainting);
            
            // Update painting fields
            if (Reflect.hasField(painting, "patterns")) 
                this.roomTypes[roomIndex].paintings[index].patterns = painting.patterns;
            if (Reflect.hasField(painting, "chance")) 
                this.roomTypes[roomIndex].paintings[index].chance = painting.chance;
        }
    }
        
    private function overrideSeekData(roomIndex:Int, seekData:Array<NearSeekData>):Void {
        for (seek in seekData) {
            if (!Reflect.hasField(seek, "id")) continue;
            
            var overridenSeek = this.roomTypes[roomIndex].seekData.filter(s -> s.id == seek.id)[0];
            if (overridenSeek == null) {
                this.roomTypes[roomIndex].seekData.push(seek);
            } 
            
            var index = this.roomTypes[roomIndex].seekData.indexOf(overridenSeek);
            
            // Update seek data fields
            var fields = ["weight", "windowBlockedSides", "paintingBlockedSides", "furnitureBlockedSides"];
            
            for (field in fields) {
                if (Reflect.hasField(seek, field))
                    Reflect.setField(this.roomTypes[roomIndex].seekData[index], field, Reflect.field(seek, field));
            }
        }
    }

    public function overridePuzzlePoolData(puzzlePool:Array<Puzzle>):Void {
        if (puzzlePool == null || puzzlePool.length == 0) return;
        
        for (puzzle in puzzlePool) {
            if (!Reflect.hasField(puzzle, "name")) continue;
            
            var existingPuzzle = this.puzzlePool.filter(p -> p.name == puzzle.name)[0];
            if (existingPuzzle == null) {
                this.puzzlePool.push(puzzle);
            } else {
                var index = this.puzzlePool.indexOf(existingPuzzle);
                
                var fields = ["type", "spawnType", "spawnArgs", "musicOverride"];
                
                for (field in fields) {
                    if (Reflect.hasField(puzzle, field))
                        Reflect.setField(this.puzzlePool[index], field, Reflect.field(puzzle, field));
                }
            }
        }
    }

    public function overrideItemValues(rarityData:Array<RarityData>):Void {
        if (rarityData == null || rarityData.length == 0) return;
        
        for (rarity in rarityData) {
            if (!Reflect.hasField(rarity, "name")) continue;
            
            var existingRarity = this.itemValues.filter(r -> r.name == rarity.name)[0];
            if (existingRarity == null) {
                this.itemValues.push(rarity);
            } else {
                var index = this.itemValues.indexOf(existingRarity);
                
                if (Reflect.hasField(rarity, "weight"))
                    this.itemValues[index].weight = rarity.weight;
                    
                if (Reflect.hasField(rarity, "items"))
                    this.itemValues[index].items = rarity.items;
            }
        }
    }

    public function overrideSongPools(songPools:Array<SongPool>):Void {
        if (songPools == null || songPools.length == 0) return;
        
        this.songPools = songPools;
    }

    public function overrideMusicData(musicData:Array<MusicData>):Void {
        if (musicData == null || musicData.length == 0) return;
        
        this.musicData = musicData;
    }

    public function overrideEntitiesToEncounter(entitiesData:Array<EntityToEncounterData>){
        if (entitiesData == null || entitiesData.length == 0) return;
        
        this.entitiesToEncounter = entitiesData;
    }
}