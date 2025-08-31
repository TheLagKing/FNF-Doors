package options.substates;

import objects.ui.DoorsOption.DoorsOptionType;
import objects.ui.DoorsOption.CommonDoorsOption;

using StringTools;

class NewControlsSubState extends BaseOptionsMenu
{
	public function new(?firstOpen:Bool = false)
	{
		//path suffix
		internalTitle = "controls";
		title = 'Controls';
		rpcTitle = 'Controls Menu'; //for Discord Rich Presence

		// --------------------------------------------------

		var option:CommonDoorsOption = {name: "notes", category: "notes", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "note_left", category: "notes", 
		controlKey: "note_left", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "note_down", category: "notes", 
		controlKey: "note_down", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "note_up", category: "notes", 
		controlKey: "note_up", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "note_right", category: "notes", 
		controlKey: "note_right", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------

		var option:CommonDoorsOption = {name: "heartbeat", category: "heartbeat", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "heartbeat_left", category: "heartbeat", 
		controlKey: "heartbeat_left", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "heartbeat_right", category: "heartbeat", 
		controlKey: "heartbeat_right", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------
		
		var option:CommonDoorsOption = {name: "items", category: "items", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "item1", category: "items", 
		controlKey: "item1", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "item2", category: "items", 
		controlKey: "item2", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "item3", category: "items", 
		controlKey: "item3", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "item4", category: "items", 
		controlKey: "item4", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "item5", category: "items", 
		controlKey: "item5", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "item6", category: "items", 
		controlKey: "item6", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------
		
		var option:CommonDoorsOption = {name: "ui", category: "ui", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "reset", category: "ui", 
		controlKey: "reset", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "accept", category: "ui", 
		controlKey: "accept", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "back", category: "ui", 
		controlKey: "back", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "pause", category: "ui", 
		controlKey: "pause", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------
		
		var option:CommonDoorsOption = {name: "volume", category: "volume", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "volume_mute", category: "volume", 
		controlKey: "volume_mute", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "volume_up", category: "volume", 
		controlKey: "volume_up", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "volume_down", category: "volume", 
		controlKey: "volume_down", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------

		var option:CommonDoorsOption = {name: "debug", category: "debug", type: DoorsOptionType.CONTROLTITLE};
		addOption(option);

		var option:CommonDoorsOption = {name: "debug_1", category: "debug", 
		controlKey: "debug_1", type: DoorsOptionType.CONTROL};
		addOption(option);

		var option:CommonDoorsOption = {name: "debug_2", category: "debug", 
		controlKey: "debug_2", type: DoorsOptionType.CONTROL};
		addOption(option);

		// --------------------------------------------------

		super(firstOpen);
	}
}