package;

import haxe.io.Bytes;
import openfl.display.BitmapData;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import haxe.crypto.Md5;
import flixel.math.FlxRect;
import flixel.util.FlxSave;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.system.FlxSound;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
#if GLASSHAT
import glasshatsec.Glasshat.GlasshatData;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard',
		'Hell'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];
	public static var translatedDifficulties:Array<String> = [];

	public static inline function quantize(Value:Float, Quant:Float) {
        return Math.fround(Value * Quant) / Quant;
    }

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	public static function getDisplayDiffString(?diffInt:Int = -1):String{
		translatedDifficulties = [
			Lang.getText("ez", "generalshit"),
			Lang.getText("normal", "generalshit"),
			Lang.getText("hard", "generalshit"),
			Lang.getText("hell", "generalshit")
		];
		if(diffInt != -1) return translatedDifficulties[diffInt];
		else return translatedDifficulties[PlayState.storyDifficulty];
	}
	
	inline public static function getSavePath(folder:String = 'leetram'):String {
		@:privateAccess
		return FlxSave.validate(FlxG.stage.application.meta.get('company')) + '/' + FlxSave.validate("doorsmod");
	}

	public static function calculateCurrentChartHash(){
		#if GLASSHAT
		var songPath = Paths.json('${PlayState.SONG.song}/${Highscore.formatSong(PlayState.SONG.song, PlayState.storyDifficulty).replace("-hell-hell", "-hell")}', "preload");
		if(songPath.replace(".json", "").endsWith("-")) {
			songPath = songPath.replace("-.json", ".json");
		}
		var content = try File.getContent(songPath) catch(e:Dynamic) {
			trace("failed to make content");
			"failed";
		};
		var encoded = Md5.encode(content + GlasshatData.chartPepper);
		#else
		var songPath = Paths.json('${PlayState.SONG.song}/${Highscore.formatSong(PlayState.SONG.song, PlayState.storyDifficulty).replace("-hell-hell", "-hell")}', "preload");
		if(songPath.replace(".json", "").endsWith("-")) {
			songPath = songPath.replace("-.json", ".json");
		}
		var fileContent = File.getContent('${songPath}');
		var encoded = Md5.encode("no glasshat nuh uh");
		#end
		return encoded;
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String;
		if(difficulties.length > 1) fileSuffix = difficulties[num].toLowerCase();
		else fileSuffix = defaultDifficulties[num].toLowerCase();

		if(fileSuffix.toLowerCase() != defaultDifficulty.toLowerCase())
		{
			fileSuffix = '-' + fileSuffix.toLowerCase();
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	/**
	 * Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
	 * @param size Size to convert to string
	 * @return String Result string representation
	 */
	public static function getSizeString(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	inline public static function calcRectByGlobal(spr:FlxSprite, rect:FlxRect):FlxRect
		return FlxRect.get(rect.x - spr.x, rect.y - spr.y, rect.width, rect.height);

	inline public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function getDisplaySong(songName:String):String{
		var displaySong:String = "";
		var wordArray:Array<String> = [];
		wordArray = songName.split("-");

		for (word in wordArray){
			displaySong += word.substr(0, 1).toUpperCase();
			displaySong += word.substr(1);
			displaySong += " ";
		}
		displaySong = displaySong.trim();

		return displaySong;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	
	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
		{
			// thank you foreverEngine
			var libraryArray:Array<String> = [];
			var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');
	
			for (folder in unfilteredLibrary)
			{
				if (!folder.contains('.'))
					libraryArray.push(folder);
			}
			trace(libraryArray);
	
			return libraryArray;
		}

		
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	} 

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
	 * Modulo that works for negative numbers
	 */
	public inline static function mod(n:Int, m:Int) {
		return ((n % m) + m) % m;
	}

	public static function makeGradient(width:Int, height:Int, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90, interpolate:Bool = true) {
		var gradWidth = width;
		var gradHeight = height;
		var gradXScale = 1;
		var gradYScale = 1;

		var modRotation = mod(rotation, 360);

		if(modRotation == 90 || modRotation == 270) {
			gradXScale = width;
			gradWidth = 1;
		}

		if(modRotation == 0 || modRotation == 180) {
			gradYScale = height;
			gradHeight = 1;
		}

		var gradient = FlxGradient.createGradientFlxSprite(gradWidth, gradHeight, colors, chunkSize, rotation, interpolate);
		gradient.scale.set(gradXScale, gradYScale);
		gradient.updateHitbox();
		return gradient;
	}

	public static function invertedAlphaMaskFlxSprite(sprite:FlxSprite, mask:FlxSprite, output:FlxSprite, ?alphaOffset:Int = 255):FlxSprite
		{
			// Solution based on the discussion here:
			// https://groups.google.com/forum/#!topic/haxeflixel/fq7_Y6X2ngY
		
			// NOTE: The code below is the same as FlxSpriteUtil.alphaMaskFlxSprite(),
			// except it has an EXTRA section below.
		
			sprite.drawFrame();
			var data:BitmapData = sprite.pixels.clone();
			data.copyChannel(mask.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		
			// EXTRA:
			// this code applies a -1 multiplier to the alpha channel,
			// turning the opaque circle into a transparent circle.
			data.colorTransform(new Rectangle(0, 0, sprite.width, sprite.height), new ColorTransform(0,0,0,-1,0,0,0,alphaOffset));
			// end EXTRA
		
			output.pixels = data;
			return output;
		}
}
