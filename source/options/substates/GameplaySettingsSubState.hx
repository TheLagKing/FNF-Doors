package options.substates;

import objects.ui.DoorsOption.DoorsOptionType;
import objects.ui.DoorsOption.CommonDoorsOption;
import flixel.FlxG;

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new(?firstOpen:Bool = false)
	{
		//path suffix
		internalTitle = "gameplay";
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:CommonDoorsOption = {
			name: "controller",
			description: "controller",
			variable: "controllerMode",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "downscroll",
			description: "downscroll",
			variable: "downScroll",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption  = {
			name: "midscroll",
			description: "midscroll",
			variable: "middleScroll",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "oppnotes",
			description: "oppnotes",
			variable: "opponentStrums",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "ghosttap",
			description: "ghosttap",
			variable: "ghostTapping",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "disablereset",
			description: "disablereset",
			variable: "noReset",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		//strumlineBackgroundOpacity
		var option:CommonDoorsOption = {
			name: "strumlineBackgroundOpacity",
			description: "strumlineBackgroundOpacity",
			variable: "strumlineBackgroundOpacity",
			type: DoorsOptionType.PERCENT,
			scrollSpeed: 1.6,
			minValue: 0.0,
			maxValue: 1,
			changeValue: 0.1,
			decimals: 1,
			onChange: onChangeHitsoundVolume
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "hitsound",
			description: "hitsound",
			variable: "hitsoundVolume",
			type: DoorsOptionType.PERCENT,
			scrollSpeed: 1.6,
			minValue: 0.0,
			maxValue: 1,
			changeValue: 0.1,
			decimals: 1,
			onChange: onChangeHitsoundVolume
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "ratingoffset",
			description: "ratingoffset",
			variable: "ratingOffset",
			type: DoorsOptionType.INT,
			scrollSpeed: 20,
			minValue: -30,
			maxValue: 30,
			displayFormat: "%vms",
		};
		addOption(option);

		super(firstOpen);
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
	}
}