package states.mechanics;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class TimothyCum extends MechanicsManager
{
    var webGroup:FlxSpriteGroup;


    public function new()
    {
        super();
    }

    override function create()
    {
        Paths.image("web");
        webGroup = new FlxSpriteGroup(0, 0, 4);
        webGroup.cameras = [game.camHUD];
    }

    override function createPost(){
        add(webGroup);
    }

    override function triggerEventNote(eventName:String, value1:String, value2:String, strumTime:Float) { 
        switch(eventName){
            case "timCum":
                game.dad.playAnim("attack", true, false, 0, true);
                new FlxTimer().start(0.5, function(tmr){
                    var startPos:Float = ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL + 640 : PlayState.STRUM_X + 640;
                    var web = webGroup.recycle(FlxSprite, makeNewWeb, false, true);
                    web.scale.set(0.01, 0.01);
                    web.alpha = 1;
                    web.setPosition(FlxG.random.float(startPos-80, startPos+222),FlxG.random.float(-30, 240));
                    FlxTween.tween(web, {"scale.x": 1.0,"scale.y": 1.0}, Conductor.stepCrochet/2000, {ease: FlxEase.expoOut, onComplete: function(twn){
                        FlxTween.tween(web, {alpha: 0.00001, y: web.y + 40}, Conductor.stepCrochet/125, {ease: FlxEase.circIn, startDelay: Conductor.crochet/250, onComplete: function(twn){
                            web.kill();
                        }});
                    }});
    
                    webGroup.add(web);
                });
        }
    }

    function makeNewWeb(){
        var startPos:Float = ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL + 640: PlayState.STRUM_X + 640;
        var web = new FlxSprite(FlxG.random.float(startPos -80, startPos + 222),FlxG.random.float(-30, 240)).loadGraphic(Paths.image("web"));
        web.antialiasing = ClientPrefs.globalAntialiasing;
        return web;
    }
}