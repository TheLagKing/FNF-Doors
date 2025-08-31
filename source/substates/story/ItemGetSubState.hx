package substates.story;

import objects.items.Item;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class ItemGetSubState extends StoryModeSubState
{
	var latestItem:FlxSprite;
	var itemBox:FlxSprite;

	var grid:FlxBackdrop;
	var youGotA:FlxText;
	var itemDescription:FlxText;
	var warning:FlxText;

	var evilTrail:FlxTrail;

	var clickAnywhereToLeave:FlxText;

	var theItem:Item;

	var hasQuit:Bool = false;

	public function new(ite){
		this.theItem = ite;
		super();
	}

	override function create()
	{
		super.create();
		hasQuit = false;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x80432004, 0x80400415));
		grid.velocity.set(0, 40);
		grid.alpha = 0;
		add(grid);

		latestItem = theItem.returnGraphic();
		latestItem.scale.set(0.5, 0.5);
		latestItem.updateHitbox();
		latestItem.setPosition(
			640 - latestItem.width/2,
			360 - latestItem.height/2
		);
		add(latestItem);

		itemBox = new FlxSprite().loadGraphic(Paths.image('storyItems/box'));
		itemBox.antialiasing = ClientPrefs.globalAntialiasing;
		itemBox.scale.set(0.125, 0.125);
		itemBox.updateHitbox();
		itemBox.alpha = 0.00001;
		add(itemBox);

		youGotA = new FlxText(0, latestItem.y - 60, FlxG.width,
			"",
			32);
		youGotA.setFormat(FONT, 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		youGotA.text = StringTools.replace((Lang.getText("singular", "story/itemget"):String), "{0}", theItem.itemData.displayName);
		youGotA.antialiasing = ClientPrefs.globalAntialiasing;
		if (theItem.itemData.isPlural) youGotA.text = (Lang.getText("multiple", "story/itemget"):String).replace("{0}", theItem.itemData.displayName);

		itemDescription = new FlxText(0, latestItem.y + latestItem.height + 10, FlxG.width,
			"",
			32);
		itemDescription.setFormat(FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		itemDescription.antialiasing = ClientPrefs.globalAntialiasing;
		itemDescription.text = theItem.itemData.displayDesc;

		warning = new FlxText(0, itemDescription.y + 50, FlxG.width,
			"",
			24);
		warning.setFormat(FONT, 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		warning.antialiasing = ClientPrefs.globalAntialiasing;
		warning.text = Lang.getText("warn", "story/itemget");

		add(youGotA);
		add(itemDescription);
		add(warning);

		clickAnywhereToLeave = new FlxText(0, FlxG.height * 0.9, FlxG.width, Lang.getText("clickOff", "newUI"));
		clickAnywhereToLeave.antialiasing = ClientPrefs.globalAntialiasing;
		clickAnywhereToLeave.setFormat(FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		clickAnywhereToLeave.alpha = 0;
		add(clickAnywhereToLeave);
		startGaming();
	}

	override function startGaming(){
		latestItem.alpha = 0.00001;
		latestItem.y -= 15;
		youGotA.alpha = 0.00001;
		youGotA.y -= 15;
		itemDescription.alpha = 0.00001;
		itemDescription.y -= 15;
		warning.alpha = 0.00001;
		warning.y -= 15;
		FlxTween.tween(grid, {alpha: 1}, 0.8, {ease: FlxEase.quadOut});
		FlxTween.tween(youGotA, {y: youGotA.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.0});
		FlxTween.tween(latestItem, {y: latestItem.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.1});
		FlxTween.tween(itemDescription, {y: itemDescription.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.2});
		FlxTween.tween(warning, {y: warning.y + 15, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.3});
		FlxTween.tween(clickAnywhereToLeave, {alpha: 0.4}, 2.0, {ease: FlxEase.quadOut, startDelay: 3.0});
	}

	override function stopGaming(){
		hasQuit = true;
		FlxTween.cancelTweensOf(grid);
		FlxTween.cancelTweensOf(latestItem);
		FlxTween.cancelTweensOf(youGotA);
		FlxTween.cancelTweensOf(itemDescription);
		FlxTween.cancelTweensOf(warning);
		FlxTween.cancelTweensOf(clickAnywhereToLeave);

		evilTrail = new FlxTrail(latestItem, null, 8*Math.floor(ClientPrefs.data.framerate/60), 0, 0.7, 0.1 / Math.floor(ClientPrefs.data.framerate/60));
		evilTrail.framesEnabled = true;
		add(evilTrail);

		itemBox.setPosition(414 + (79 * theItem.itemData.itemSlot), 654);
		
		FlxTween.tween(grid, {alpha: 0}, 0.8, {ease: FlxEase.quadOut});
		FlxTween.tween(youGotA, {y: youGotA.y + 15, alpha: 0.0001}, 0.5, {ease: FlxEase.quadIn, startDelay: 0.2});
		FlxTween.tween(itemDescription, {y: itemDescription.y + 15, alpha: 0.0001}, 0.5, {ease: FlxEase.quadIn, startDelay: 0.1});
		FlxTween.tween(warning, {y: warning.y + 15, alpha: 0.0001}, 0.5, {ease: FlxEase.quadIn, startDelay: 0.0});
		FlxTween.tween(itemBox, {alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.3});
		FlxTween.tween(latestItem, {y: 654, x: 414 + (79 * theItem.itemData.itemSlot), "scale.x": 0.125, "scale.y": 0.125}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.3, onUpdate: function(twn){
			try {
				latestItem.updateHitbox();
			} catch(e) {}
		}, onComplete: function(twm){
			StoryMenuState.instance.freezeItem = false;
			new FlxTimer().start(0.4, function(tmr) {
				StoryMenuState.instance.itemInventory.redrawItems();
				StoryMenuState.instance.iLikeMen = 634;
				close();
			});
		}});
		FlxTween.tween(clickAnywhereToLeave, {alpha: 0}, 0.8, {ease: FlxEase.quadIn});
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT || controls.BACK || FlxG.mouse.justPressed) {
			if(hasQuit) return;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			stopGaming();
		}
		super.update(elapsed);
	}
}
