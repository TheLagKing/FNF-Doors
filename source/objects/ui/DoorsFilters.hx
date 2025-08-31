package objects.ui;

import online.Leaderboards.LeaderboardSongScore;

class DoorsFilters extends FlxSpriteGroup {
    var filterBar:FlxSpriteGroup;
        var bg:FlxSprite;
        var icon:FlxSprite;
        var filterText:FlxText;

    var filterGroup:FlxTypedSpriteGroup<DoorsFilter>;

    public var arrayToFilter:Array<Dynamic> = [];
    public var filteredArray:Array<Dynamic> = [];
    var lastArray:Array<Dynamic> = [];

    var translationPath:String = "";

    var onFilter:Void -> Void;

    /*
    * @param arrayToFilter Send an array of Dynamic, most likely JSON objects.
    * @param filterBy The variable inside one JSON object to filter by.
    */
    public function new(x:Float, y:Float, arrayToFilter:Array<Dynamic>, filterBy:String, translationPath:String, onFilter:Void -> Void){
        super(x, y);

        this.translationPath = translationPath;
        this.onFilter = onFilter;

        for(object in arrayToFilter){
            if(!this.arrayToFilter.contains(Reflect.field(object, filterBy)))
                this.arrayToFilter.push(Reflect.field(object, filterBy));
        }
        this.lastArray = this.arrayToFilter;

        makeFilterBar();
        makeFilterSelectors();

        forEach(function(spr){
            spr.antialiasing = ClientPrefs.globalAntialiasing;
        });
    }

    public function makeFilterBar(){
        bg = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/filters/barBG"));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        icon = new FlxSprite(7, 7).loadGraphic(Paths.image("ui/filters/barIcon"));
        icon.antialiasing = ClientPrefs.globalAntialiasing;
        add(icon);
    }

    public function makeFilterSelectors(){
        filterGroup = new FlxTypedSpriteGroup<DoorsFilter>(0, 37);
        for(i=>filter in arrayToFilter){
            var filterSelector = new DoorsFilter(filter, translationPath, onFilter);
            filterSelector.setPosition(0, (i*34));
            filterGroup.add(filterSelector);
        }
        add(filterGroup);
    }

	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        justStoppedHovering = false;
        if  ((this.x + bg.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + bg.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            if(isHovered){
                justStoppedHovering = true;
            }
            isHovered = false;
        }
    }

    override function update(elapsed:Float){
        checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

        var tempArr:Array<String> = [];
        for(filterSelector in filterGroup.members){
            if(filterSelector.isSelected){
                tempArr.push(filterSelector.assignedFilter);
            }
        }
        if(tempArr.length > 0) filteredArray = tempArr;
        else filteredArray = arrayToFilter;

        if(filteredArray.length != lastArray.length){
            lastArray = filteredArray;
            onFilter();
        }

        super.update(elapsed);
    }
}

class DoorsFilter extends FlxSpriteGroup {
    var bg:FlxSprite;
    var text:FlxText;

    public var assignedFilter:String;
    var translationPath:String;
    var onFilter:Void -> Void;

    public var isSelected(default, set):Bool = false;
    public function set_isSelected(v:Bool){
        isSelected = v;
        makeDisplay(v);
        return isSelected;
    }

    public function new(assignedFilter:String, translationPath:String, onFilter:Void -> Void){
        super(0, 0);
        this.assignedFilter = assignedFilter;
        this.translationPath = translationPath;
        this.onFilter = onFilter;

        makeDisplay(false);
    }

    public function makeDisplay(selected:Bool){
        if(this.members.contains(bg)) {
            remove(bg);
        } 
        bg = new FlxSprite().loadGraphic(Paths.image('ui/filters/filter${!selected ? 'Normal' : 'Selected'}'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        if(this.members.contains(text)) remove(text);
        text = new FlxText(2, 2, 305, Lang.getText(assignedFilter, translationPath, "value"));
        if(selected) text.setFormat(MEDIUM_FONT, 24, 0xFF452D25, CENTER, NONE, FlxColor.TRANSPARENT);
        else text.setFormat(FONT, 24, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
        text.antialiasing = ClientPrefs.globalAntialiasing;
        add(text);
    }

	public var isHovered:Bool;
    public var justHovered:Bool;
    public var justStoppedHovering:Bool;
    public function checkOverlap(camera:FlxCamera){
        justHovered = false;
        justStoppedHovering = false;
        if  ((this.x + bg.width > FlxG.mouse.getWorldPosition(camera).x)
            && (this.x < FlxG.mouse.getWorldPosition(camera).x)
            && (this.y + bg.height > FlxG.mouse.getWorldPosition(camera).y)
            && (this.y < FlxG.mouse.getWorldPosition(camera).y)
        ) {
            if(!isHovered){
                justHovered = true;
            }
            isHovered = true;
        } else {
            if(isHovered){
                justStoppedHovering = true;
            }
            isHovered = false;
        }
    }

    override function update(elapsed:Float){
        checkOverlap(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

        if(this.isHovered && FlxG.mouse.justPressed){
            this.isSelected = !this.isSelected;
            //onFilter();
        }

        super.update(elapsed);
    }
}