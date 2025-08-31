package objects;

// Code by @Ne_Eo_Twitch
// Thanks Ne_Eo!

import flixel.ui.FlxBar;
import openfl.geom.ColorTransform;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxStringUtil;

using flixel.util.FlxColorTransformUtil;

class ColorBar extends FlxBar {
	public var backColorTransform(default, null):ColorTransform;
	public var frontColorTransform(default, null):ColorTransform;

	override function updateColorTransform():Void
	{
		if (colorTransform == null)
			colorTransform = new ColorTransform();

		backColorTransform = colorTransform;

		useColorTransform = alpha != 1 || color != 0xffffff;
		if (useColorTransform)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
		else
			colorTransform.setMultipliers(1, 1, 1, 1);

		dirty = true;
	}

	override function initVars():Void
	{
		super.initVars();

		backColorTransform = colorTransform;
		frontColorTransform = new ColorTransform();
	}

	override public function draw():Void
	{
        var old = _frontFrame.type;
        _frontFrame.type = FlxFrameType.EMPTY;

		super.draw();

        _frontFrame.type = old;

		if (!FlxG.renderTile)
			return;

		if (alpha == 0)
			return;

		if (percent > 0 && _frontFrame.type != FlxFrameType.EMPTY)
		{
			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
				{
					continue;
				}

				getScreenPosition(_point, camera).subtractPoint(offset);

				_frontFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, flipX, flipY);
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);

				// rotate matrix if sprite's graphic isn't prerotated
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}

				_point.add(origin.x, origin.y);
				if (isPixelPerfectRender(camera))
				{
					_point.floor();
				}

				_matrix.translate(_point.x, _point.y);
				camera.drawPixels(_frontFrame, _matrix, frontColorTransform, blend, antialiasing, shader);
			}
		}
	}

	public override function updateFilledBar():Void
	{
		_filledBarRect.width = barWidth;
		_filledBarRect.height = barHeight;

		var fraction:Float = (value - min) / range;
		var percent:Float = fraction * 100;
		var maxScale:Float = (_fillHorizontal) ? barWidth : barHeight;
		//var scaleInterval:Float = maxScale / numDivisions;
		var interval:Float = fraction * maxScale; // Math.round(Std.int(fraction * maxScale / scaleInterval) * scaleInterval);

		if (_fillHorizontal)
		{
			_filledBarRect.width = Std.int(interval);
		}
		else
		{
			_filledBarRect.height = Std.int(interval);
		}

		if (percent > 0)
		{
			switch (fillDirection)
			{
				case LEFT_TO_RIGHT, TOP_TO_BOTTOM:
				//	Already handled above

				case BOTTOM_TO_TOP:
					_filledBarRect.y = barHeight - _filledBarRect.height;
					_filledBarPoint.y = barHeight - _filledBarRect.height;

				case RIGHT_TO_LEFT:
					_filledBarRect.x = barWidth - _filledBarRect.width;
					_filledBarPoint.x = barWidth - _filledBarRect.width;

				case HORIZONTAL_INSIDE_OUT:
					_filledBarRect.x = Std.int((barWidth / 2) - (_filledBarRect.width / 2));
					_filledBarPoint.x = Std.int((barWidth / 2) - (_filledBarRect.width / 2));

				case HORIZONTAL_OUTSIDE_IN:
					_filledBarRect.width = Std.int(maxScale - interval);
					_filledBarPoint.x = Std.int((barWidth - _filledBarRect.width) / 2);

				case VERTICAL_INSIDE_OUT:
					_filledBarRect.y = Std.int((barHeight / 2) - (_filledBarRect.height / 2));
					_filledBarPoint.y = Std.int((barHeight / 2) - (_filledBarRect.height / 2));

				case VERTICAL_OUTSIDE_IN:
					_filledBarRect.height = Std.int(maxScale - interval);
					_filledBarPoint.y = Std.int((barHeight - _filledBarRect.height) / 2);
			}

			if (FlxG.renderBlit)
			{
				pixels.copyPixels(_filledBar, _filledBarRect, _filledBarPoint, null, null, true);
			}
			else
			{
				if (frontFrames != null)
				{
					_filledFlxRect.copyFromFlash(_filledBarRect);//.round();
					if (percent > 0)
					{
						_frontFrame = frontFrames.frame.clipTo(_filledFlxRect, _frontFrame);
					}
				}
			}
		}

		if (FlxG.renderBlit)
		{
			dirty = true;
		}
	}

	override function get_percent():Float
	{
		if (value > max)
		{
			return 100;
		}

		return ((value - min) / range) * 100;
	}
}
