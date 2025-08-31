// Fix From: https://github.com/HaxeFlixel/flixel/pull/2656
// Hi Neo, thanks for this lol
package flixel.text;

import flixel.text.FlxText;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxRange;
import openfl.Assets;

// TODO: think about filters and text

/**
 * Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate
 * though. Also does nice pixel-perfect centering on pixel fonts as long as they are only one-liners.
 */
class FlxTextNew extends FlxText
{
	public var translationID:String = "";

	static inline var VERTICAL_GUTTER:Int = 4;

	override function set_text(Text:String):String {
		var specificKey:Null<String> = null;
		if(Text.startsWith("|:|")){
			specificKey = Text.substring(3, Text.lastIndexOf("|:|"));
		}

		var splittedText = Text.substring(Text.lastIndexOf("|:|")).replace("|:|", "").split("/");
		final errors:Array<String> = [
			"Bad Path!","Bad Translation!","Bad Modifier!","Bad Item!","Bad Option!","Bad Award!"
		];

		var last = splittedText[splittedText.length-1];
		splittedText.pop();
		if(!errors.contains(Lang.getText(last, splittedText.join("/"), specificKey))){
				translationID = Text;
				Text = Lang.getText(last, splittedText.join("/"), specificKey);
		} else text = Text;

		if (textField != null)
		{
			var ot:String = textField.text;
			textField.text = Text;
			_regen = (textField.text != ot) || _regen;
		}
		return Text;
	}

	override public function new(?x:Float = 0, ?y:Float = 0, ?fw:Float = 0, ?txt:String, 
		?siz:Int = 8, ?fh:Float = 0, ?color:FlxColor = 0xFFFFFFFF){
		
		var specificKey:Null<String> = null;
		if(txt.startsWith("|:|")){
			specificKey = txt.substring(3, txt.lastIndexOf("|:|"));
		}

		var splittedText = txt.substring(txt.lastIndexOf("|:|")).replace("|:|", "").split("/");
		final errors:Array<String> = [
			"Bad Path!","Bad Translation!","Bad Modifier!","Bad Item!","Bad Option!","Bad Award!"
		];

		var last = splittedText[splittedText.length-1];
		splittedText.pop();

		translationID = txt;
		if(!errors.contains(Lang.getText(last, splittedText.join("/"), specificKey))){
				txt = Lang.getText(last, splittedText.join("/"), specificKey);
		}
		
		super(x, y, fw, txt, siz, true);
		setFormat(Constants.FONT, siz, color);
		antialiasing = ClientPrefs.globalAntialiasing;
		if(fh != 0) fieldHeight = fh;
	}

	public function applyTranslation() {
		var specificKey:Null<String> = null;
		if(translationID.startsWith("|:|")){
			specificKey = translationID.substring(3, translationID.lastIndexOf("|:|"));
		}
		var splittedText = translationID.substring(translationID.lastIndexOf("|:|")).replace("|:|", "").split("/");
		final errors:Array<String> = [
			"Bad Path!","Bad Translation!","Bad Modifier!","Bad Item!","Bad Option!","Bad Award!"
		];

		var last = splittedText[splittedText.length-1];
		splittedText.pop();
		if(!errors.contains(Lang.getText(last, splittedText.join("/"), specificKey))){
			text = Lang.getText(last, splittedText.join("/"), specificKey);
		} else text = translationID;

		setFormat(Constants.FONT, this.size, this.color);
	}

	override function regenGraphic():Void
	{
		if (textField == null || !_regen)
			return;

		var oldWidth:Int = 0;
		var oldHeight:Int = VERTICAL_GUTTER;

		if (graphic != null)
		{
			oldWidth = graphic.width;
			oldHeight = graphic.height;
		}

		var newWidth:Int = Math.ceil(textField.width);
		var textfieldHeight = _autoHeight ? textField.textHeight : textField.height;
		var vertGutter = _autoHeight ? VERTICAL_GUTTER : 0;
		// Account for gutter
		var newHeight:Int = Math.ceil(textfieldHeight) + vertGutter;

		// prevent text height from shrinking on flash if text == ""
		if (textField.textHeight == 0)
		{
			newHeight = oldHeight;
		}

		if (oldWidth != newWidth || oldHeight != newHeight)
		{
			// Need to generate a new buffer to store the text graphic
			height = newHeight;
			var key:String = FlxG.bitmap.getUniqueKey("text");
			makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, false, key);

			if (_hasBorderAlpha)
				_borderPixels = graphic.bitmap.clone();
			
			if (_autoHeight)
				textField.height = newHeight;

			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = newWidth;
			_flashRect.height = newHeight;
		}
		else // Else just clear the old buffer before redrawing the text
		{
			graphic.bitmap.fillRect(_flashRect, FlxColor.TRANSPARENT);
			if (_hasBorderAlpha)
			{
				if (_borderPixels == null)
					_borderPixels = new BitmapData(frameWidth, frameHeight, true);
				else
					_borderPixels.fillRect(_flashRect, FlxColor.TRANSPARENT);
			}
		}

		if (textField != null && textField.text != null && textField.text.length > 0)
		{
			// Now that we've cleared a buffer, we need to actually render the text to it
			copyTextFormat(_defaultFormat, _formatAdjusted);

			_matrix.identity();

			applyBorderStyle();
			applyBorderTransparency();
			applyFormats(_formatAdjusted, false);

			drawTextFieldTo(graphic.bitmap);
		}

		_regen = false;
		resetFrame();
	}
}