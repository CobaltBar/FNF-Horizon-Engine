package objects;

class Alphabet extends FlxSpriteGroup
{
	var align(default, set):FlxTextAlign;

	static final letters = ~/^[a-zA-Z]+$/;

	public var option:Dynamic;

	public function new(x:Float, y:Float, text:String, bold:Bool, align:FlxTextAlign, scale:Float = 1, offsetX:Float = 0, offsetY:Float = 0)
	{
		super(x + offsetX, y - offsetY);
		var chars = text.split('');
		var letterWidth:Float = 0;
		for (ch in chars)
		{
			var name = ch;
			var char = Create.sparrow(0, 0, Path.sparrow('alphabet'), scale);
			switch (name)
			{
				case '\r' | '\n':
					continue;
				case ' ':
					letterWidth += 30 * scale;
					continue;
				case '\'' | '“' | '”' | '*':
					char.y -= char.height * .5;
				case '-':
					char.y -= char.height * .25;
				case '"':
					name = 'quote';
					char.y -= char.height * .5;
				case '?':
					name = 'question';
			}
			if (bold)
				name += ' bold';
			else if (letters.match(ch))
				name += name.toLowerCase() != name ? ' uppercase' : ' lowercase';
			else
				name += ' normal';
			name = name.toLowerCase();
			char.animation.addByPrefix('idle', name, 24);
			char.animation.play('idle');
			char.updateHitbox();
			char.centerOffsets();
			char.x = letterWidth;
			char.y -= char.height;
			letterWidth += char.width;
			add(char);
		}

		this.align = align;
	}

	@:noCompletion function set_align(val:FlxTextAlign):FlxTextAlign
	{
		updateHitbox();
		switch (val)
		{
			case LEFT | JUSTIFY:
				offset.x = 0;
			case CENTER:
				offset.x = width * .5;
			case RIGHT:
				offset.x = width;
		}
		return align = val;
	}

	public override function setColorTransform(redMultiplier = 1.0, greenMultiplier = 1.0, blueMultiplier = 1.0, alphaMultiplier = 1.0, redOffset = 0.0,
			greenOffset = 0.0, blueOffset = 0.0, alphaOffset = 0.0):Void
	{
		for (member in members)
			member.setColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
	}
}
