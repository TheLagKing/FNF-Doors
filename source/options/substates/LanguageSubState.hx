package options.substates;

import flixel.group.FlxGroup;
import objects.ui.DoorsOption.DoorsOptionType;
import objects.ui.DoorsOption.CommonDoorsOption;

using StringTools;

class LanguageSubState extends BaseOptionsMenu
{
	private var translationText:FlxText;
	
	public function new(?firstOpen:Bool = false)
	{
		internalTitle = "language";
		title = 'Language';
		rpcTitle = 'Language Menu'; //for Discord Rich Presence

		var option:CommonDoorsOption = {
			name: "language",
			description: "language",
			variable: "displayLanguage",
			type: DoorsOptionType.STRING,
			stringOptions: [
				"English",
				"Français",
				"Zhōngwén",
				"Čeština",
				"Polski",
				"Português",
				"Русский",
				"Español",
				"Türkçe",
				"Tiếng Việt",
				"한국어",
				"Română",
				"Български"
			],
			onChange: onChangeLang
		};
		addOption(option);

		var option:CommonDoorsOption = {
			name: "helpOut",
			description: "helpOut",
			type: DoorsOptionType.BUTTON,
			onChange: function(){
				CoolUtil.browserLoad("https://forms.gle/mp6xXtZHKdUoDkAcA");
			}
		};
		addOption(option);

		super(firstOpen);

		var bottomField:FlxSprite = new FlxSprite(24, 381).loadGraphic(Paths.image("ui/glasshat/infoField"));
		bottomField.antialiasing = ClientPrefs.globalAntialiasing;
		add(bottomField);

		translationText = new FlxText(24, 399, 1232, "", 36);
		translationText.setFormat(FONT, 36, 0xFFFEDEBF, CENTER, OUTLINE, 0xFF452D25);
		translationText.antialiasing = ClientPrefs.globalAntialiasing;
		add(translationText);
		
		updateTranslationText();
	}

	function updateTranslationText() {
		var translationData:Dynamic = null;
		try {
			var rawJson:String = sys.io.File.getContent("assets/lang/translationData.json");
			translationData = haxe.Json.parse(rawJson);
		} catch (e) {
			trace('Error loading translation data: ${e.toString()}');
			translationData = {};
		}

		var currentLocale:String = Lang.getLocaleNameFromDisplay(ClientPrefs.data.displayLanguage).toLowerCase();
		var currentProgress:Float = 0;
		var proofReadProgress:Float = 0;

		if (translationData != null && Reflect.hasField(translationData, currentLocale)) {
			var langData = Reflect.field(translationData, currentLocale);
			currentProgress = Reflect.hasField(langData, "advancement") ? Reflect.field(langData, "advancement") : 0;
			proofReadProgress = Reflect.hasField(langData, "proofRead") ? Reflect.field(langData, "proofRead") : 0;
		}

		var progressPercent:Int = Math.round(currentProgress * 100);
		var proofReadPercent:Int = Math.round(proofReadProgress * 100);

		var translationString:String = 'The translation ${ClientPrefs.data.displayLanguage} is:\n${progressPercent}% Finished\n${proofReadPercent}% Proofread\nYou can help by clicking the button above.';
		
		translationText.text = translationString;
	}

	function onChangeLang(){
		Lang.loadTransFromXml(Lang.getLocaleNameFromDisplay(ClientPrefs.data.displayLanguage));
		this.forEach(function(spr:Any){
			recursiveGoThroughGroup(spr);
		});
		_parentState.forEach(function(spr:Any){
			recursiveGoThroughGroup(spr);
		});
		
		// Update translation text with new language data
		updateTranslationText();
	}

	private function recursiveGoThroughGroup(thing:Any) {
		if(thing is FlxText){
			(thing:FlxText).applyTranslation();
		} else {
			try{
				(thing:Dynamic).forEach(function(newthing:Any){
					recursiveGoThroughGroup(newthing);
				});
			} catch(e){}
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}