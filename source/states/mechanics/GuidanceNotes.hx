package states.mechanics;


class GuidanceNotes extends MechanicsManager
{
    public var requirement:Void -> Bool;
    public var randomRequirement:Void -> Bool;

    public function new()
    {
        super();
        requirement = function(){
            return switch(PlayState.storyDifficulty){
                case 0: game.ratingPercent < 0.90;
                case 2: game.health <= 0.5 && game.ratingPercent < 0.85 && game.songMisses >= 20;
                case 3: false;

                case 1: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                default: game.health <= 1.5 && game.ratingPercent < 0.90 && game.songMisses >= 5;
                
            }
        }
        randomRequirement = function(){
            return switch(PlayState.storyDifficulty){
                case 0: FlxG.random.bool(50 * ((2.0 - game.health) / 2));
                case 2: FlxG.random.bool(20 * ((2.0 - game.health) / 2));
                case 3: false;
                
                case 1: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
                default: FlxG.random.bool(35 * ((2.0 - game.health) / 2));
            }
        }
    }

    override function noteSpawn(note:Note){
        if(!note.mustPress || note.isSustainNote || note.texture == "NOTE_taiko") return;
        
        if((requirement != null && requirement()) || PlayState.SONG.song.toLowerCase() == "guidance"){
            if(randomRequirement != null && randomRequirement()){
                if(note.noteType == "Alt Animation") {
                    note.noteType = "Alt Animation+Guidance Note";
                    for (t in note.tail){
                        t.noteType = "Alt Animation+Guidance Note";
                    }
                } else if(note.noteType == null || note.noteType == ""){
                    note.noteType = "Guidance Note";
                    for (t in note.tail){
                        t.noteType = "Guidance Note";
                    }
                }
            }
        }
    }
}