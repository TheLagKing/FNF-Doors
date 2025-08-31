package online;

//codename new input
import objects.ui.UITextBox;
import flixel.math.FlxRect;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import objects.ui.UISprite;
import objects.ui.IUIFocusable;
//end codename

import PopUp.MessagePopup;
import objects.ui.DoorsButton;
import flixel.math.FlxPoint;
import objects.ui.DoorsMenu;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxButtonPlus;
import flixel.text.FlxText;
import flixel.FlxG;
import lime.system.System;

class GlasshatLogin extends MusicBeatSubstate
{
    //codename new input
	public var buttonHandler:Void->Void = null;
	public var hoveredSprite:UISprite = null;
	public var currentFocus:IUIFocusable = null;

	public static var instance:GlasshatLogin;

	private var __mousePos:FlxPoint;
	private var __rect:FlxRect;
    //end codename

    var emInputText:UITextBox;
    var diInputText:UITextBox;
    var utInputText:UITextBox;

    var seePassword:StoryModeSpriteHoverable;
    var paField:FlxSprite;

	final options:Array<String> = ['language', "glasshat", 'controls', 'graphics', 'visuals', 'gameplay'];
	var visualOptions:Array<String> = [];
	private var switchStateButtons:FlxTypedSpriteGroup<DoorsButton>;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'language':
				_parentState.openSubState(new options.substates.LanguageSubState());
			case 'controls':
				_parentState.openSubState(new options.substates.NewControlsSubState());
			case 'graphics':
				_parentState.openSubState(new options.substates.GraphicsSettingsSubState());
			case 'visuals':
				_parentState.openSubState(new options.substates.VisualsUISubState());
			case 'gameplay':
				_parentState.openSubState(new options.substates.GameplaySettingsSubState());
			case 'glasshat':
				_parentState.openSubState(new online.GlasshatLogin());
		}
		close();
	}

    public function new()
    {
        super();
    }
    override public function create()
    {
        instance = this;
		__rect = new FlxRect();
		__mousePos = FlxPoint.get();
        
		for(i in 0...options.length){
			visualOptions.push('options/main/${options[i]}');
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var blacc:FlxSprite = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		blacc.alpha = 0.6;
		add(blacc);

		var bg:DoorsMenu = new DoorsMenu(8,8,"options", Lang.getText("glasshatOnline", "newUI"), true, FlxPoint.get(1203, 25));
		bg.closeFunction = function(){
            FlxG.save.data.doorsUsername = emInputText.label.text;
            FlxG.save.data.doorsPassword = utInputText.label.text;
            FlxG.save.flush();
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		add(bg);

        var usernameField:FlxSprite = new FlxSprite(24, 92).loadGraphic(Paths.image("ui/glasshat/normalField"));
        usernameField.antialiasing = ClientPrefs.globalAntialiasing;
        add(usernameField);

        paField = new FlxSprite(24, 242).loadGraphic(Paths.image("ui/glasshat/passwordField"));
        Paths.image("ui/glasshat/passwordFieldVisible");
        paField.antialiasing = ClientPrefs.globalAntialiasing;
        add(paField);

        var diField:FlxSprite = new FlxSprite(24, 167).loadGraphic(Paths.image("ui/glasshat/normalField"));
        diField.antialiasing = ClientPrefs.globalAntialiasing;
        add(diField);

        var bottomField:FlxSprite = new FlxSprite(24, 381).loadGraphic(Paths.image("ui/glasshat/infoField"));
        bottomField.antialiasing = ClientPrefs.globalAntialiasing;
        add(bottomField);

        var emailText:FlxText = new FlxText(38, 96, FlxG.width, Lang.getText("email", "glasshat"));
        emailText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF452D25);
        add(emailText);
        emailText.antialiasing = ClientPrefs.globalAntialiasing;

        var usernameText:FlxText = new FlxText(38, 171, FlxG.width, Lang.getText("username", "glasshat"));
        usernameText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF452D25);
        add(usernameText);
        usernameText.antialiasing = ClientPrefs.globalAntialiasing;

        var passwordText:FlxText = new FlxText(38, 246, FlxG.width, Lang.getText("password", "glasshat"));
        passwordText.setFormat(FONT, 32, 0xFFFEDEBF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF452D25);
        add(passwordText);
        passwordText.antialiasing = ClientPrefs.globalAntialiasing;

        var passwordInfo:FlxText = new FlxText(38, 308, FlxG.width, Lang.getText("passwordInfo", "glasshat"));
        passwordInfo.setFormat(FONT, 20, 0xFFFEDEBF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF452D25);
        add(passwordInfo);
        passwordInfo.antialiasing = ClientPrefs.globalAntialiasing;

        var bottomInfo:FlxText = new FlxText(365, 399, 871, Lang.getText("info", "glasshat"));
        bottomInfo.setFormat(FONT, 36, 0xFFFEDEBF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF452D25);
        add(bottomInfo);
        bottomInfo.antialiasing = ClientPrefs.globalAntialiasing;

        //set up typers
        emInputText = new UITextBox(271,104, '', 966);
        emInputText.cameras = cameras;
        add(emInputText);
        if (FlxG.save.data.doorsUsername != null)
            emInputText.label.text = FlxG.save.data.doorsUsername;

        diInputText = new UITextBox(271,179, '', 966);
        diInputText.cameras = cameras;
        add(diInputText);
        if (FlxG.save.data.doorsDisplayName != null)
            diInputText.label.text = FlxG.save.data.doorsDisplayName;

        utInputText = new UITextBox(271,254, '', 894);
        utInputText.passwordMode = true;
        utInputText.cameras = cameras;
        add(utInputText);
        if (FlxG.save.data.doorsPassword != null)
            utInputText.label.text = FlxG.save.data.doorsPassword;

        var registerButton = new DoorsButton(33, 388, Lang.getText("register", "newUI"), LARGE, NORMAL, function(){
            if(emInputText.label.text == "" ||
                diInputText.label.text == "" ||
                utInputText.label.text == ""
            ){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", Lang.getText("allFields", "glasshat")));
                return;
            }
            if(!~/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/.match(emInputText.label.text)){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", Lang.getText("invalidMail", "glasshat")));
                return;
            }
            if(!~/^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])([^\s]){8,32}$/.match(utInputText.label.text)){
                Main.popupManager.addPopup(new MessagePopup(5, "Glasshat Notification", Lang.getText("insecurePass", "glasshat")));
                return;
            }

            FlxG.save.data.doorsUsername = emInputText.label.text.toLowerCase();
            FlxG.save.data.doorsDisplayName = diInputText.label.text;
            FlxG.save.data.doorsPassword = utInputText.label.text;
            FlxG.save.flush();

            Glasshat.register();
        });
        registerButton.cameras = cameras;
        add(registerButton);

        var loginButton = new DoorsButton(33, 473, Lang.getText("login", "newUI"), LARGE, NORMAL, function(){
            FlxG.save.data.doorsUsername = emInputText.label.text;
            FlxG.save.data.doorsDisplayName = diInputText.label.text;
            FlxG.save.data.doorsPassword = utInputText.label.text;
            FlxG.save.flush();

            Glasshat.login();
        });
        loginButton.cameras = cameras;
        add(loginButton);

        var modifyButton = new DoorsButton(33, 558, Lang.getText("modifyAcc", "newUI"), LARGE, NORMAL, function(){
			CoolUtil.browserLoad('https://glasshat.fr/forgot-password');
        });
        modifyButton.cameras = cameras;
        add(modifyButton);

        seePassword = cast new StoryModeSpriteHoverable(1176, 247, "").makeGraphic(75, 45, FlxColor.TRANSPARENT);
        seePassword.cameras = cameras;
        add(seePassword);

		makeButtons(false);
        super.create();

        //codename new input
		FlxG.stage.window.onKeyDown.add(onKeyDown);
		FlxG.stage.window.onKeyUp.add(onKeyUp);
		FlxG.stage.window.onTextInput.add(onTextInput);
		FlxG.stage.window.onTextEdit.add(onTextEdit);
        //end codename
    }

    var isSeeingPassword:Bool = false;
    override function update(elapsed:Float)
    {
        if (controls.BACK && currentFocus == null) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
		}
        
        seePassword.checkOverlap(cameras[0]);
        if(seePassword.isHovered && FlxG.mouse.justPressed){
            utInputText.passwordMode = isSeeingPassword;
            utInputText.label.text = utInputText.label.text + ' ';
            utInputText.label.text = utInputText.label.text.rtrim();
            if(isSeeingPassword) paField.loadGraphic(Paths.image("ui/glasshat/passwordField"));
            else paField.loadGraphic(Paths.image("ui/glasshat/passwordFieldVisible"));
            isSeeingPassword = !isSeeingPassword;
        }
        
        //codename new input
		FlxG.mouse.getScreenPosition(FlxG.camera, __mousePos);

		super.update(elapsed);

		if (buttonHandler != null) {
			buttonHandler();
			buttonHandler = null;
		}

		if (FlxG.mouse.justReleased)
			currentFocus = (hoveredSprite is IUIFocusable) ? (cast hoveredSprite) : null;

		FlxG.sound.keysAllowed = currentFocus != null ? !(currentFocus is UITextBox) : true;

		if (hoveredSprite != null) {
			hoveredSprite = null;
		}
        //end codename
    }

	function makeButtons(?hideGlasshat:Bool = false){
		if(switchStateButtons != null) switchStateButtons.clear();
		else {
			switchStateButtons = new FlxTypedSpriteGroup<DoorsButton>(25, 644);
			add(switchStateButtons);
		}
		for(i in 0...options.length){
			if(hideGlasshat && options[i] == 'glasshat') continue;
			//separate each by 54px

			var buton:DoorsButton = new DoorsButton((i * 214), 0, visualOptions[i], OPTIONS, NORMAL, function(){
				openSelectedSubstate(options[i]);
			});
			if(options[i] == 'glasshat') {
				buton.state = PRESSED;
				buton.makeButton(visualOptions[i]);
			}
			switchStateButtons.add(buton);
		}
	}

    //codename new implementation pending

	private function onKeyDown(e:KeyCode, modifier:KeyModifier) {
		if (currentFocus != null)
			currentFocus.onKeyDown(e, modifier);
	}

	private function onKeyUp(e:KeyCode, modifier:KeyModifier) {
		if (currentFocus != null)
			currentFocus.onKeyUp(e, modifier);
	}

	private function onTextInput(str:String) {
		if (currentFocus != null)
			currentFocus.onTextInput(str);
	}
	private function onTextEdit(str:String, start:Int, end:Int) {
		if (currentFocus != null)
			currentFocus.onTextEdit(str, start, end);
	}

	public inline function updateSpriteRect(spr:UISprite) {
		spr.__rect.x = spr.x;
		spr.__rect.y = spr.y;
		spr.__rect.width = spr.width;
		spr.__rect.height = spr.height;
	}

	public function updateButtonHandler(spr:UISprite, buttonHandler:Void->Void) {
		spr.__rect.x = spr.x;
		spr.__rect.y = spr.y;
		spr.__rect.width = spr.width;
		spr.__rect.height = spr.height;
		updateRectButtonHandler(spr, spr.__rect, buttonHandler);
	}

	public function isOverlapping(spr:UISprite, rect:FlxRect) {
		for(camera in spr.__lastDrawCameras) {
			var pos = FlxG.mouse.getScreenPosition(camera, FlxPoint.get());
			__rect.x = rect.x;
			__rect.y = rect.y;
			__rect.width = rect.width;
			__rect.height = rect.height;

			__rect.x -= camera.scroll.x * spr.scrollFactor.x;
			__rect.y -= camera.scroll.y * spr.scrollFactor.y;

			if (((pos.x > __rect.x) && (pos.x < __rect.x + __rect.width)) && ((pos.y > __rect.y) && (pos.y < __rect.y + __rect.height))) {
				pos.put();
				return true;
			}
			pos.put();
		}
		return false;
	}

	public function updateRectButtonHandler(spr:UISprite, rect:FlxRect, buttonHandler:Void->Void) {
		if(isOverlapping(spr, rect)) {
			spr.hoveredByChild = true;
			this.hoveredSprite = spr;
			this.buttonHandler = buttonHandler;
		}
	}

	public override function destroy() {
		super.destroy();
		__mousePos.put();

		FlxG.stage.window.onKeyDown.remove(onKeyDown);
		FlxG.stage.window.onKeyUp.remove(onKeyUp);
		FlxG.stage.window.onTextInput.remove(onTextInput);
		FlxG.stage.window.onTextEdit.remove(onTextEdit);
	}
}