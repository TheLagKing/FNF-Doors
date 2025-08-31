package options.substates;

import objects.ui.DoorsOption.DoorsOptionType;
import objects.ui.DoorsOption.CommonDoorsOption;
import flixel.text.FlxTextNew as FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import shaders.ColorblindFilters;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new(?firstOpen:Bool = false)
	{
		internalTitle = "graphics";
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		var option:CommonDoorsOption = {
			name: "lowquality",
			description: "lowquality",
			variable: "lowQuality",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "antialiasing",
			description: "antialiasing",
			variable: "antialiasing",
			type: DoorsOptionType.BOOL,
			onChange: onChangeAntiAliasing
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "shaders",
			description: "shaders",
			variable: "shaders",
			type: DoorsOptionType.BOOL
		};
		addOption(option);
		
		var option:CommonDoorsOption = {
			name: "colorblind",
			description: "colorblind",
			variable: "colorblindMode",
			type: DoorsOptionType.STRING,
			stringOptions: ['none', 'deuteranopia', 'protanopia', 'tritanopia'],
			onChange: ColorblindFilters.applyFiltersOnGame
		};
        addOption(option);
		
		var option:CommonDoorsOption = {
			name: "filmgrain",
			description: "filmgrain",
			variable: "filmGrain",
			type: DoorsOptionType.BOOL
		};
		addOption(option);
		
		var option:CommonDoorsOption = {
			name: "gpucache",
			description: "gpucache",
			variable: "cacheOnGPU",
			type: DoorsOptionType.BOOL
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "framerate",
			description: "framerate",
			variable: "framerate",
			type: DoorsOptionType.INT,
			minValue: 60,
			maxValue: 420,
			displayFormat: '%v FPS',
			onChange: onChangeFramerate,
		};
		addOption(option);

		super(firstOpen);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}
}