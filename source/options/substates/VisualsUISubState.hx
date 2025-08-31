package options.substates;

import objects.ui.DoorsOption.DoorsOptionType;
import objects.ui.DoorsOption.CommonDoorsOption;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new(?firstOpen:Bool = false)
	{
		internalTitle = "visuals";
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:CommonDoorsOption = {
			name: "notesplash",
			description: "notesplash",
			variable: "noteSplashes",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "notesplashAlpha",
			description: "notesplashAlpha",
			variable: "splashAlpha",
			type: DoorsOptionType.PERCENT,
			scrollSpeed: 1.6,
			minValue: 0.0,
			maxValue: 1,
			changeValue: 0.1,
			decimals: 1,
			displayFormat: '%v%',
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "hidehud",
			description: "hidehud",
			variable: "hideHud",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);
		
		var option:CommonDoorsOption = {
			name: "timebar",
			description: "timebar",
			variable: "timeBarType",
			type: DoorsOptionType.STRING,
			stringOptions: ['timeleft', 'timeelapsed', 'songname', 'songname-timeleft', 'disabled'],
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "flashinglights",
			description: "flashinglights",
			variable: "flashing",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "camerazooms",
			description: "camerazooms",
			variable: "camZooms",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "camerafollow",
			description: "camerafollow",
			variable: "camFollow",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "cameraangle",
			description: "cameraangle",
			variable: "camAngle",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "healthslide",
			description: "healthslide",
			variable: "chachaSlide",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "healthicons",
			description: "healthicons",
			variable: "iconsOnHB",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "scoretxtzoom",
			description: "scoretxtzoom",
			variable: "scoreZoom",
			type: DoorsOptionType.BOOL,
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "fpscounter",
			description: "fpscounter",
			variable: "showFPS",
			type: DoorsOptionType.BOOL,
			onChange: onChangeFPSCounter
		};
		addOption(option);

		super(firstOpen);
	}

	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
}