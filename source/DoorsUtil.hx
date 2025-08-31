package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import haxe.Unserializer;
import haxe.Serializer;
import flixel.FlxG;
import backend.metadata.ItemsMetadata;
import backend.metadata.StoryModeMetadata;

typedef ShopData = {
    var items:Array<String>;
    var boughtItems:Array<Bool>;
}

class DoorsUtil {
	//GLOBAL VARIABLES
	public static var knobs:Int = 0;

	public static var isNewRun:Bool = true;
	
	public static var isDead:Bool = false;
	public static var causeOfDeath:String = "SONG";

	public static var curRun:DoorsRun;

	//shop data
	public static var generateNewShop(get,never):Bool;
	static function get_generateNewShop():Bool{
		return FlxG.save.data.jeffShopData == null || FlxG.save.data.jeffShopData == "";
	}

	public static var jeffShopData:ShopData;

	public static var isGreenhouse(get,never):Bool;
	public static function get_isGreenhouse(){
		return DoorsUtil.curRun != null ? DoorsUtil.curRun.curDoor >= 90 : false;
	}

	//static things
	public static final RUSH_SONGS:Array<String> = ['demise', 'rushing', 'flicker', 'coming-through'];
	public static final SCREECH_SONGS:Array<String> = ['annoyance', 'darkness', 'shitstain', 'stalker'];
	public static final EYES_SONGS:Array<String> = ['stare', 'always-watching', 'watch-out', 'eye-spy'];
	public static final AMBUSH_SONGS:Array<String> = ['recursion', 'rebound', 'ambuscade', 'ethereal'];
	public static final TIMOTHY_SONGS:Array<String> = ['drawer', 'itzy-bitzy', 'jumpscare', 'kumo'];
	public static final HALT_SONGS:Array<String> = ['halt', 'onward'];
	public static final JACK_SONGS:Array<String> = ['invader'];

	public static var maxHealth:Int = 2;

	static public function modifierActive(ID:Int)
	{
		var b:Bool = false;

		b = ModifierManager.modifierActive(ID, !PlayState.isStoryMode);

		if(b && PlayState.instance != null && !PlayState.instance.activeModifiers.contains(ID)){
			PlayState.instance.activeModifiers.push(ID);
		}
		return b;
	}

	public static function reloadMaxHealth() {
		if(modifierActive(43)) maxHealth = 1;
		else if(modifierActive(44)) maxHealth = 4;
		else maxHealth = 2; 
	}

    public static function saveShopData(){
		var serialized:Array<Dynamic> = [];
		serialized = [jeffShopData.items, jeffShopData.boughtItems];
        FlxG.save.data.jeffShopData = serialized;
    }

    public static function loadShopData(){
		if(FlxG.save.data.jeffShopData != "") {
			var deserialized:Array<Dynamic> = FlxG.save.data.jeffShopData;
			jeffShopData = {items: deserialized[0], boughtItems: deserialized[1]};
		}
		FlxG.save.data.jeffShopData = null;
    }

	public inline static function generateWhichShop(){
		#if debug
			var result = FlxG.random.bool(90) ? "glitched" : "jeff";
			trace("Chose : " + result);
			return result;
		#else
			return FlxG.random.bool(5) ? "glitched" : "jeff";
		#end
	}

	public static function generateShopData(numberOfItems:Int, rarityWeights:Map<ItemRarities, Int>, spawnableItems:Map<ItemRarities, Array<String>>,
		?guaranteedItems:Map<Int, String>){
		var numberOfRandomItems:Int = numberOfItems;
		var itemArray:Array<String> = [for (x in 0...numberOfRandomItems) null];

		for(i in 0...numberOfRandomItems){
			var itemWeights:Array<Float> = [];
			var rarities:Array<ItemRarities> = [];

			for(rarity in rarityWeights.keys()){
				rarities.push(rarity);
				itemWeights.push(rarityWeights.get(rarity));
			}
			var chosenRarity:ItemRarities = FlxG.random.getObject(rarities, itemWeights);

			itemArray[i] = FlxG.random.getObject(spawnableItems.get(chosenRarity));
			var newArr = spawnableItems.get(chosenRarity);
			newArr.remove(itemArray[itemArray.length-1]);
			spawnableItems[chosenRarity] = newArr;
		}
		
		trace(guaranteedItems);
		if(guaranteedItems != null){
			for(guaranteedItem in guaranteedItems.keys()){
				while(guaranteedItem > itemArray.length){
					itemArray.push("");
				}
				itemArray[guaranteedItem] = guaranteedItems.get(guaranteedItem);
			}
		}

		return {
			items: itemArray,
			boughtItems: [for (x in 0...numberOfRandomItems) false]
		};
	}

	public static function loadAllData()
	{
		if(FlxG.save.data.knobs != null) {
			knobs = FlxG.save.data.knobs;
		}
		if(FlxG.save.data.isDead != null) {
			isDead = FlxG.save.data.isDead;
		}
	}

	public static function saveAllData(){
		FlxG.save.data.isNewRun = isNewRun;
        FlxG.save.data.isDead = isDead;
		FlxG.save.data.knobs = knobs;

		FlxG.save.flush();
	}
	/**
	 * Adds knobs to the player's inventory based on the results of the run.
	 * Knobs are a currency used to purchase songs.
	 * The amount of knobs added is calculated based on the run's rating, difficulty, misses, revives left, and money earned.
	 * The resulting amount is then saved to the player's save data.
	 */

	public static function endRun(){
		if(FlxG.save.data.knobs != null){
			knobs = FlxG.save.data.knobs;
		} else {
			knobs = 0;
		}

		var runIntDiff:Int = 0;
		switch(curRun.runDiff){
			case 'Easy':
				runIntDiff = 0;
			case 'Normal':
				runIntDiff = 1;
			case 'Hard':
				runIntDiff = 3;
			case 'Hell':
				runIntDiff = 6;
		}

		knobs += Math.floor(200 + (curRun.runMoney / 40) * curRun.runRating 
							- ((curRun.runMisses * 2) > 50 ? 50 : curRun.runMisses*2)
							+ (30 * curRun.revivesLeft * runIntDiff) + (100 * (runIntDiff / 2)));


		if(FlxG.save.data.bestSMScore == null || curRun.runScore > FlxG.save.data.bestSMScore) FlxG.save.data.bestSMScore = curRun.runScore;
		if(FlxG.save.data.bestSMMiss == null || curRun.runMisses > FlxG.save.data.bestSMMiss) FlxG.save.data.bestSMMiss = curRun.runMisses;
		if(FlxG.save.data.bestSMAcc == null || curRun.runRating > FlxG.save.data.bestSMAcc) FlxG.save.data.bestSMAcc = curRun.runRating;

		FlxG.save.data.knobs = knobs;
		FlxG.save.flush();

		resetRun();
	}

	public static function saveFreeplayData(){
		FlxG.save.data.knobs = knobs;

		FlxG.save.flush();
	}

	public static function loadFreeplayData(){
		if(FlxG.save.data.knobs != null) {
			knobs = FlxG.save.data.knobs;
		}
	}

	public static function resetRun(){
		FlxG.save.data.jeffShopData = "";

		FlxG.save.flush();
		DoorsUtil.curRun.reset();
		ModifierManager.onReset();
		DoorsUtil.loadStoryData();
		DoorsUtil.loadRunData();
	}

	public static function saveStoryData() {
		curRun.save();
        FlxG.save.data.isDead = isDead;

        FlxG.save.flush();
	}

	public static function saveRunData(){
		curRun.save();

		FlxG.save.flush();
	}

	public static function loadRunData(){
		DoorsRun.load();
	}
	
	public static var wantedDiff = "normal";
	public static function setupRunData(?diff = 'Normal'){
		//curRun.makeNewRun();
		wantedDiff = diff;

		saveRunData();
	}

	public static function recalculateKnobModifier(){
		var calculatedModifier:Float = 1.0;
		var hasInvalidatingModifier:Bool = false;
		for(modifier in curRun.runModifiers){
			calculatedModifier += ((modifier.knobAddition) - 1);
		}

		for(modifier in curRun.runModifiers){
			calculatedModifier *= modifier.knobMultiplier;
		}

		curRun.runKnobModifier = calculatedModifier;
	}

	public static function recalculateScoreModifier(){
		var calculatedModifier:Float = 1.0;
		var hasInvalidatingModifier:Bool = false;
		for(modifier in ModifierManager.freeplayChosenModifiers){
			calculatedModifier += (modifier.knobAddition - 1);
			if(modifier.ID == 54 || modifier.ID == 55){
				hasInvalidatingModifier = true;
			}
			trace(calculatedModifier);
		}

		for(modifier in ModifierManager.freeplayChosenModifiers){
			calculatedModifier *= modifier.knobMultiplier;
			trace(calculatedModifier);
		}

		trace(calculatedModifier);
		ModifierManager.freeplayScoreMod = calculatedModifier;
	}

	public static function recalculateRunScores(newRating:Float, newScore:Int, newMisses:Int, newEncounter:String){
		loadRunData();

		curRun.runRating = FlxMath.bound(curRun.runRating, 0, 1);

		if (curRun.runEncounters == null){
			curRun.runEncounters = [];
		}
		curRun.runEncounters.push(newEncounter);
		curRun.songsPlayed.push(newEncounter.toLowerCase());
		var finalRating = ((newRating + (curRun.runRating * (curRun.runEncounters.length - 1))) / curRun.runEncounters.length);
		var finalScore = curRun.runScore + newScore;
		var finalMisses = curRun.runMisses + newMisses;

		var finalHealth = PlayState.instance.health;

		curRun.latestHealth = finalHealth;
        curRun.runMisses = finalMisses;
        curRun.runScore = finalScore;
        curRun.runRating = finalRating;

		FlxG.save.flush();
		loadRunData();
	}

	public static function addStoryHealth(amt:Float, ?flush:Bool = true){
		if(curRun.latestHealth <= maxHealth){
			FlxG.save.data.latestHealth += amt;
			curRun.latestHealth += amt;
			if(flush) return FlxG.save.flush();
			else return true;
		}
		return false;
	}

	public static function spendMoney(cost:Int){
		// Returns a bool :
		// True if you had enough money and therefore spent the money
		// False if you couldn't spend the money and runMoney went into the negatives
		loadRunData();

		var b:Bool = (curRun.runMoney - cost) >= 0;

		if (b){
			FlxG.save.data.runMoney = curRun.runMoney - cost;
			curRun.runMoney = curRun.runMoney - cost;
			
			FlxG.save.flush();
		}
		return b;
	}

	public static function addKnobs(amt:Int, modifier:Float){
		FlxG.save.data.knobs = Math.round(knobs + (amt * modifier));
		knobs = Math.round(knobs + (amt * modifier));
		
		FlxG.save.flush();
	}
    
	public static function loadStoryData() {
		DoorsRun.load();
		if(FlxG.save.data.isDead != null){
			isDead = FlxG.save.data.isDead;
		}
    }

	public static function handleMusicVariations(musicData:MusicData){
		if(musicData.variants == null || musicData.variants.length == 0) return musicData.name;

		var variantsMet:Array<Dynamic> = [musicData];
		for(variant in musicData.variants){
			var conditionsMet:Array<Bool> = [];
			for(condition in variant.conditions){
				for(conditionData in variant.conditionsData){
					if(conditionData.condition == condition) {
						conditionsMet.push(isConditionMet(condition, conditionData));
					}
				}
			}

			if(!conditionsMet.contains(false)){
				variantsMet.push(variant);
			}
		}

		if(variantsMet.length == 1) return variantsMet[0].name ?? "storymode/start";

		var maxPriority:Int = -999;
		var chosenVariant = "";
		for(variant in variantsMet){
			if(!Reflect.hasField(variant, "variantPriority") || variant.variantPriority > maxPriority){
				chosenVariant = variant.name;
				if(Reflect.hasField(variant, "variantPriority")) maxPriority = variant.variantPriority;
			}
		}

		return chosenVariant;
	}

	public static function isConditionMet(condition:String, conditionData:Dynamic){
		switch(condition){
			case "ENTITY_ENCOUNTERED":
				if(Reflect.hasField(conditionData, "entityAmt")){
					if(DoorsUtil.curRun.runEncounters.length >= conditionData.entityAmt) return true;
				}
		}
		return false;
	}

	public static function recalculateSongEntitiesEncountered(){
		if(curRun.entitiesEncountered == null){
			curRun.entitiesEncountered = [];
		}
		var _entitiesEncountered:Map<String, Int> = [];
		var _alreadyCheckedSongs:Array<String> = [];

		for(pool in curRun.songPools){
			for(entity in pool.entities){
				for(song in curRun.songsPlayed){
					if(entity.songs.length == 0) continue;
					if(!entity.songs.contains(song)) continue;
					if(_alreadyCheckedSongs.contains(song)) continue;
					
					_alreadyCheckedSongs.push(song);
					if(_entitiesEncountered.exists(entity.name)) {
						_entitiesEncountered.set(entity.name, _entitiesEncountered.get(entity.name) + 1);
					} else {
						_entitiesEncountered.set(entity.name, 1);
					}
				}
			}
		}

		for(entity in _entitiesEncountered.keys()){
			if(curRun.entitiesEncountered.exists(entity)){
				if(curRun.entitiesToEncounter.filter(function(data) {
					return data.entityName == entity && data.encounterType == "SONG";
				}).length > 0){
					curRun.entitiesEncountered.set(entity, _entitiesEncountered.get(entity));
				}
			}
		}

		curRun.save();

		return curRun.entitiesEncountered;
	}

	public static function addMechanicEntityToEncountered(mechanicEntity:String){
		if(curRun.entitiesEncountered == null){
			curRun.entitiesEncountered = [];
		}

		for(entity in curRun.entitiesEncountered.keys()){
			if(curRun.entitiesToEncounter.filter(function(data) {
				return 	data.entityName == entity && 
						data.entityName == mechanicEntity && 
						data.encounterType == "MECHANIC";
			}).length > 0){
				curRun.entitiesEncountered.set(entity, curRun.entitiesEncountered.get(entity) + 1);
			}
		}

		curRun.save();
		return curRun.entitiesEncountered;
	}

	public static function calculateRunRank(){
		var acc = curRun.runRating;
		var misses = curRun.runMisses;

		if(acc >= 0.995 && misses == 0) {
			return RunRanking.P;
		} else if(acc >= 0.95 && misses <= 30){
			return RunRanking.S;
		} else if (acc >= 0.90 && misses <= 100) {
			return RunRanking.A;
		} else if (acc >= 0.85 && misses <= 250) {
			return RunRanking.B;
		} else if (acc >= 0.80 && misses <= 500) {
			return RunRanking.C;
		} else if (acc >= 0.70) {
			return RunRanking.D;
		} 
		return RunRanking.F;
	}
}