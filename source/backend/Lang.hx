package backend;

import haxe.xml.Access;
import sys.io.File;
import sys.FileSystem;
using StringTools;

/**
 * Error types for translation operations
 */
enum abstract TRANS_ERRORS(String) {
    var BAD_PATH = "Bad Path!";
    var BAD_TRANS = "Bad Translation!";
    var BAD_MODIFIER = "Bad Modifier!";
    var BAD_ITEM = "Bad Item!";
    var BAD_OPTION = "Bad Option!";
    var BAD_AWARD = "Bad Award!";
}

/**
 * Handles language localization and translations
 */
class Lang {
    // Current language code (e.g., "en", "zh-cn")
    public static var curLang:String;
    // XML containing all translations
    public static var theTranslationXML:Xml;
    
    /**
     * Sets the appropriate font based on language
     * @param language The language code
     */
    public static function getFontFromTrans(language:String) {
        switch(language) {
            case "zh" | "vi":
                Constants.FONT = "noto-chinese.ttf";
                Constants.MEDIUM_FONT = "noto-chinese-medium.ttf";
            case "ko":
                Constants.FONT = "NotoSansKR-Regular.ttf";
                Constants.MEDIUM_FONT = "NotoSansKR-Medium.ttf";
            default:
                Constants.FONT = "Oswald.ttf";
                Constants.MEDIUM_FONT = "Oswald-Medium.ttf";
        }
    }

    /**
     * Converts display language name to locale code
     * @param displayName The display name of the language
     * @return The corresponding locale code
     */
    public static function getLocaleNameFromDisplay(displayName:String) {
        return switch(displayName) {
            case "English": "en";
            case "Français": "fr"; 
            case "Español": "es";
            case "Čeština": "cs";
            case "Polski": "pl";
            case "Português": "pt";
            case "Русский": "ru";
            case "Türkçe": "tr";
            case "Tiếng Việt": "vi";
            case "Zhōngwén": "zh";
            case "한국어": "ko";
            case "Română": "ro";
            case "Български": "bg";
            default: "en";
        }
    }

    /**
     * Initializes the language system
     */
    public static function start() {
        var language = 
            (ClientPrefs.data.displayLanguage != null) 
            ? getLocaleNameFromDisplay(ClientPrefs.data.displayLanguage) 
            : "en";
            
        loadTransFromXml(language);
    }

    /**
     * Loads translations from XML file
     * @param language The language code to load
     * @return Whether loading was successful
     */
    public static function loadTransFromXml(language:String) {
        curLang = language;
        FlxG.save.data.language = language;
        FlxG.save.flush();

        getFontFromTrans(language);

        var path = 'assets/lang/${language}.xml';
        if (FileSystem.exists(path)) {
            try {
                var rawXml:String = File.getContent(path);
                theTranslationXML = Xml.parse(rawXml);
                return true;
            } catch (err) {
                trace(err);
                if (language != "en") {
                    loadTransFromXml("en"); // Fallback to English
                }
                return false;
            }
        } else {
            if (language != "en") {
                loadTransFromXml("en"); // Fallback to English
            }
            return false;
        }
    }

    /**
     * Gets unescaped text for a key
     * @param key The translation key
     * @param subPath Optional path to the translation
     */
    public static function getUnescapedText(key:String, ?subPath:Null<String>) {
        return getText(key, subPath);
    }
    
    /**
     * Gets translated text for a key
     * @param key The translation key
     * @param subPath Optional path to the translation
     * @param specificAttr Optional specific attribute to retrieve
     * @return The translated text or error message
     */
    public static function getText(key:String, ?subPath:Null<String>, ?specificAttr:Null<String>):Dynamic {
        // Navigate to the requested section in the XML
        try{
            var fastAccess:Access = new Access(theTranslationXML.firstElement());
            
            if (subPath != null) {
                var pathsToTake = subPath.split("/");
                for (sub in pathsToTake) {
                    if (fastAccess.hasNode.resolve(sub)) {
                        fastAccess = fastAccess.node.resolve(sub);
                    } else {
                        return TRANS_ERRORS.BAD_PATH;
                    }
                }
            }
            
            // Handle special case for retrieving multiple items
            if (key == "SPECIAL_ANY") {
                var arrToReturn:Array<String> = [];
                for (node in fastAccess.nodes.resolve(key)) {
                    var i = 0;
                    while (node.att.resolve('_${i}') != null) {
                        arrToReturn.push(correctFormat(node.att.resolve('_${i}')));
                        i++;
                    }
                }
                return arrToReturn;
            } 

            // Standard case - return single translation
            else {
                for (node in fastAccess.nodes.resolve(key)) {
                    var attr = specificAttr != null ? node.att.resolve(specificAttr) : node.att.value;
                    return correctFormat(attr);
                }
            }
        } catch(e) {
            return TRANS_ERRORS.BAD_TRANS;
        }

        return TRANS_ERRORS.BAD_TRANS;
    }

    /**
     * Gets text for a modifier
     * @param key The modifier key
     * @return Array containing name and value
     */
    public static function getModifierText(key:String):Dynamic {
        return [getText(key, "modifiers", "name"), getText(key, "modifiers", "value")];
    }

    /**
     * Gets text for an option
     * @param key The option key
     * @param category The option category
     * @return Array containing name and description
     */
    public static function getOptionText(key:String, category:String):Dynamic {
        return [getText(key, 'options/${category}', "name"), getText(key, 'options/${category}', "desc")];
    }

    /**
     * Gets text for a specific option
     * @param key The option key
     * @param category The option category
     * @return The option text
     */
    public inline static function getSpecificOptionText(key:String, category:String):Dynamic {
        return getText("SPECIAL_ANY", 'options/${category}/specificOptions/${key}', "value");
    }

    /**
     * Gets text for an achievement
     * @param key The achievement key
     * @return Array containing name and description
     */
    public static function getAwardText(key:String):Dynamic {
        try {
            return [
                getText(key, 'achievements', "name"), 
                getText(key, 'achievements', "desc")
            ];
        } catch(e) {
            return TRANS_ERRORS.BAD_AWARD;
        }
    }

    /**
     * Gets text for an item
     * @param type The item type
     * @return Array containing name, description, and plural flag
     */
    public static function getItemText(type:String):Dynamic {
        return [
            getText(type, 'items', "name"),
            getText(type, 'items', "desc"),
            (getText(type, 'items', "plural") == "T")
        ];
    }

    /**
     * Formats a string by replacing escape sequences
     * @param value The string to format
     * @return The formatted string
     */
    private static inline function correctFormat(value:String):String {
        return value.replace("\\n", "\n").replace("\\t", "\t").replace("\\\\", "\\");
    }
}
