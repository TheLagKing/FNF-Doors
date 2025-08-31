package flixel.addons.api;

import openfl.net.URLRequestHeader;
import haxe.io.Bytes;
import haxe.crypto.padding.NoPadding;
import haxe.Json;
import flash.display.Loader;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import haxe.crypto.Aes;
import flixel.FlxG;
#if flash
import flash.Lib;
#end
#if GLASSHAT
import glasshatsec.Glasshat.GlasshatData;
#end

typedef RequestLoader =
{
	var _loader:URLLoader;
	var _callBack:Dynamic;
	var _returnJson:Dynamic;
	var _statusCode:Int;
}

/**
 * Similar to FlxGameJolt, this allows access to the Glasshat Online API.
 *
 * @author 	Leetram
 *
*/
class FlxGlasshat
{
	/**
	 * Trophy data return type, will return only non-unlocked trophies. As an alternative, can just pass in the ID of the trophy to see if it's unlocked.
	 */
	public static inline var TROPHIES_MISSING:Int = -1;

	/**
	 * Trophy data return type, will return only unlocked trophies. As an alternative, can just pass in the ID of the trophy to see if it's unlocked.
	 */
	public static inline var TROPHIES_ACHIEVED:Int = -2;

	/**
	 * Whether or not to log the URL that is contacted and messages returned from GameJolt.
	 * Useful if you're not getting the right data back.
	 * Only works in debug mode.
	 */
	public static var verbose:Bool = true;

	/**
	 * Whether or not the API has been fully initialized by passing game id, private key, and authenticating user name and token.
	 */
	public static var initialized(get, never):Bool;

	/**
	 * Internal method to verify that this user (and game) have been authenticated. Called before running functions which require authentication.
	 *
	 * @return 	True if authenticated, false otherwise.
	 */
	static var authenticated(get, never):Bool;

	/**
	 * The user's GameJolt user name. Only works if you've called authUser() and/or init(), otherwise will return "No user".
	 */
	public static var username(get, never):String;

	/**
	 * The user's GameJolt user token. Only works if you've called authUser() and/or init(), otherwise will return "No token".
	 * Generally you should not need to mess with this.
	 */
	public static var userPassword(get, never):String;

	/**
	 * Internal storage for this user's username.
	 */
	static var _userName:String;

	/**
	 * Internal storage for this user's password.
	 */
	static var _userPassword:String;

	/**
	 * Set to true once game ID, user name, user token have been set and user name and token have been verified.
	 */
	static var _initialized:Bool = false;

	/**
	 * The session cookie, used to keep authentication
	 */
	static var _sessionCookie:String = "";

	/**
	 * Internal tracker for authenticating user data.
	 */
	static var _verifyAuth:Bool = false;

	static var _loaders:Map<String, RequestLoader> = new Map<String, RequestLoader>();

	/**
	 * Various common strings required by the API's https values.
	 */
	static inline var URL_API:String = "https://glasshat.fr/api/v1/";

	/**
	 * Version for all requests
	 */
	static inline var REQUEST_VERSION:Float = 0.2;

	/**
	 * Initialize this class by storing the GameID and private key.
	 * You must call this function first for many of the other functions to work.
	 * To enable user-specific functions, call authUser() afterward, or set AutoAuth to true.
	 *
	 * @param 	username			The username to authenticate. 
	 * @param 	userPassword		The user password to authenticate.
	 * @param 	Callback 			An optional callback function. Will return true if authentication was successful, false otherwise.
	 */
	public static function init(username:String, userPassword:String, cb:Dynamic):Void
	{
		if (username != null && userPassword != null)
		{
			authUser(username, userPassword, cb);
		}
		else
		{
			cb(false);
		}
	}

	/**
	 * Fetch user data. Pass UserID to get user name, pass UserName to get UserID, or pass multiple UserIDs to get multiple usernames.
	 *
	 * @see 	https://gamejolt.com/api/doc/game/users/fetch/
	 * @param	UserID		An integer user ID value. If this is passed, UserName and UserIDs are ignored. Pass 0 to ignore.
	 * @param	UserName	A string user name. If this is passed, UserIDs is ignored. Pass "" or nothing to ignore. Usernames can only have letters, numbers, hyphens (-) and underscores (_), and must be 3-30 characters long.
	 * @param	UserIDs		An array of integers representing user IDs. Pass [] or nothing to ignore.
	 * @param	Callback	An optional callback function. Will return a Map<String:String> whose keys and values are equivalent to the key-value pairs returned by GameJolt.
	 */
	public static function fetchUser(
		?Callback:Dynamic, ?loaderGroup:String = "user"):Void
	{
		var tempURL:String = URL_API + "users";
		var data:Json = null;

		sendLoaderRequest(tempURL, Callback, loaderGroup, false, data);
	}

	/**
	 * Verify user data. 
	 * Must be called before any user-specific functions, and after init(). 
	 * Will set initialized to true if successful.
	 *
	 * @see 	https://gamejolt.com/api/doc/game/users/auth/
	 *
	 * @param	UserName	A user name. Leave null to automatically pull user data.
	 * Usernames can only have letters, numbers, hyphens (-) and underscores (_), and must be 3-30 characters long.
	 *
	 * @param	UserPassword	A user password. 
	 * Players enter this instead of a password to enable highscores, trophies, etc.
	 * User tokens can only have letters and numbers, and must be 4-30 characters long.
	 *
	 * @param	Callback	An optional callback function. 
	 * Will return true if authentication was successful, false otherwise.
	 */
	public static function registerUser(?userName:String, ?displayName:String, ?userPassword:String, ?Callback:Dynamic, ?loaderGroup:String = "default"):Void
	{
		_userName = userName;
		_userPassword = userPassword;

		// Only send initialization request to GameJolt if user name and token were found or passed.
		if (_userName != null && displayName != null && _userPassword != null)
		{
			_sessionCookie = "";
			sendLoaderRequest(URL_API + "authenticate/register", Callback, loaderGroup, true, {
				"version": REQUEST_VERSION,
				"email": _userName,
				"displayName": displayName,
				"password": _userPassword
			});
		}
		else
		{
			#if debug
			FlxG.log.warn("FlxGlasshat: Unable to access username or password, and no username or password was passed.");
			#end
		}
	}

	/**
	 * Verify user data. 
	 * Must be called before any user-specific functions, and after init(). 
	 * Will set initialized to true if successful.
	 *
	 * @see 	https://gamejolt.com/api/doc/game/users/auth/
	 *
	 * @param	UserName	A user name. Leave null to automatically pull user data.
	 * Usernames can only have letters, numbers, hyphens (-) and underscores (_), and must be 3-30 characters long.
	 *
	 * @param	UserPassword	A user password. 
	 * Players enter this instead of a password to enable highscores, trophies, etc.
	 * User tokens can only have letters and numbers, and must be 4-30 characters long.
	 *
	 * @param	Callback	An optional callback function. 
	 * Will return true if authentication was successful, false otherwise.
	 */
	public static function authUser(?userName:String, ?userPassword:String, ?Callback:Dynamic, ?loaderGroup:String = "default"):Void
	{
		_userName = userName;
		_userPassword = userPassword;

		// Only send initialization request to GameJolt if user name and token were found or passed.
		if (_userName != null && _userPassword != null)
		{
			_sessionCookie = "";
			sendLoaderRequest(URL_API + "authenticate/login", Callback, loaderGroup, true, {
				"version": REQUEST_VERSION,
				"email": _userName,
				"password": _userPassword
			});
		}
		else
		{
			#if debug
			FlxG.log.warn("FlxGlasshat: Unable to access username or password, and no username or password was passed.");
			#end
		}
	}
	
	/**
	 * Retrieve the high scores from this game's remote data. 
	 * If not authenticated, leaving Limit null will still return the top ten scores. Requires initialization.
	 *
	 * @see		https://gamejolt.com/api/doc/game/scores/fetch/
	 * @param	Limit		The maximum number of scores to retrieve. If blank to retrieve only this user's scores.
	 * @param 	TableID		The ID of the table you want to pull data from. Leave blank to fetch from the primary score table.
	 * @param	Callback	An optional callback function. Will return a Map<String:String> whose keys and values are equivalent to the key-value pairs returned by GameJolt.
	 */
	public static function fetchScore(
		?song:String = "demise", ?diff:String = "normal", ?limit:Int = 100, 
		?offset:Int = 0, ?Callback:Dynamic, ?loaderGroup:String = "score",
		?addUsernameToRequest:Bool = false):Void
	{
		var tempURL = URL_API + "scores/get";

		var data = {};
		if(addUsernameToRequest){
			data = {
				"version": REQUEST_VERSION,
				"username": FlxG.save.data.doorsUsername,
				"song": song,
				"diff": diff,
				"limit": limit,
				"offset": offset
			}
		} else {
			data = {
				"version": REQUEST_VERSION,
				"song": song,
				"diff": diff,
				"limit": limit,
				"offset": offset
			};
		}

		sendLoaderRequest(tempURL, Callback, loaderGroup, true, data);
	}

	/**
	 * Set a new high score, either globally or for this particular user. Requires game initialization.
	 * If user data is not authenticated, GuestName is required.
	 * Please note: On native platforms, having spaces in your Sort, GuestName, or ExtraData values will break this function.
	 *
	 * @see		https://gamejolt.com/api/doc/game/scores/add/
	 * @param	
	 * @param 	Callback 	An optional callback function. Will return a Map<String:String> whose keys and values are equivalent to the key-value pairs returned by GameJolt.
	 */
	public static function addScore(
		song:String, diff:String, chartHash:String, 
		score:Int, acc:Float, misses:Int, ?modifiers:Array<Int> = null,
		?Callback:Dynamic, ?loaderGroup:String = "score", ?isReplace:Bool = false):Void
	{
		var tempURL = URL_API + "scores/post";

		if(modifiers == null) modifiers = [];
		var timeStamp = Date.now().getTime() / 1000;

		var data = {
			"version": REQUEST_VERSION,
			"song": song,
			"diff": diff,
			"hash": chartHash,
			"score": score,
			"acc": acc,
			"misses": misses,
			"modifiers": modifiers,
			"timeStamp": timeStamp,
			"replace": isReplace
		};

		var aes:Aes = new Aes();

		#if GLASSHAT
		var chartAESPrivateKey = Bytes.ofString(GlasshatData.chartAESPrivateKey);
		var dataToEncrypt = Bytes.ofString(Json.stringify(data));
		var chartIV = Bytes.ofHex(GlasshatData.chartIV);
		aes.init(chartAESPrivateKey, chartIV);
		#else
		var dataToEncrypt = Bytes.ofString("");
		aes.init(Bytes.ofString(""), Bytes.ofString(""));
		#end

		var encryptedData = aes.encrypt(haxe.crypto.mode.Mode.CTR, dataToEncrypt, NoPadding).toHex();

		sendLoaderRequest(tempURL, Callback, loaderGroup, true, {"key": encryptedData});
	}

	/**
	 * A generic internal function to setup and send a URLRequest. All of the functions that interact with the API use this.
	 *
	 * @param	URLString	The URL to send to. Usually formatted as the API url, section of the API (e.g. "scores/") and then variables to pass (e.g. user name, trophy ID).
	 * @param	Callback	A function to call when loading is done and data is parsed.
	 * @param   loaderGroup The Loader Group that the request is connected to, only 1 request can happen at once in a group, use different groups for loading multiple url requests at the same time
	 */
	static function sendLoaderRequest(
		URLString:String, ?Callback:Dynamic, ?loaderGroup:String = "default", 
		?post:Bool = false, ?data:Dynamic = null):Void 
	{
		var request:URLRequest = new URLRequest(URLString);
		if(post){
			request.method = URLRequestMethod.POST;
			if(_sessionCookie != "") request.requestHeaders.push(new URLRequestHeader("Cookie", _sessionCookie));
		} else {
			request.method = URLRequestMethod.GET;
		}
		
		if(data != null){
			request.data = Json.stringify(data);
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
		}

		var _loaderGroup:RequestLoader = getLoaderGroup(loaderGroup);

		_loaderGroup._callBack = Callback;

		trace("FlxGlasshat: Contacting " + request.url);

		var parseData:Event->Void = null;
		parseData = function(e:Event) {
			_loaderGroup._loader.removeEventListener(Event.COMPLETE, parseData);

			if (Std.string((cast e.currentTarget).data) == "") {
				#if debug
				FlxG.log.warn("FlxGlasshat received no data back. This is probably because one of the values it was passed is wrong.");
				#end
				return;
			}
			_loaderGroup._statusCode = (cast e.currentTarget.__httpRequest).responseStatus; 
			for (header in ((cast e.currentTarget.__httpRequest).responseHeaders : Array<URLRequestHeader>)){
				if(header.name == "Set-Cookie"){
					_sessionCookie = header.value;
				}
			}
			var rawJson = Std.string((cast e.currentTarget).data);
			var theJson = cast Json.parse(rawJson);
			_loaderGroup._returnJson = theJson;

			if (_loaderGroup._callBack != null && _loaderGroup._returnJson != null && !_verifyAuth) {
				_loaderGroup._callBack(_loaderGroup._returnJson);
			}
			else if (_verifyAuth) {
				verifyAuthentication(_loaderGroup);
			}
		}

		_loaderGroup._loader.addEventListener(Event.COMPLETE, parseData);
		_loaderGroup._loader.load(request);
	}

	/**
	 * Internal function to evaluate whether or not a user was successfully authenticated and store the result in _initialized. If authentication failed, the tentative user name and password are nulled.
	 *
	 * @param	ReturnMap	The data received back from Glasshat. This should be {"success"="true"} if authenticated, or {"success"="false"} otherwise.
	 */
	static function verifyAuthentication(_loaderGroup:RequestLoader):Void
	{
		if (_loaderGroup._statusCode == 200)
		{
			_initialized = true;
		}
		else
		{
			_initialized = false;
			_userName = null;
			_userPassword = null;
		}

		_verifyAuth = false;

		if (_loaderGroup._callBack != null)
			_loaderGroup._callBack(_initialized);
	}

	/**
	 * Function to authenticate a new user, to be used when a user has already been authenticated but you'd like to authenticate a new one.
	 * If you just try to run authUser after a user has been authenticated, it will fail.
	 *
	 * @param	UserName	The user's name.
	 * @param	UserToken	The user's token.
	 * @param	Callback	An optional callback function. Will return true if authentication was successful, false otherwise.
	 */
	public static function resetUser(userName:String, userPassword:String, ?Callback:Dynamic):Void
	{
		_userName = userName;
		_userPassword = userPassword;

		_verifyAuth = true;
		sendLoaderRequest(URL_API + "authenticate/login", Callback, true, {
			"version": REQUEST_VERSION,
			"username": _userName,
			"password": _userPassword
		});
	}

	static function getLoaderGroup(loaderGroup:String)
	{
		if (!_loaders.exists(loaderGroup))
		{
			var _loaderGroup = {_loader: new URLLoader(), _callBack: null, _returnJson: {}, _statusCode: 100};
			_loaders.set(loaderGroup, _loaderGroup);
		}
		return _loaders.get(loaderGroup);
	}

	static function get_initialized():Bool
	{
		return _initialized;
	}

	static function get_authenticated():Bool
	{
		if (!_initialized)
		{
			#if debug
			FlxG.log.warn("FlxGameJolt: You must authenticate user before you can do this.");
			#end
			return false;
		}

		return true;
	}

	static function get_username():String
	{
		if (!_initialized || _userName == null || _userName == "")
		{
			return "No user";
		}

		return _userName;
	}

	static function get_userPassword():String
	{
		if (!_initialized || _userPassword == null || _userPassword == "")
		{
			return "No password";
		}

		return _userPassword;
	}
}