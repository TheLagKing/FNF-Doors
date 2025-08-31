package backend.storymode;

import lime.ui.KeyCode;
import ModifierManager;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import haxe.Unserializer;
import haxe.Serializer;
import backend.metadata.StoryModeMetadata;

class DoorsRun {
	var type:String = "F1"; // this is where you say "hey this is a floor 1 run" or "hey this is a rooms run"

	public var initialDoor:Int = -1;

	public var revivesLeft:Int = 3;
	public var latestHealth:Float = DoorsUtil.maxHealth ?? 2;
	public var runMoney:Int = 0;
    public var runDiff:String = "normal";
    public var runMisses:Int = 0;
    public var runScore:Int = 0;
	public var runEncounters:Array<String> = [];
    public var runRating:Float = 0.0; // Will reset to the acc of the first song you beat and do the average of every song onwards
	public var runModifiers:Array<Modifier> = [];
	public var runKnobModifier:Float = 1.0;
	public var runHours:Int = 0; 
	public var runSeconds:Float = 0.0; //when 3600 seconds, hours++

	public var lastEntity:String = "";
	public var nbConsecutiveEntities:Int = 0;

	public var entitiesToEncounter:Array<EntityToEncounterData> = [];
	public var entitiesEncountered:Map<String, Int> = [];

	public var curDoor:Int = -1;
	
	//item vars
	public var curInventory:InventoryManager = null;

	public var rooms:Array<StoryRoom> = [];
	public var songsPlayed:Array<String> = [];

	public var songPools:Array<SongPool> = [];
	public var sawGreenhousePopup:Bool = false;

	public var currentRoom(get, default):StoryRoom;
	public function get_currentRoom(){
		return rooms[curDoor - initialDoor];
	}

	public function new(?type:String = "F1", ?difficulty:String = "normal", ?modifiers:Array<Modifier>, ?knobModifier:Float){
		DoorsUtil.curRun = this;
		if(modifiers != null) this.runModifiers = modifiers;
		if(knobModifier != null) this.runKnobModifier = knobModifier;
		if(curInventory == null || curInventory.items == null) curInventory = new InventoryManager();

		type = type.toLowerCase();

		makeNewRun(type, difficulty);
		save();
	}

	function returnCorrectPool(curDoor:Int, smMetadata:StoryModeMetadata){
		for(pool in smMetadata.songPools){
			if(Std.isOfType(pool.doorInterval, Array)){
				if(pool.doorInterval[0] < curDoor && pool.doorInterval[1] > curDoor) return pool.entities;
			}
		}

		return [];
	}

	function returnSongArrayFromPool(pool:Array<EntitySongCollection>){
		var weightArr:Array<Float> = [];
		var songsArray:Array<Array<String>> = [];
		for(entity in pool){
			if(DoorsUtil.modifierActive(27) && entity.name == "halt"){
				weightArr.push(entity.weight * 2);
			} else {
				weightArr.push(entity.weight);
			}
			songsArray.push(entity.songs);
		}

		if(DoorsUtil.modifierActive(16)) {
			for(i in 1...weightArr.length){
				weightArr[i] /= 2;
			}
		}
		if(DoorsUtil.modifierActive(17)) {
			for(i in 1...weightArr.length){
				weightArr[i] *= 2;
			}
		}
		return FlxG.random.getObject(songsArray, weightArr);
	}
	
	inline function hasNeverPlayedSong(song:String):Bool{
		if(DoorsUtil.modifierActive(18)) return true;
		if(songsPlayed.contains(song)) return false;
		return true;
	}

	function getSpecificPool(specific:Dynamic, smMetadata:StoryModeMetadata){
		for(pool in smMetadata.songPools){
			if(specific == pool.doorInterval){
				return pool.entities;
			} 
		}

		return null;
	}

	public function getReplacementSong(ogSong:String, door:Int, ?specificPoolName:String){
		var formattedOg:String = ogSong.toLowerCase().trim();

		if(debug) {
			trace("OG Song is : " + formattedOg);
			trace("Player has played : " + songsPlayed);
			trace("Game thinks player has never played OG Song ? : " + hasNeverPlayedSong(formattedOg));
		} 
		
		for(pool in songPools){
			if(Std.isOfType(pool.doorInterval, Array)){
				if(!(pool.doorInterval[0] < door && pool.doorInterval[1] > door)) continue;

				for(entity in pool.entities){
					if(!entity.songs.contains(formattedOg)) continue;

					if(lastEntity == entity.name) 
						nbConsecutiveEntities += 1;
					else nbConsecutiveEntities = 0;
					lastEntity = entity.name;

					if(debug) {
						trace("lastEntity : "+lastEntity);
						trace("entity.name : "+entity.name);
					}
				}
			} else {
				// Sanity check
				nbConsecutiveEntities = 0;
			}
		}

		var isFindingSkipReplacement:Bool = false;
		switch(nbConsecutiveEntities){
			case 0: // Don't do anything
				
			case 1: // Skip the song
				return "None";
			default: // 2 and more = find another entity to replace the song by
				isFindingSkipReplacement = true;
		}

		if(debug) {
			trace("nbConsecutiveEntities : "+nbConsecutiveEntities);
			trace("isFindingSkipReplacement : "+isFindingSkipReplacement);
		}

		if(hasNeverPlayedSong(formattedOg) && !isFindingSkipReplacement) return ogSong;

		for(pool in songPools){
			if(Std.isOfType(pool.doorInterval, Array)){
				if(pool.doorInterval[0] < door && pool.doorInterval[1] > door){
					if(debug) {
						trace("Found suitable pool : " + pool);
					}
					for(entity in pool.entities){
						if(isFindingSkipReplacement && !entity.songs.contains(formattedOg)){
							if(debug) {
								trace("Found entity pool that contains OgSong : " + entity.songs);
							}
							var testicle:Array<String> = entity.songs;
							for (song in songsPlayed) {
								testicle.remove(song);
							}

							if(testicle.length == 0) return "None";

							var song:String = FlxG.random.getObject(testicle);
							while(!hasNeverPlayedSong(song)){
								song = FlxG.random.getObject(testicle);
								if(debug) {
									trace("Trying to switch to : " + song);
									trace("Does the game accept this song ? : " + song);
								}
							}
							return song;
						}



						if(entity.songs.contains(formattedOg)){
							if(debug) {
								trace("Found entity pool that contains OgSong : " + entity.songs);
							}
							var testicle:Array<String> = entity.songs;
							for (song in songsPlayed) {
								testicle.remove(song);
							}

							if(testicle.length == 0) return "None";

							var song:String = FlxG.random.getObject(testicle);
							while(!hasNeverPlayedSong(song)){
								song = FlxG.random.getObject(testicle);
								if(debug) {
									trace("Trying to switch to : " + song);
									trace("Does the game accept this song ? : " + song);
								}
							}
							return song;
						}
					}
				}
			} else if (Std.isOfType(pool.doorInterval, String)) {
				if(isFindingSkipReplacement) return "None";
				if(pool.doorInterval == specificPoolName){
					if(debug) {
						trace("Found suitable pool : " + pool);
					}
					for(entity in pool.entities){
						if(entity.songs.contains(formattedOg)){
							if(debug) {
								trace("Found entity pool that contains OgSong : " + entity.songs);
							}
							var testicle:Array<String> = entity.songs;
							for (song in songsPlayed) {
								testicle.remove(song);
							}
							
							if(testicle.length == 0) return "None";

							var song:String = FlxG.random.getObject(testicle);
							if(debug) {
								trace("Trying to switch to : " + song);
								trace("Does the game accept this song ? : " + hasNeverPlayedSong(song));
							}
							while(!hasNeverPlayedSong(song)){
								song = FlxG.random.getObject(testicle);
								if(debug) {
									trace("Trying to switch to : " + song);
									trace("Does the game accept this song ? : " + hasNeverPlayedSong(song));
								}
							}
							return song;
						}
					}
				}
			}
		}

		return "None";
	}
	
	/**
	 * This function chooses the next song to play based on the door number and various weights.
	 * @param door The current door number.
	 * @return The name of the chosen song as a string.
	 */
	public function choosingNextSong(specialThing:Null<String>, door:Int, smMetadata:StoryModeMetadata):Dynamic {
		var songPicker = FlxG.random.int();
		if (specialThing == "lobby"){
			return 'None';
		}
		if(specialThing != null){
			var pool = getSpecificPool(specialThing, smMetadata);
			if(pool != null){
				var songArr = returnSongArrayFromPool(pool);
				if(songArr.length > 0){
					return FlxG.random.getObject(songArr);
				}
			}
		}

		var pool = returnCorrectPool(door, smMetadata);
		if(pool.length > 0){
			var songArr = returnSongArrayFromPool(pool);
			if(songArr.length > 0)
				return FlxG.random.getObject(songArr);
		}
		return "None";
	}
		
	function handleFurniture(furniture:String, smMetadata:StoryModeMetadata):Dynamic{
		var hasItem = false;
		var theItem = "";
		var itemDurability = 1;
		var hasTimothy = false;
		var timSong = "";
		var jackSong = "";
		var drawerMoney = 0;

		switch(furniture){
			case "drawer":
				var itemChance:Int = 30;
				if(DoorsUtil.modifierActive(10)) itemChance = 40;
				if(DoorsUtil.modifierActive(11)) itemChance = 15;
				if(DoorsUtil.modifierActive(12)) itemChance = 0;
				hasItem = FlxG.random.bool(itemChance);
				theItem = "";
				if(hasItem){
					var rarityWeights:Array<Float> = [];
					var availableRarities:Array<String> = [];

					for(rarityData in smMetadata.itemValues){
						availableRarities.push(rarityData.name);
						rarityWeights.push(rarityData.weight);
					}
					var selectedRarity:String = FlxG.random.getObject(availableRarities, rarityWeights);

					for(rarityData in smMetadata.itemValues){
						if(rarityData.name == selectedRarity){
							theItem = FlxG.random.getObject(rarityData.items);
						}
					}

					if(debug) trace(smMetadata.itemValues);
					if(debug) trace(selectedRarity);
					if(debug) trace(theItem);
				}

				if(!hasItem){
					var timothyChance:Float = 15;
					if(DoorsUtil.modifierActive(21)) timothyChance = 0;
					if(DoorsUtil.modifierActive(36)) timothyChance = 30;
					if(FlxG.random.bool(timothyChance)) {
						var timothyPool = getSpecificPool("timothy", smMetadata);
						if(timothyPool != null){
							var availableSongs = returnSongArrayFromPool(timothyPool);
							if(availableSongs.length > 0){
								timSong = FlxG.random.getObject(availableSongs);
								hasTimothy = true;
							}
						}
					}
				}

				if(!hasItem && !hasTimothy){
					if(FlxG.random.bool(90)){
						var moneyValues = [5, 10, 20, 25, 50, 100];
						var moneyWeights = [15, 12, 6, 4, 1, 0.3];

						if(DoorsUtil.modifierActive(7)) {
							var adjustedMoney:Array<Int> = [];
							for(amount in moneyValues){
								adjustedMoney.push(Math.ceil(amount * 1.4));
							}
							moneyValues = adjustedMoney;
						}

						if(DoorsUtil.modifierActive(8)) {
							var adjustedMoney:Array<Int> = [];
							for(amount in moneyValues){
								adjustedMoney.push(Math.ceil(amount * 0.6));
							}
							moneyValues = adjustedMoney;
						}

						if(DoorsUtil.modifierActive(9)) {
							var adjustedMoney:Array<Int> = [];
							for(amount in moneyValues){
								adjustedMoney.push(Math.ceil(amount * 0));
							}
							moneyValues = adjustedMoney;
						}

						drawerMoney = FlxG.random.getObject(moneyValues, moneyWeights);
					} else drawerMoney = 0;
				}
				return {
					hasItem: hasItem,
					theItem: theItem,
					isOpened: false,
					timSong: timSong,
					hasTimothy: hasTimothy,
					howMuchMoney: drawerMoney
				};
			case "closet":
				var hasJack = FlxG.random.bool(2);
				jackSong = "";
				if(hasJack){
					var pool = getSpecificPool("jack", smMetadata);
					if(pool != null){
						var songArr = returnSongArrayFromPool(pool);
						if(songArr.length > 0){
							jackSong = FlxG.random.getObject(songArr);
							hasJack = true;
						}
					}
				}
				return {
					hasJack: hasJack,
					isOpened: false,
					jackSong: jackSong
				};
			case "table":
				var paperID = 0;
				var papers:Bool = FlxG.random.bool(75);
				if(papers){
					paperID = FlxG.random.int(1, 41);
				}
				var booksID = 0;
				var books:Bool = FlxG.random.bool(50);
				if(books){
					booksID = FlxG.random.int(0, 1);
				}

				return {
					hasPaper: papers,
					paperModel: paperID,
					hasBooks:books,
					booksModel: booksID
				};
			default:
				return null;
		}
	}
	
	final debug:Bool = #if debug true #else false #end;
	public function makeNewRun(?type:String = "F1", ?difficulty:String = "normal"){
		var smMetadata:StoryModeMetadata = new StoryModeMetadata(type, difficulty);

		this.revivesLeft = smMetadata.reviveAmount ?? 3;
		this.runDiff = difficulty ?? "normal";
		this.initialDoor = smMetadata.startingRoom;
		this.songPools = smMetadata.songPools;

		this.entitiesToEncounter = smMetadata.entitiesToEncounter;
		this.entitiesEncountered = [];
		for(entityData in smMetadata.entitiesToEncounter) {
			this.entitiesEncountered.set(entityData.entityName, 0);
		}

		var i = smMetadata.startingRoom;
		var guaranteedSpawns:Map<String, Array<Map<String, Array<Dynamic>>>> = [];
		
		for(pool in smMetadata.puzzlePool){
			if(!guaranteedSpawns.exists(pool.name)){
				guaranteedSpawns.set(pool.name, [makeGuaranteedSpawns(pool, smMetadata)]);
			} else {
				var arr = guaranteedSpawns.get(pool.name);
				arr.push(makeGuaranteedSpawns(pool, smMetadata));
				guaranteedSpawns.set(pool.name, arr);
			}
		}

		while(rooms.length < smMetadata.maxRooms - smMetadata.startingRoom){
			var thaRoom = generateSingularRoom(i, smMetadata, guaranteedSpawns);
			rooms.push(thaRoom);
			i++;
		}
	}

	function generateSingularRoom(i:Int, smMetadata:StoryModeMetadata, ?guaranteedSpawns:Map<String, Array<Map<String, Array<Dynamic>>>>, ?canSpawnEntities:Bool = true){
		if(debug) trace("===== MAKING NEW ROOM "+i+" =====");
		var map:Map<String, Dynamic> = [];

		var firstToCreate = FlxG.random.int((i + smMetadata.intervals[0]), (i + smMetadata.intervals[1]));
		var secondToCreate = FlxG.random.int((i + smMetadata.intervals[0]), (i + smMetadata.intervals[1]));

		while (secondToCreate == firstToCreate){
			secondToCreate = FlxG.random.int((i + smMetadata.intervals[0]), (i + smMetadata.intervals[1]));
		}

		var door = i;

		if(debug) trace("Creating boss states");
		var roomData:Null<RoomData> = null;
		var specialThing:Null<String> = null;
		var isAttractedRoom:Bool = false;
		for(specificDoor in smMetadata.specificDoors){
			// If current door is the specific door
			if(door == specificDoor.spawnsAt) {
				specialThing = specificDoor.name;
				firstToCreate = secondToCreate = specificDoor.leavesAt;
				break;
			}

			if(specificDoor.attracts){
				// If current door is within interval
				// convert all doors within intervals to point to specific
				if(
					door >= specificDoor.attractionInterval[0] &&
					door <= specificDoor.attractionInterval[1]
				){
					isAttractedRoom = true;
					firstToCreate = secondToCreate = specificDoor.spawnsAt;
					var availableTypes = [for (x in smMetadata.roomTypes) if(door >= x.spawnInterval[0] && door <= x.spawnInterval[1] && x.preBossViable) x];
					if(availableTypes.length <= 0){
						availableTypes = [for (x in smMetadata.roomTypes) if(door >= x.spawnInterval[0] && door <= x.spawnInterval[1]) x];
						roomData = FlxG.random.getObject(availableTypes, [for (x in availableTypes) x.weight/1]);
					} else {
						roomData = FlxG.random.getObject(availableTypes, [for (x in availableTypes) x.weight/1]);
					}
					break;
				}
			} 
		}
		
		if(specialThing != null && specialThing == "shop"){
			specialThing = DoorsUtil.generateWhichShop();
		}

		if(debug) trace("Choosing the room type");
		if(specialThing == null && roomData == null) {
			var availableTypes = [for (x in smMetadata.roomTypes) if(door >= x.spawnInterval[0] && door <= x.spawnInterval[1]) x];
			roomData = FlxG.random.getObject(availableTypes, [for (x in availableTypes) x.weight/1]);
		}

		if(specialThing == null){
			switch(roomData.name){
				case "Long":
					//Generate 2 "Normal" rooms to go into roomPostfixes
					var normalRoomsArray = [];
					for(k in 0...2){
						var proposedRoom:StoryRoom = generateSingularRoom(i, smMetadata, guaranteedSpawns, false);
						while(proposedRoom.room.roomType != "Normal"){
							proposedRoom = generateSingularRoom(i, smMetadata, guaranteedSpawns, false);
						}
						var entityNamesInProposed = [for (x in proposedRoom.entitiesInRoom) x.name];
						if(entityNamesInProposed.contains("dupe")) {	// Bandaid Fix for a bug where sub-rooms in long rooms could generate dupe 
							proposedRoom.entitiesInRoom.remove({
								name: "dupe",
								className: "Dupe"
							});
						}
						normalRoomsArray.push(proposedRoom);
					}
	
					map.set("roomPostfixes", normalRoomsArray);
	
				default:
					//nothing
			}
		}
		

		if(debug) trace("Choosing Puzzles & Entities");
		if(specialThing == null) {
			var allSpawns:Array<{ name:String, info:Dynamic }> = [];
			for (spawnName in guaranteedSpawns.keys()) {
				for (multiSpawnInfo in guaranteedSpawns.get(spawnName)) {
					for (individualSpawnName in multiSpawnInfo.keys()) {
						for (individualSpawnInfo in multiSpawnInfo.get(individualSpawnName)) {
							allSpawns.push({
								name: individualSpawnName,
								info: individualSpawnInfo
							});
						}
					}
				}
			}


			for (spawn in allSpawns) {
				switch(spawn.info.type) {
					case "room-replacement":
						if(spawn.info.door == door) {
							if(debug) {
								trace("On door " + spawn.info.door + ", we create a room-replacement of type : " + spawn.name);
							}
							specialThing = spawn.name;
							break;
						}
					case "entity":
						if(!canSpawnEntities || isAttractedRoom) break;

						var dataToPush:StoryRoom.EntityData = {name: "None", className: "None"};

						if(spawn.info.door == door) {
							dataToPush = {
								name: spawn.name,
								className: CoolUtil.capitalize(spawn.name)
							}

							if(dataToPush.name == "None" || !roomData.canSpawn.contains(dataToPush.name)) 
								continue;

							switch(spawn.name) {
								case "void":
									if(DoorsUtil.modifierActive(31)) break;
								case "shadow":
									if(DoorsUtil.modifierActive(28)) break;
							}

							if(debug) {
								trace("SPAWNING ENTITY " + dataToPush.name);
							}
							
							if(map.exists("entitiesInRoom")){
								var arr = map.get("entitiesInRoom");
								arr.push(dataToPush);
								map.set("entitiesInRoom", arr);
							} else {
								map.set("entitiesInRoom", [dataToPush]);
							}
						}
					default:
						continue;
				}
			}
		}

		if(specialThing != null && map.exists("entitiesInRoom") && !DoorsUtil.modifierActive(31)){
			map.set("entitiesInRoom", [{
				name: "void",
				className: "Void"
			}]);
		}

		if (map.exists("entitiesInRoom")) {
			var entities:Array<Dynamic> = cast map.get("entitiesInRoom");
			var hasAmbush = false;
			var hasRush = false;

			for (entity in entities) {
				if (entity.name == "ambush") {
					hasAmbush = true;
				} else if (entity.name == "rush") {
					hasRush = true;
				}
			}

			if (hasAmbush && hasRush) {
				entities = entities.filter(function(entity) {
					return entity.name != "rush";
				});
				map.set("entitiesInRoom", entities);
			}
		}

		var seekArray:Null<Array<NearSeekData>> = [];
		if(debug) trace("Creating seek shit");
		for(specificDoor in smMetadata.specificDoors){
			if(specialThing == null && specificDoor.modifiesDoors != null && (specificDoor.modifiesDoors.contains(door))){
				if(debug) trace('Doing shit on door ${door} because modifiersDoors was found.');
				for(data in (Reflect.field(roomData, specificDoor.modificationID):Array<Dynamic>)){
					if(debug) trace('Trying ${data}.');
					if(FlxG.random.bool(data.weight)) {
						seekArray.push(data);
						if(debug) trace('Added ${data} to seek Array');
					}
				}
			}
		}

		var darkChance:Float = 10;
		
		if(DoorsUtil.modifierActive(3)) darkChance = 3;
		if(DoorsUtil.modifierActive(5)) darkChance = 30;
		if(DoorsUtil.modifierActive(6)) darkChance = 100;

		var isDark = FlxG.random.bool(darkChance);
		var hasAWood:Bool = FlxG.random.bool(10);
		var whichWood:Int = FlxG.random.int();

		if(specialThing != null || !canSpawnEntities || !roomData.canSpawn.contains("screech") || isAttractedRoom){
			isDark = false;
			hasAWood = false;
		}
		
		if(map.exists("entitiesInRoom") && 
			([for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("dupe") || 
			[for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("rush") || 
			[for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("ambush")
			)
		){
			isDark = false;
			hasAWood = false;
		}

		if(isDark){
			hasAWood = false;

			var dataToPush = {
				name: "screech",
				className: "Screech"
			}

			if(map.exists("entitiesInRoom")){
				var arr = map.get("entitiesInRoom");
				arr.push(dataToPush);
				map.set("entitiesInRoom", arr);
			} else {
				map.set("entitiesInRoom", [dataToPush]);
			}
		}

		if(debug && map.exists("entitiesInRoom")) trace(map.get("entitiesInRoom"));


		if(specialThing == null){
			var dataPerSide:Map<String, Array<FurnitureData>> = [];
			var paintingDataPerSide:Map<String, Array<PaintingData>> = [];

			for(furnitureData in roomData.furniture){
				for(side in furnitureData.sides){
					if(dataPerSide.exists(side)){
						var arr = dataPerSide.get(side);
						arr.push(furnitureData);
						dataPerSide.set(side, arr);
					} else {
						dataPerSide.set(side, [furnitureData]);
					}
				}
			}

			for(paintingData in roomData.paintings){
				if(paintingDataPerSide.exists(paintingData.side)){
					var arr = paintingDataPerSide.get(paintingData.side);
					arr.push(paintingData);
					paintingDataPerSide.set(paintingData.side, arr);
				} else {
					paintingDataPerSide.set(paintingData.side, [paintingData]);
				}
			}

			FlxG.random.shuffle(roomData.furnitureSides);


			if(debug) trace("Choosing which furniture must be spawned, and adding it to the furniture array");
			for(side in roomData.furnitureSides) {
				var chosenFurniture = null;

				for(furData in dataPerSide.get(side)) {
					// if rush or ambush is here, spawn ONE closet guaranteed.

					var needToSpawnCloset = true;

					if(map.exists("furniture")){
						for (fur in (map.get("furniture"):Array<Dynamic>)) {
							if(fur.name.toLowerCase() == "closet") needToSpawnCloset = false;
						}
					}	

					if(!needToSpawnCloset || 
						!map.exists("entitiesInRoom") || 
						(![for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("rush") && 
						![for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("ambush"))
					)
						break;

					if(debug){
						trace("Trying to spawn closet on this door because [" + 
						([for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("rush") ? "Rush" :
						([for (x in (map.get("entitiesInRoom"):Array<Dynamic>)) x.name].contains("ambush")) ? "Ambush" : "Error!!!!!") + "] spawned.");
					
						trace("Here's the furniture data we have to work with on this side : " + furData);
					}
					
					if(furData.name.toLowerCase().contains("closet")){
						switch(roomData.name){
							case "Greenhouse":
								chosenFurniture = {name: "Closet", sides: ["BL", "BR", "FL", "FR"], weight: 20.0, canHavePainting: false};
							case "Long":
								chosenFurniture = {name: "closet", sides: ["SL", "SR"], weight: 40.0, canHavePainting: false};
							default:
								chosenFurniture = {name: "closet", sides: ["left", "right"], weight: 20.0, canHavePainting: false};
						}
						
						if(debug){
							trace("Spawned closet on side : " + side);
						}
						
						if(map.exists("furniture")){
							var arr = map.get("furniture");
							arr.push({
								name:chosenFurniture.name,
								sprite:null,
								side:side,
								specificAttributes:{
									hasJack: false,
									isOpened: false,
									jackSong: ""
								}
							});
							map.set("furniture", arr);
						} else {
							map.set("furniture", [{
								name:chosenFurniture.name,
								sprite:null,
								side:side,
								specificAttributes:{
									hasJack: false,
									isOpened: false,
									jackSong: "None"
								}
							}]);
						}
						break;
					}
				}

				if(map.exists("furniture")){
					var mustContinue = false;
					for (fur in (map.get("furniture"):Array<Dynamic>)) {
						if(fur.side == side) mustContinue = true;
					}
					if(mustContinue) continue;
				}

				//edge case where side exists but no furniture can spawn there.
				if(dataPerSide.exists(side)){
					if(debug) trace("Choosing the furniture on side "+side);
					var dataArr:Array<FurnitureData> = dataPerSide.get(side);
					var weightArr:Array<Float> = [for (x in dataArr) x.weight];

					chosenFurniture = FlxG.random.getObject(dataArr, weightArr);

					if(chosenFurniture.name != ""){
						var dataToPush = {
							name:chosenFurniture.name,
							sprite:null,
							side:side,
							specificAttributes:handleFurniture(chosenFurniture.name, smMetadata)
						}
						if(debug) trace("We have chosen furniture ["+chosenFurniture.name+"]");

						if(map.exists("furniture")){
							var arr = map.get("furniture");
							arr.push(dataToPush);
							map.set("furniture", arr);
						} else {
							map.set("furniture", [dataToPush]);
						}
					}
				}

				//edge case where side exists but no paintings/windows can spawn there.
				if(paintingDataPerSide.exists(side)){
					if(chosenFurniture != null && !chosenFurniture.canHavePainting) {
						if(!map.exists("paintings")){
							map.set("paintings", []);
						}
						continue;
					}
					
					if(debug) trace("Choosing if there is a window on side "+side);
					var chosenPainting:Null<PaintingData> = null;

					for(painting in paintingDataPerSide.get(side)){
						if(!painting.isWindow) continue;
						else {
							if(FlxG.random.bool(painting.chance)) chosenPainting = painting;
						}
					}

					if(chosenPainting == null) {
						if(debug) trace("There is no window, choosing painting on side "+side);
						for(painting in paintingDataPerSide.get(side)){
							if(painting.isWindow) continue;
							else {
								if(FlxG.random.bool(painting.chance)) chosenPainting = painting;
							}
						}
					}

					if(chosenPainting != null){
						var pattern = "";
						if(!chosenPainting.isWindow) pattern = FlxG.random.getObject(chosenPainting.patterns);

						var dataToPush = {
							side: side,
							data: chosenPainting,
							pattern: pattern
						};

						if(map.exists("paintings")){
							var arr = map.get("paintings");
							arr.push(dataToPush);
							map.set("paintings", arr);
						} else {
							map.set("paintings", [dataToPush]);
						}
					}
				}
			}

			if(!map.exists("furniture")){
				map.set("furniture", []);
			}
			
			if(!map.exists("paintings")){
				map.set("paintings", []);
			}

			if(!map.exists("entitiesInRoom") || !canSpawnEntities || isAttractedRoom){
				map.set("entitiesInRoom", []);
			}

			if(debug) trace("Generating hide");
			for(fur in (map.get("furniture"):Array<Dynamic>)) {
				if((fur.name:String).toLowerCase().contains("closet")) {
					var dataToPush = {
						name: "hide",
						className: "Hide"
					}

					if(map.exists("entitiesInRoom")){
						var arr = map.get("entitiesInRoom");
						arr.push(dataToPush);
						map.set("entitiesInRoom", arr);
					} else {
						map.set("entitiesInRoom", [dataToPush]);
					}
					break;
				}
			}

			if(debug) trace("Generating dupe");
			for(ent in (map.get("entitiesInRoom"):Array<Dynamic>)){
				if(ent.name == "dupe" && roomData.canSpawn.contains("dupe")) {
					if(FlxG.random.int()%2 == 0)
						firstToCreate = FlxG.random.int((i - smMetadata.intervals[0]), (i - smMetadata.intervals[1]));
					else 
						secondToCreate = FlxG.random.int((i - smMetadata.intervals[0]), (i - smMetadata.intervals[1]));
					if(debug) trace('Should have dupe : D1 = ${firstToCreate} / D2 = ${secondToCreate}');
					break;
				}
			}

		} else {
			darkChance = 0;
		}

		if(debug) trace("Choosing songs");
		var nextSong1:String = isAttractedRoom ? "None" : choosingNextSong(specialThing, firstToCreate, smMetadata);
		var nextSong2:String = isAttractedRoom ? "None" : choosingNextSong(specialThing, secondToCreate, smMetadata);

		if(debug) trace("Creating leftDoor");
		map.set("leftDoor", {
			doorNumber:firstToCreate,
			isLocked:(hasAWood && whichWood%2 == 0 && specialThing == null && (roomData == null ? "Normal" : roomData.name) == "Normal"),
			song:nextSong1
		});
		if(debug) trace("Creating rightDoor");
		map.set("rightDoor", {
			doorNumber:secondToCreate,
			isLocked:(hasAWood && whichWood%2 == 1 && specialThing == null && (roomData == null ? "Normal" : roomData.name) == "Normal"),
			song:nextSong2
		});

		if(debug) {
			trace("CONDITIONS FOR LOCKED DOORS : ");
			trace("hasAWood : " + (hasAWood) );
			trace("whichWood : " + (whichWood) );
			trace("specialThing == null : " + (specialThing) );
			trace("(roomData == null ? \"Normal\" : roomData.name) == \"Normal\" : " + (roomData == null ? "Normal" : roomData.name));

			trace("LEFT IS LOCKED :" + map.get("leftDoor").isLocked);
			trace("RIGHT IS LOCKED :" + map.get("rightDoor").isLocked);
		}
		
		if(debug) trace("Creating Room");
		map.set("room", {
			bossType: specialThing == null ? "None" : specialThing,
			roomType: roomData == null ? "Normal" : roomData.name,
			roomColor: roomData == null ? "" : FlxG.random.getObject(roomData.colors),
			isDark: isDark,
			seekData: seekArray
		});

		if(debug) trace("Handing music");
		var musicOverride:Null<String> = null;
		if(specialThing != null){
			for(specificDoor in smMetadata.specificDoors){
				if(specificDoor.name != specialThing) continue;

				if(specificDoor.musicOverride != null) 
					musicOverride = specificDoor.musicOverride;

				break;
			}

			for(puzzlePool in smMetadata.puzzlePool){
				if(puzzlePool.name != specialThing) continue;

				if(puzzlePool.musicOverride != null) 
					musicOverride = puzzlePool.musicOverride;

				break;
			}
		}

		if(roomData != null && roomData.musicOverride != null){
			musicOverride = roomData.musicOverride;
		}

		var musicData:Null<MusicData> = null;
		if(musicOverride == null){
			for(music in smMetadata.musicData){
				if(music.doorInterval[0] <= i && music.doorInterval[1] >= i){
					musicData = music;
				}
			}
		} else {
			musicData = {
				name: musicOverride,
				bpm: 93,
				doorInterval: [-2, -1],
				variants: []
			}
		}

		map.set("musicData", musicData);

		if(debug) trace("===== FINISHED ROOM "+i+" =====");
		return new StoryRoom(map);
	}

	public function save(){
		var serializer = new Serializer();
		serializer.serialize(this);
		FlxG.save.data.curRun = serializer.toString();
		FlxG.save.flush();
	}

	public static function load(){
		if(DoorsUtil.curRun != null) return;
		if(FlxG.save.data.curRun != null){
			var unserializer = new Unserializer(FlxG.save.data.curRun);
			var run:Null<DoorsRun> = null;
			try{
				run = unserializer.unserialize();
			} catch(e){
				trace(e);
				run = new DoorsRun();
			}
			if(run == null || run.rooms == null || run.curInventory == null){
				run = new DoorsRun();
			}
			DoorsUtil.curRun = run;
		} else {
			var run:DoorsRun = new DoorsRun();
			DoorsUtil.curRun = run;
		}
	}

	public function reset(){
		var run:DoorsRun = new DoorsRun();
		DoorsUtil.curRun = run;
	}

	public function toString(){
		var theString = "";
		for(i in 0...rooms.length){
			theString += 'Room ${initialDoor + i} : ${rooms[i]} \n';
		}
		return theString;
	}

	public function linearFunc(baseline:Float, addsWith:Dynamic, addBy:Float){
		return FlxG.random.bool(baseline + addsWith * addBy);
	}

	public function makeGuaranteedSpawns(pool:Puzzle, smMetadata:StoryModeMetadata) {
		if(debug) {
			trace("Trying to make the puzzle room spawn pools");
		}
		var guaranteedSpawns:Map<String, Array<Dynamic>> = [];

		if(pool.spawnType == "intervalFunc"){
			for(thing in pool.spawnArgs){
				var allPossibleSpawns = [for(x in thing.interval[0]...thing.interval[1]) x];
				if(debug) {
					trace("All Possible Spawn : " + allPossibleSpawns);
				}
				for(_ in 0...thing.minimumPerInterval){
					if(allPossibleSpawns.length <= 0) continue;
	
					var chosenDoor = FlxG.random.getObject(allPossibleSpawns);
	
					if(!guaranteedSpawns.exists(pool.name)){
						guaranteedSpawns.set(pool.name, [{
							type: pool.type,
							door: chosenDoor,
						}]);
					} else {
						var arr = guaranteedSpawns.get(pool.name);
						arr.push({
							type: pool.type,
							door: chosenDoor,
						});
						guaranteedSpawns.set(pool.name, arr);
					}
	
					allPossibleSpawns.remove(chosenDoor - 1);
					allPossibleSpawns.remove(chosenDoor);
					allPossibleSpawns.remove(chosenDoor + 1);
	
					if(debug) {
						trace("Chose door : " + chosenDoor);
						trace("Puzzle room spawn info " + pool.name + " was created : " + guaranteedSpawns.get(pool.name));
					}
				}
	
				var isDoorStillAllowed = [for(_ in allPossibleSpawns) true];
				for(i=>potentialDoor in allPossibleSpawns){
					if(FlxG.random.bool(thing.additionalSpawnChance * 100) && isDoorStillAllowed[i]){
						isDoorStillAllowed[i] = false;
						if(i != isDoorStillAllowed.length - 1) isDoorStillAllowed[i + 1] = false;
	
						if(!guaranteedSpawns.exists(pool.name)){
							guaranteedSpawns.set(pool.name, [{
								type: pool.type,
								door: potentialDoor,
							}]);
						} else {
							var arr = guaranteedSpawns.get(pool.name);
							arr.push({
								type: pool.type,
								door: potentialDoor,
							});
							guaranteedSpawns.set(pool.name, arr);
						}
	
						if(debug) {
							trace("Chose door : " + potentialDoor);
							trace("Puzzle room spawn info was created : " + guaranteedSpawns.get(pool.name));
						}
					}
				}
			}
		} else if (pool.spawnType == "guaranteedFunc") {
			for(door in 0...smMetadata.maxRooms - smMetadata.startingRoom){
				var b = guaranteedFunc([for(x in pool.spawnArgs) x], door);

				if(b) {
					if(!guaranteedSpawns.exists(pool.name)){
						guaranteedSpawns.set(pool.name, [{
							type: pool.type,
							door: door,
						}]);
					} else {
						var arr = guaranteedSpawns.get(pool.name);
						arr.push({
							type: pool.type,
							door: door,
						});
						guaranteedSpawns.set(pool.name, arr);
					}
				}
			}
		} else if (pool.spawnType == "linearFunc") {
			for(door in 0...smMetadata.maxRooms - smMetadata.startingRoom){
				var b:Bool = false;
				switch(pool.name) {
					case "shadow":	// double shadow spawn rate by running function twice if shadow_more modifier is here
						if(DoorsUtil.modifierActive(30)) {
							b = linearFunc(pool.spawnArgs[0], switch(pool.spawnArgs[1]) {
									case "door": door;
									default: 0;
								}, pool.spawnArgs[2]);
						} 
				}

				if(!b) b = linearFunc(pool.spawnArgs[0], switch(pool.spawnArgs[1]) {
						case "door": door;
						default: 0;
					}, pool.spawnArgs[2]);

				if(b) {
					if(!guaranteedSpawns.exists(pool.name)){
						guaranteedSpawns.set(pool.name, [{
							type: pool.type,
							door: door,
						}]);
					} else {
						var arr = guaranteedSpawns.get(pool.name);
						arr.push({
							type: pool.type,
							door: door,
						});
						guaranteedSpawns.set(pool.name, arr);
					}
				}
			}
		}

		return guaranteedSpawns;
	}

	public function intervalFunc(data:Array<IntervalSpawningInfo>, door:Int){
		for(thing in data){
			if(FlxG.random.bool(thing.additionalSpawnChance * 100) && 
				door >= thing.interval[0] && door <= thing.interval[1]){
				return true;
			}
		}
		return false;
	}

	public function guaranteedFunc(intervals:Array<Array<Int>>, door){
		for(interval in intervals){
			if(door >= interval[0] && door <= interval[1]){
				return true;
			}
		}
		return false;
	}
}