package states.storyrooms.shop;

import backend.storymode.InventoryManager;
import shaders.GlitchPosterize;
import shaders.GlitchShopShader;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import shaders.RGBGlitchShader;
import haxe.macro.Expr.Access;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.text.FlxTextNew as FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import CoolUtil;
import backend.metadata.ItemsMetadata;

using StringTools;

class GlitchedShopState extends MusicBeatState
{
    var spriteGroup:FlxSpriteGroup;
    var textGroup:FlxTypedGroup<FlxText>;

    var itemArray:Array<Dynamic> = [];

    var button:StoryModeSpriteHoverable;

    var glitch:Character;
    var glitchHands:FlxSprite;
    
    public var camBackground:FlxCamera;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

    var itemInventory:ItemInventory;

	var moneyIndicator:MoneyIndicator;
    var targetMoney:Int;
    
	var camFollowPos:FlxObject;

    var itemTargetScales:Array<FlxPoint> = [];
    var itemsGettingBought:Array<Int> = [];

    var bgShader:GlitchShopShader;
    var glitchChroma:GlitchPosterize;

	override function create()
	{
        DoorsUtil.loadRunData();
		MenuSongManager.crossfade("fuckedUpShop", 1, 100);

        camBackground = new FlxCamera();
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camGame.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;

		camFollowPos = new FlxObject(0, 0, 1, 1);

		camGame.follow(camFollowPos, LOCKON, 0.95);
		FlxG.cameras.add(camBackground, false);
		FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

        spriteGroup = new FlxSpriteGroup();
        textGroup = new FlxTypedGroup<FlxText>();

		var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('story_mode_backgrounds/shop/glitched/bg'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;

        var counterBG:FlxSprite = new FlxSprite(87,804).loadGraphic(Paths.image('story_mode_backgrounds/shop/glitched/counter'));
        counterBG.antialiasing = ClientPrefs.globalAntialiasing;

        button = new StoryModeSpriteHoverable(FlxG.width - 320/2, 0, "doorIdle", "");
        button.scale.set(0.8,0.8);
        button.updateHitbox();
        button.x = FlxG.width - button.width;
        button.y = 0;
        Paths.image("doorHover");
        button.antialiasing = ClientPrefs.globalAntialiasing;
		button.cameras = [camHUD];
        
		camFollowPos.setPosition(960, 540);
        camGame.zoom = 0.7;

		moneyIndicator = new MoneyIndicator(FlxG.width * 0.8, FlxG.height * 0.92, false);
		moneyIndicator.cameras = [camHUD];
        targetMoney = Std.parseInt(moneyIndicator.moneyCounter.text);

        itemInventory = new ItemInventory(VERTICAL, StoryMenuState.instance);
        itemInventory.cameras = [camHUD];

        glitch = new Character(0, 0, "glitch", false);
        glitch.setPosition(542, 200);
        var glitchCharShader = new GlitchPosterize();
        glitch.shader = glitchCharShader.shader;
        glitchCharShader.amount = 0.06;
        
		glitchHands = new FlxSprite(0, 0);
		glitchHands.frames = Paths.getSparrowAtlas("characters/glitch/GlitchHands");
		glitchHands.animation.addByPrefix("idle", "Idle Hands", 24, true);
		glitchHands.animation.play("idle");
        glitchHands.setPosition(600, 710);

        DoorsUtil.jeffShopData = DoorsUtil.generateShopData(
            1,
            [COMMON => 1],
            [COMMON => ["vitamins"]],
            [
                0 => "vitamins",
                1 => "",
                2 => "error",
                3 => "crucifix"
            ]
        );
        DoorsUtil.saveShopData();

        bgShader = new GlitchShopShader();
        add(bgShader);
        var bgFilter:ShaderFilter = new ShaderFilter(bgShader.shader);

        glitchChroma = new GlitchPosterize();
        glitchChroma.amount = 0.02;
        add(glitchChroma);
        var filter:ShaderFilter = new ShaderFilter(glitchChroma.shader);
        camHUD.setFilters([filter]);
        camGame.setFilters([filter]);
        camBackground.setFilters([bgFilter, filter]);

		add(bg);
        add(glitch);
		add(counterBG);
        add(glitchHands);
        add(spriteGroup);
        add(textGroup);
        generateItems();

        add(button);
        add(itemInventory);
		add(moneyIndicator);

		super.create();
	}

    var hoveredItem:Int = -1;
    var elapsed2:Float = 0;
	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 6, 0, 1);
        hoveredItem = -1;
        for(i in 0...spriteGroup.members.length){
            var isHovered:Bool = checkHovered(spriteGroup.members[i], camGame);
            if(isHovered){
                hoveredItem = i;
            }
        }
        
        elapsed2 += elapsed;
        if (elapsed2 >= 0.5) {
            textGroup.members[0].text = Std.string(new FlxRandom().int(20, 250));
            textGroup.members[2].text = Std.string(new FlxRandom().int(0, 100));
            textGroup.members[3].text = Std.string(new FlxRandom().int(100, 600));
            elapsed2 = 0;
        }

        itemTargetScales = [];
        for(i in 0...spriteGroup.members.length){
            itemTargetScales.push(new FlxPoint(1, 1));
        }

        //do thing
        if(hoveredItem != -1 && !itemsGettingBought.contains(hoveredItem)) {
            itemTargetScales[hoveredItem] = new FlxPoint(1.2, 1.2);
            if(FlxG.mouse.justPressed){
                buyItem(hoveredItem);
            }
        }

        //item scale lerp
        for(i in 0...spriteGroup.members.length){
            if(!itemsGettingBought.contains(hoveredItem)){
                spriteGroup.members[i].scale.set(
                    FlxMath.lerp(spriteGroup.members[i].scale.x, itemTargetScales[i].x, lerpVal/2),
                    FlxMath.lerp(spriteGroup.members[i].scale.y, itemTargetScales[i].y, lerpVal/2)
                );
            }
        }

        camHUD.alpha = FlxMath.lerp(camHUD.alpha, 1, lerpVal);

        button.checkOverlap(camHUD);

        if(button.isHovered){
            button.loadGraphic(Paths.image("doorHover"));
            if(FlxG.mouse.justPressed){
                trace("should leave");
                DoorsUtil.curRun.currentRoom.room.bossType = "jeff";
                DoorsUtil.curRun.curDoor = 51;
                DoorsUtil.saveStoryData();
                FlxG.save.data.jeffShopData = null;
                MusicBeatState.switchState(new StoryMenuState());
            }
        } else {
			button.loadGraphic(Paths.image("doorIdle"));
        }

        if(controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            DoorsUtil.saveShopData();
            MusicBeatState.switchState(new MainMenuState());
        }

        moneyIndicator.moneyCounter.text = Std.string(Math.round(FlxMath.lerp(Std.parseInt(moneyIndicator.moneyCounter.text), targetMoney, lerpVal*2)));
        if(Math.abs(targetMoney - Std.parseInt(moneyIndicator.moneyCounter.text)) < 10){
            moneyIndicator.moneyCounter.text = Std.string(targetMoney);
        }

        DoorsUtil.curRun.runSeconds += elapsed;
        if(DoorsUtil.curRun.runSeconds >= 3600) {
            DoorsUtil.curRun.runHours++;
            DoorsUtil.curRun.runSeconds -= 3600;
        }
		super.update(elapsed);
	}

    function generateItems(){
        for(i in 0...DoorsUtil.jeffShopData.items.length){
            if(DoorsUtil.jeffShopData.items[i] != null && DoorsUtil.jeffShopData.items[i] != "" && !DoorsUtil.jeffShopData.boughtItems[i]){
                var newSprite = new FlxSprite(0, 0).loadGraphic(getItemGraphic(DoorsUtil.jeffShopData.items[i]));
                newSprite.antialiasing = ClientPrefs.globalAntialiasing;
                newSprite.setPosition(
                    575 + (i * 233.5) + getItemOffset(DoorsUtil.jeffShopData.items[i]).x,
                    599 + getItemOffset(DoorsUtil.jeffShopData.items[i]).y
                );
                spriteGroup.add(newSprite);
    
                var tempItem = InventoryManager.fromItemIDtoItem(DoorsUtil.jeffShopData.items[i], /*itemInventory*/);
                var coinPrice = tempItem.itemData.itemCoinPrice;
    
                var theText = new FlxText(newSprite.x - getItemOffset(DoorsUtil.jeffShopData.items[i]).x, 946, 233.5, Std.string(coinPrice).trim(), 32);
                theText.setFormat(FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
                theText.antialiasing = ClientPrefs.globalAntialiasing;
                textGroup.add(theText);
            } else {
                //don't mind this, this is fucking stupid
                var newSprite = new FlxSprite(-3, -3).makeSolid(1, 1, 0xFF000000);
                spriteGroup.add(newSprite);

                var theText = new FlxText(-300, -300, 0, "a", 2);
                textGroup.add(theText);
            }
        }
    }

    function buyItem(index:Int){
        if(DoorsUtil.curRun.runMoney >= Std.parseInt(textGroup.members[index].text)){
            var r = DoorsUtil.curRun.curInventory.addItem(
                InventoryManager.fromItemIDtoItem(DoorsUtil.jeffShopData.items[index])
            );

            if(r){
                DoorsUtil.jeffShopData.boughtItems[index] = true;
                DoorsUtil.spendMoney(Std.parseInt(textGroup.members[index].text));
    
                itemsGettingBought.push(index);
                itemInventory.redrawItems();
    
                targetMoney -= Std.parseInt(textGroup.members[index].text);
                FlxTween.color(moneyIndicator.moneyCounter, 1.0, 0xFFFF0000, 0xFFFFFFFF, {ease: FlxEase.expoOut});
                FlxTween.tween(textGroup.members[index], {alpha: 0, y: 1280}, 0.9, {ease: FlxEase.cubeIn});
                FlxTween.tween(spriteGroup.members[index], {angle: 360, "scale.x": 0.01, "scale.y": 0.01}, 1.0, {ease: FlxEase.backIn, onComplete: function(twn){
                    spriteGroup.remove(spriteGroup.members[index]);
                    var newSprite = new FlxSprite(-3, -3).makeSolid(1, 1, 0xFF000000);
                    spriteGroup.insert(index, newSprite);
        
                    textGroup.remove(textGroup.members[index]);
                    var theText = new FlxText(-300, -300, 0, "a", 2);
                    textGroup.insert(index, theText);
                }});
            } else {
                // TODO : Add feedback that your inventory is full.
            }
        } else {
            // TODO : Add feedback that you don't have enough money.
        }
    }

    function tipJeff(){
        if(DoorsUtil.curRun.runMoney >= 25){
            DoorsUtil.spendMoney(25);
            targetMoney -= 25;
            FlxTween.cancelTweensOf(moneyIndicator.moneyCounter);
            FlxTween.color(moneyIndicator.moneyCounter, 1.0, 0xFFFF0000, 0xFFFFFFFF, {ease: FlxEase.expoOut});
        }
    }

    function getItemGraphic(item:String){
        return Paths.image('story_mode_backgrounds/shop/items/' + item);
    }

    function getItemOffset(item:String){
        var thePoint:FlxPoint = new FlxPoint(0,0);
        switch(item){
            case "lighter":
                thePoint.set(33, 84);
            case "vitamins":
                thePoint.set(59, 90);
            case "flashlight":
                thePoint.set(14, 120);
            case "error":
                thePoint.set(14, 72);
            case "crucifix":
                thePoint.set(13, 10);
        }
        return thePoint;
    }

    function checkHovered(item:FlxSprite, cam:FlxCamera){
        if  ((item.x + item.width > FlxG.mouse.getWorldPosition(cam).x)
            && (item.x < FlxG.mouse.getWorldPosition(cam).x)
            && (item.y + item.height > FlxG.mouse.getWorldPosition(cam).y)
            && (item.y < FlxG.mouse.getWorldPosition(cam).y)
        ) {
            return true;
        }
        return false;
    }
}