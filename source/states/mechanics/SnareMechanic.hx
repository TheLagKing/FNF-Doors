package states.mechanics;

import openfl.display.BlendMode;
#if !flash 
import openfl.filters.ShaderFilter;
#end

class SnareMechanic extends MechanicsManager
{
    var healthTreshold = 0.3;
    var healthbarPositionAimX:Float = 1280;
    var snareIcon:HealthIcon;
    var snareOverlay:ColorBar;
    
    var popupGroup:FlxSpriteGroup;


    public function new()
    {
        super();
    }

    override function create()
    {
		snareIcon = new HealthIcon("snare", true);
		snareIcon.visible = !ClientPrefs.data.hideHud;
		snareIcon.alpha = ClientPrefs.data.healthBarAlpha;
        snareIcon.cameras = [game.camHUD];
        snareIcon.scale.set(0.9, 0.9);
        snareIcon.updateHitbox();
    }

    override function createPost() {
		snareIcon.y = game.healthBar.y - 40;
		game.uiGroup.insert(game.uiGroup.members.indexOf(game.iconP1), snareIcon);

        snareOverlay = new ColorBar(game.aegisOverlay.x, game.aegisOverlay.y, RIGHT_TO_LEFT, Std.int(game.aegisOverlay.width), Std.int(game.aegisOverlay.height), this,
        'healthTreshold', 0, DoorsUtil.maxHealth);
		snareOverlay.scrollFactor.set();
		snareOverlay.antialiasing = false;
		snareOverlay.visible = !ClientPrefs.data.hideHud;
		snareOverlay.alpha = ClientPrefs.data.healthBarAlpha;
		snareOverlay.blend = BlendMode.MULTIPLY;
		snareOverlay.createImageEmptyBar(Paths.image('healthBars/healthbarMask'), 0x00000000) ;
		snareOverlay.createImageFilledBar(Paths.image('healthBars/healthbarMask'), FlxColor.WHITE) ;
        snareOverlay.cameras = [game.camHUD];

		snareOverlay.backColorTransform.color = 0x00FFFFFF;
		snareOverlay.frontColorTransform.color = 0xFF004023;
		game.uiGroup.insert(game.uiGroup.members.indexOf(game.aegisOverlay) + 1, snareOverlay);

        snareIcon.x = game.healthBar.x + (game.healthBar.width * (
            FlxMath.remapToRange(healthTreshold, 0, DoorsUtil.maxHealth, 100, 0) * 0.01
            )) + (150 * snareIcon.scale.x - 150) / 2 - 101;

        move(0.8);

        if(DoorsUtil.curRun.sawGreenhousePopup) return;
        createPopup();
        PlayState.instance.add(popupGroup);
        FlxTween.tween(popupGroup, {x : FlxG.width}, 1, {ease: FlxEase.quartIn, startDelay: 4, onComplete:function(twn){
            PlayState.instance.remove(popupGroup);
        }});
    }

	var moveCooldown:Float = 0;
    override function update(elapsed:Float)
    {
		snareIcon.y = game.healthBar.y - 40;
        healthbarPositionAimX = game.healthBar.x + (game.healthBar.width * (
            FlxMath.remapToRange(healthTreshold, 0, DoorsUtil.maxHealth, 100, 0) * 0.01
            )) + (150 * snareIcon.scale.x - 150) / 2 - 101;

        snareIcon.x = FlxMath.lerp(snareIcon.x, healthbarPositionAimX, CoolUtil.boundTo(elapsed*4, 0, 1));

		moveCooldown -= elapsed;
        if(game.health <= healthTreshold + DoorsUtil.maxHealth/3){
            snareIcon.animation.curAnim.curFrame = 1;
            game.iconP1.animation.curAnim.curFrame = 1;
        } else {
            snareIcon.animation.curAnim.curFrame = 0;
            game.iconP1.animation.curAnim.curFrame = 0;
        }
    }

    override function updatePost(elapsed:Float){
        if(game.health <= healthTreshold + DoorsUtil.maxHealth/7){
            if(PlayState.healthLoss > 0.01) game.health = -1;
        }
    }

    override function onStepHit(curStep:Int) { 
        if(FlxG.random.bool(10) && moveCooldown <= 0){
            moveCooldown = FlxG.random.float(8, 16);
            move(0.35);
        }
    }

	function move(mercyBonus:Float){
        healthTreshold = FlxG.random.float(DoorsUtil.maxHealth/8, DoorsUtil.maxHealth/4);
        if(game.health <= healthTreshold + mercyBonus) game.health = healthTreshold + mercyBonus;
	}

    private function createPopup() {
        DoorsUtil.curRun.sawGreenhousePopup = true;

        popupGroup = new FlxSpriteGroup(792, 21);
        popupGroup.cameras = [PlayState.instance.camOther];

        var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("mechanics/popups/snare"));
        popupGroup.add(bg);

        var majorText:FlxText = new FlxText(20, 15, 300, Lang.getText("major", "mechanics/popups/snare"));
        majorText.setFormat(FONT, 64, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF004023);
        majorText.borderSize = 2;
        popupGroup.add(majorText);

        var minorText:FlxText = new FlxText(20, 102, 300, (Lang.getText("minor", "mechanics/popups/snare"):String).replace("{0}", "SPACE"));
        minorText.setFormat(FONT, 32, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF004023);
        minorText.borderSize = 2;
        popupGroup.add(minorText);

        popupGroup.setPosition(FlxG.width, 21);
        FlxTween.tween(popupGroup, {x : 792}, 1, {ease: FlxEase.quartIn});
    }
}