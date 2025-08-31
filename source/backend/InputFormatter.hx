package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String {
		var toReturn:String = "";
		switch (key) {
			case BACKSPACE:
				toReturn =  "BckSpc";
			case CONTROL:
				toReturn =  "Ctrl";
			case ALT:
				toReturn =  "Alt";
			case CAPSLOCK:
				toReturn =  "Caps";
			case PAGEUP:
				toReturn =  "PgUp";
			case PAGEDOWN:
				toReturn =  "PgDown";
			case ZERO:
				toReturn =  "0";
			case ONE:
				toReturn =  "1";
			case TWO:
				toReturn =  "2";
			case THREE:
				toReturn =  "3";
			case FOUR:
				toReturn =  "4";
			case FIVE:
				toReturn =  "5";
			case SIX:
				toReturn =  "6";
			case SEVEN:
				toReturn =  "7";
			case EIGHT:
				toReturn =  "8";
			case NINE:
				toReturn =  "9";
			case NUMPADZERO:
				toReturn =  "#0";
			case NUMPADONE:
				toReturn =  "#1";
			case NUMPADTWO:
				toReturn =  "#2";
			case NUMPADTHREE:
				toReturn =  "#3";
			case NUMPADFOUR:
				toReturn =  "#4";
			case NUMPADFIVE:
				toReturn =  "#5";
			case NUMPADSIX:
				toReturn =  "#6";
			case NUMPADSEVEN:
				toReturn =  "#7";
			case NUMPADEIGHT:
				toReturn =  "#8";
			case NUMPADNINE:
				toReturn =  "#9";
			case NUMPADMULTIPLY:
				toReturn =  "#*";
			case NUMPADPLUS:
				toReturn =  "#+";
			case NUMPADMINUS:
				toReturn =  "#-";
			case NUMPADPERIOD:
				toReturn =  "#.";
			case SEMICOLON:
				toReturn =  ";";
			case COMMA:
				toReturn =  ",";
			case PERIOD:
				toReturn =  ".";
			//case SLASH:
			//	toReturn =  "/";
			case GRAVEACCENT:
				toReturn =  "`";
			case LBRACKET:
				toReturn =  "[";
			//case BACKSLASH:
			//	toReturn =  "\\";
			case RBRACKET:
				toReturn =  "]";
			case QUOTE:
				toReturn =  "'";
			case PRINTSCREEN:
				toReturn =  "PrtScrn";
			case NONE:
				toReturn =  '---';
			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') {
					toReturn =  '---';
					return toReturn;
				}

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				toReturn =  arr.join(' ');
		}

		return toReturn;
	}
}