package;

import ClientPrefs;

class Rating
{
	public var name:String = '';
	public var image:String = '';
	public var hitWindow:Null<Int> = 0; //ms
	public var ratingMod:Float = 1;
	public var score:Int = 320;
	public var noteSplash:Bool = true;
	public var hits:Int = 0;
    public var hitBonusValue:Int = 32;
    public var hitBonus:Int = 2;
    public var hitPunishment:Int = 0;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.hitWindow = 0;

		var window:String = name + 'Window';
		try
		{
			this.hitWindow = Reflect.field(ClientPrefs.data, window);
		}
		catch(e) FlxG.log.error(e);
	}

	public static function loadDefault():Array<Rating>
	{
		var ratingsData:Array<Rating> = [new Rating('perfect')]; //highest rating goes first

		var rating:Rating = new Rating('sick');
		rating.ratingMod = 1.0;
		rating.score = 300;
		rating.noteSplash = true;
        rating.hitBonusValue = 32;
        rating.hitBonus = 1;
        rating.hitPunishment = 0;
        
		ratingsData.push(rating);

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.67;
		rating.score = 200;
		rating.noteSplash = false;
        rating.hitBonusValue = 16;
        rating.hitBonus = 0;
        rating.hitPunishment = 8;

		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.34;
		rating.score = 100;
		rating.noteSplash = false;
        rating.hitBonusValue = 8;
        rating.hitBonus = 0;
        rating.hitPunishment = 24;

		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
        rating.hitBonusValue = 4;
        rating.hitBonus = 0;
        rating.hitPunishment = 44;
		ratingsData.push(rating);

		return ratingsData;
	}
}