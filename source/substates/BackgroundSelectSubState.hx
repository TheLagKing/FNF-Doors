package substates;

import backend.SongMetadata;

class BackgroundSelectSubState extends MusicBeatSubstate {
    private final availableBackgrounds:Map<String, Array<String>> = [
        "A60" => ["Rooms"],
        "abuse" => ["Somewhere..."],
        "abush" => ["Corridor", "Bookshelves", "Crossroad"],
        "bad" => ["the lobby"],
        "bargainBG" => ["Jeff's Shop"],
        "black" => ["The Void"],
        "corridor" => ["Red Hallway"],
        "daddyIssues" => ["Family Home"],
        "drip" => ["Somewhere..."],
        "elevator" => ["Out of danger"],
        "eyes" => ["Crossroad", "Basement Entrance", "Downstairs"],
        "eyes-greenhouse" => ["Greenhouse"],
        "figureend" => ["Electrical Facility"],
        "f-library" => ["The Library"],
        "gangsta" => ["Somewhere..."],
        "glitch" => ["The Lobby"],
        "halt" => ["The Endless Hallway"],
        "jack" => ["In front of a closet"],
        "jeff-kill" => ["The Courtyard"],
        "lilguys" => ["Somewhere..."],
        "lobby" => ["The Lobby"],
        "mg" => ["Somewhere..."],
        "mutant" => ["Somewhere..."],
        "rush" => ["Closet Warehouse", "Blue Room", "Yellow Room"],
        "rush-greenhouse" => ["Greenhouse"],
        "screech" => ["Dark Room", "Basement", "Dark Corridor", "Windows"],
        "screech-greenhouse" => ["Greenhouse"],
        "seek_running_song" => ["Red Corridor"],
        "seek2" => ["Red Corridor"],
        "sencounter" => ["Red Corridor"],
        "stage" => ["Somewhere..."],
        "startpoint" => ["The Elevator"],
        "timothy" => ["In front of a drawer"],
        "timothy_joke" => ["Somewhere..."]
    ];

    public var selectedBackground:String = "";
    public var selectedID(get, never):Int;
    public function get_selectedID(){
        if(selectedBackground == "") selectedBackground = availableBackgrounds.get(stageFile)[0];
        return availableBackgrounds.get(stageFile).indexOf(selectedBackground);
    }

    private var selectedMetadata:SongMetadata;
    private var stageFile:String;

    public function new(selectedMetadata:SongMetadata, stageFile:String){
        super();

        this.stageFile = stageFile.replace("-greenhouse", "");
        this.selectedMetadata = selectedMetadata;
    }
}