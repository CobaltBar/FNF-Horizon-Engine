package objects;

// PsychEngine's CheckboxThingie.hx with minor edits
class Checkbox extends FlxAttachedSprite
{
	public var checked(default, set):Bool = false;

	public function new(x:Float = 0, y:Float = 0, startChecked:Bool = false)
	{
		super(x, y);

		frames = Path.sparrow('checkbox');
		animation.addByPrefix('unchecked', 'checkbox0', 24, false);
		animation.addByPrefix('unchecking', 'checkbox anim reverse', 24, false);
		animation.addByPrefix('checking', 'checkbox anim0', 24, false);
		animation.addByPrefix('checked', 'checkbox finish', 24, false);

		setGraphicSize(Std.int(0.9 * width));
		updateHitbox();

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		checked = startChecked;
	}

	@:noCompletion function set_checked(val:Bool):Bool
	{
		if (val)
		{
			if (animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking')
			{
				animation.play('checking', true);
				offset.set(34, 25);
			}
		}
		else if (animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking')
		{
			animation.play("unchecking", true);
			offset.set(25, 28);
		}
		return checked = val;
	}

	private function animationFinished(name:String)
	{
		switch (name)
		{
			case 'checking':
				animation.play('checked', true);
				offset.set(3, 12);

			case 'unchecking':
				animation.play('unchecked', true);
				offset.set(0, 2);
		}
	}
}
