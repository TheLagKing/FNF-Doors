package substates.story;

import backend.storymode.InventoryManager;
import objects.ui.DoorsBuyable;
import objects.ui.DoorsMenu;
import substates.MusicBeatSubstate;

using StringTools;

class PrerunShopSubState extends StoryModeSubState
{
	var BUYABLEIDLIST = ["bandages", "vitamins", "lighter", "flashlight"];

	var menuBG:DoorsMenu;
	var newKnobIndicator:MoneyIndicator;
    var targetMoney:Int;

	public function new()
	{
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		menuBG = new DoorsMenu(300, 40, "pre-run", Lang.getText("prerun", "newUI"), true);
		menuBG.closeFunction = stopGaming;
		add(menuBG);

		StoryMenuState.instance.knobIndicator.visible = false;
		newKnobIndicator = new MoneyIndicator(324, 620, true);
		makeBuyables();
		add(newKnobIndicator);
		targetMoney = Std.parseInt(newKnobIndicator.moneyCounter.text);

		startGaming();
	}

	override function update(elapsed:Float)
	{
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 6, 0, 1);

        newKnobIndicator.moneyCounter.text = Std.string(Math.round(FlxMath.lerp(Std.parseInt(newKnobIndicator.moneyCounter.text), targetMoney, lerpVal)));
        if(Math.abs(targetMoney - Std.parseInt(newKnobIndicator.moneyCounter.text)) < 10){
            newKnobIndicator.moneyCounter.text = Std.string(targetMoney);
        }

		super.update(elapsed);
	}

    override function beatHit(){
        super.beatHit();
    }

	function makeBuyables(){
		var curRow = 0;
		for(i=>buyable in BUYABLEIDLIST){
			if(i%2 == 0 && i>1) curRow++;
			var newBuyable = new DoorsBuyable(
				322 + (i%2 * 326), 
				140 + (curRow * 177), 
				InventoryManager.fromItemIDtoItem(buyable), 
				NORMAL,
				function(){
					trace(i);
					buyItem(i);
				});
			add(newBuyable);
		}
	}

    function buyItem(index:Int){
		var theItem = InventoryManager.fromItemIDtoItem(BUYABLEIDLIST[index]);
		var theData = theItem.itemData;

        if(DoorsUtil.knobs >= theData.itemKnobPrice){
            var r = DoorsUtil.curRun.curInventory.addItem(theItem);
			if(r) {
				DoorsUtil.addKnobs(-theData.itemKnobPrice, 1.0);

				StoryMenuState.instance.itemInventory.redrawItems();

				targetMoney -= theData.itemKnobPrice;
				FlxTween.color(newKnobIndicator.moneyCounter, 1.0, 0xFFFF0000, 0xFFFFFFFF, {ease: FlxEase.expoOut});
			}

		}
    }

    override function startGaming(){
        this.forEach(function(basic:Dynamic){
            try{
                if(Std.isOfType(basic, FlxSprite)){
                    FlxTween.tween((basic:FlxSprite), {x: (basic:FlxSprite).x}, 0.6, {ease:FlxEase.quadInOut});
                    (basic:FlxSprite).x -= 1280;
                }
            } catch(e){}
        });
    }

    var isClosed = false;
    override function stopGaming(){
		StoryMenuState.instance.knobIndicator.visible = true;
		newKnobIndicator.visible = false;
        this.forEach(function(basic:Dynamic){
            try{
                if(Std.isOfType(basic, FlxSprite)){
                    FlxTween.tween((basic:FlxSprite), {x: (basic:FlxSprite).x - 1280}, 0.6, {ease:FlxEase.quadInOut, onComplete: function(twn){
                        if(!isClosed){
                            isClosed = true;
							StoryMenuState.instance.itemInventory.redrawItems();
							StoryMenuState.instance.iLikeMen = 634;
                            close();
                        }
                    }});
                }
            } catch(e){}
        });
    }
}