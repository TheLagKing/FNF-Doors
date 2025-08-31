#if !macro
import Paths;
import Rating;

import states.*;
import substates.*;
import substates.story.*;
import objects.*;
import backend.*;

import backend.storymode.StoryRoom;
import backend.storymode.StoryRoom.*;
import backend.storymode.DoorsRun;
import backend.storymode.DoorsRun.*;

import ModifierManager;

#if GAMEJOLT
import flixel.system.FlxBaseLoader;
#end

#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.openfl.*;
import objects.DoorsVideoSprite;
#end

//Flixel
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxTextNew as FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import Constants.*;

using StringTools;
#end
