package;

import backend.macro.GitCommitMacro;
import lime.app.Application;

class Constants {
    public static var FONT(default, set):String = Paths.font("Oswald.ttf");
    public static var MEDIUM_FONT(default, set):String = Paths.font("Oswald-Medium.ttf");
    
    public static function set_FONT(fontName:String){
        FONT = Paths.font('${fontName}');
        return fontName;
    }
    public static function set_MEDIUM_FONT(fontName:String){
        MEDIUM_FONT = Paths.font('${fontName}');
        return fontName;
    }

    public static var DOORS_FONT(default, set):String = Paths.font("Doors.ttf");
    
    public static function set_DOORS_FONT(fontName:String){
        DOORS_FONT = Paths.font('${fontName}');
        return fontName;
    }

    /**
     * The title of the game, for debug printing purposes.
     * Change this if you're making an engine.
     */
    public static final TITLE:String = "FNF : Doors";
  
    /**
     * The current version number of the game.
     * Modify this in the `project.xml` file.
     */
    public static var VERSION(get, never):String;

    /**
    * A suffix to add to the game version.
    * Add a suffix to prototype builds and remove it for releases.
    */
    public static final VERSION_SUFFIX:String = #if debug ' PROTOTYPE' #else ' RELEASE' #end;

    #if debug
    static function get_VERSION():String
    {
        return 'v${Application.current.meta.get('version')} | Commit: ${GitCommitMacro.commitNumber} (${GitCommitMacro.commitHash})' + VERSION_SUFFIX;
    }
    #else
    static function get_VERSION():String
    {
        return 'v${Application.current.meta.get('version')}' + VERSION_SUFFIX;
    }
    #end
    
    /**
    * The generatedBy string embedded in the chart files made by this application.
    */
    public static var GENERATED_BY(get, never):String;

    static function get_GENERATED_BY():String
    {
        return '${Constants.TITLE} - ${Constants.VERSION}';
    }

    public static var ALL_SONGS_FOR_COMPLETIONIST:Array<String>;
}