package shaders;

import flixel.FlxG;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;



//thank you salad :)
class ColorblindFilters {
    public static var filterArray:Array<BitmapFilter> = [];
    public static var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
        // Matrix for deuteranopia (red-green color blindness)
        "deuteranopia" => {
            var matrix:Array<Float> = [
                0.43, 0.72, -0.15, 0, 0,
                0.34, 0.57,  0.09, 0, 0,
               -0.02, 0.03,  1.00, 0, 0,
                0,    0,     0,    1, 0
            ];
            {filter: new ColorMatrixFilter(matrix)}
        },
        // Matrix for protanopia (red color blindness)
        "protanopia" => {
            var matrix:Array<Float> = [
                0.20, 0.99, -0.19, 0, 0,
                0.16, 0.79,  0.04, 0, 0,
                0.01, -0.01, 1.00, 0, 0,
                0,    0,     0,    1, 0
            ];
            {filter: new ColorMatrixFilter(matrix)}
        },
        // Matrix for tritanopia (blue-yellow color blindness)
        "tritanopia" => {
            var matrix:Array<Float> = [
                0.97, 0.11, -0.08, 0, 0,
                0.02, 0.82,  0.16, 0, 0,
                0.06, 0.88,  0.18, 0, 0,
                0,    0,     0,    1, 0
            ];
            {filter: new ColorMatrixFilter(matrix)}
        }
    ];

    public static function applyFiltersOnGame():Void {
        filterArray = [];
        FlxG.game.setFilters(filterArray);

        var selectedMode:String = ClientPrefs.data.colorblindMode;
        if (selectedMode != "None") {
            var filterData = filterMap.get(selectedMode);
            if (filterData != null && filterData.filter != null) {
                filterArray.push(filterData.filter);
            } else {
                trace("Warning: Invalid colorblind mode or filter not found.");
            }
        }
        
        FlxG.game.setFilters(filterArray);
    }
}