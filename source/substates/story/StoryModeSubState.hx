package substates.story;

import objects.DoorsMouse.DoorsMouseActions;

class StoryModeSubState extends MusicBeatSubstate
{
	public var currentMouseAction:DoorsMouseActions = NONE;
	public function new()
	{
		super();
	}

	override function create(){
		super.create();

		StoryMenuState.instance.inSubState = true;
	}

	override function close(){
		StoryMenuState.instance.inSubState = false;
		super.close();
	}

	override function update(elapsed){
		DoorsUtil.curRun.runSeconds += elapsed;
		if(DoorsUtil.curRun.runSeconds >= 3600) {
			DoorsUtil.curRun.runHours++;
			DoorsUtil.curRun.runSeconds -= 3600;
		}

		super.update(elapsed);

		theMouse.currentAction = currentMouseAction;
	}

	function startGaming(){ }
	function stopGaming(){close();}
}
