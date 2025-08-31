package states.mechanics.modifiers;

class SweetTooth extends MechanicsManager
{
    public function new()
    {
        super();
    }

    override function noteMissEarly(direction:Int, note:Note = null)
    {
        var healthShitYeah:Float = game.combo*0.01;
        game.health -= (Math.min(DoorsUtil.maxHealth*0.9, healthShitYeah) * PlayState.healthLoss);
    }
}