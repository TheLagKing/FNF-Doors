package backend.system;

import openfl.Lib;
import backend.system.NativeAPI;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;

/**
 * A custom crash handler that displays a message box.
 */
class CrashHandler {
  public static function initialize() {
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
    #if cpp
    untyped __global__.__hxcpp_set_critical_error_handler(onError);
    #end
  }

  public static function onUncaughtError(e:UncaughtErrorEvent) {
    var m:String = e.error;
    if (Std.isOfType(e.error, Error)) {
      var err = cast(e.error, Error);
      m = '${err.message}';
    } else if (Std.isOfType(e.error, ErrorEvent)) {
      var err = cast(e.error, ErrorEvent);
      m = '${err.text}';
    }
    var stack = CallStack.exceptionStack();
    var stackLabel:String = "";
    for(e in stack) {
      switch(e) {
        case CFunction: stackLabel += "Non-Haxe (C) Function";
        case Module(c): stackLabel += 'Module ${c}';
        case FilePos(parent, file, line, col):
          switch(parent) {
            case Method(cla, func):
              stackLabel += '(${file}) ${cla.split(".")[cla.split(".").length-1]}.$func() - line $line';
            case _:
              stackLabel += '(${file}) - line $line';
          }
        case LocalFunction(v):
          stackLabel += 'Local Function ${v}';
        case Method(cl, m):
          stackLabel += '${cl} - ${m}';
      }
      stackLabel += "\r\n";
    }
    
    stackLabel += "\n\nPlease report this in the community discord!\nMake sure to include a screenshot of this screen, and detail exactly what you were doing prior to the crash.";

    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();

    NativeAPI.showMessageBox("Doors Engine Crash Handler", 'Uncaught Error : $m\n\n$stackLabel', MSG_ERROR);
    #if sys
    Sys.exit(1);
    #end
  }
  
  #if cpp
  private static function onError(message:Dynamic):Void
  {
    throw Std.string(message);
  }
  #end

  public static function queryStatus():Void
  {
    @:privateAccess
    var currentStatus = Lib.current.stage.__uncaughtErrorEvents.__enabled;
    trace('ERROR HANDLER STATUS: ' + currentStatus);

    #if openfl_enable_handle_error
    trace('Define: openfl_enable_handle_error is enabled');
    #else
    trace('Define: openfl_enable_handle_error is disabled');
    #end

    #if openfl_disable_handle_error
    trace('Define: openfl_disable_handle_error is enabled');
    #else
    trace('Define: openfl_disable_handle_error is disabled');
    #end
  }

  public static function induceBasicCrash():Void
  {
    throw "This is an example of an uncaught exception.";
  }

  public static function induceNullObjectReference():Void
  {
    var obj:Dynamic = null;
    var value = obj.test;
  }

  public static function induceNullObjectReference2():Void
  {
    var obj:Dynamic = null;
    var value = obj.test();
  }

  public static function induceNullObjectReference3():Void
  {
    var obj:Dynamic = null;
    var value = obj();
  }
}