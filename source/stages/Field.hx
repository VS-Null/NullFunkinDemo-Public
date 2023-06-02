package stages;

class Field extends BaseStage
{
	override function create()
	{
		super.create();

		var nullbg:BGSprite = new BGSprite('stages/null/nullbg', 200, 100, 0.9, 0.9);
		nullbg.setGraphicSize(Std.int(nullbg.width * 1.5));
		add(nullbg);

		// this just has less of a chance to screw up then json
		// and also because I don't wanna have to do a million things from a json file to modify this, cuz lazy
		game.opponentCameraOffset = [350, 0];
	}
}
