package states.storyrooms.roomTypes;

class Courtyard extends BaseSMRoom {
    override function create() { 
        drawCourtyard();
    }

	private function drawCourtyard(){
		var background:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("story_mode_backgrounds/courtyard"));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);
		
		var door:StoryModeSpriteHoverable = cast new StoryModeSpriteHoverable(843, 412, "").makeGraphic(246, 206, FlxColor.TRANSPARENT);
		//don't turn this into a makeSolid, cause getGraphicMidpoint() doesn't work with makeSolids
		door.alpha = 0.00001;
		add(door);
		doors.push({
			doorNumber: 91,
			doorSpr: door,
			side: "right",
			isLocked: false,
			song: "None"
		});
	}
}