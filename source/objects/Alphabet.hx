package objects;

class Alphabet
{
	public static function generateText(x:Float, y:Float, text:String, bold:Bool, alignment:Alignment, ?scale:Float, ?yOffset:Float):FlxSpriteGroup
	{
		var group:FlxSpriteGroup = new FlxSpriteGroup();
		var chars:Array<String> = text.split("");
		var letterWidth:Float = 0;
		for (i in 0...chars.length)
		{
			var animName:String = chars[i];
			var spr = Util.createSparrowSprite(x, y - (yOffset ?? 0), "assets/images/alphabet");
			spr.scale.set(spr.scale.x * (scale ?? 1), spr.scale.y * (scale ?? 1));
			spr.centerOrigin();
			if (animName == " ")
			{
				letterWidth += 35 * (scale ?? 1);
				continue;
			}
			else if (animName == "&")
				animName = "ampersand";
			else if (animName == ".")
				animName = "bullet";
			else if (animName == "'")
			{
				animName = "apostrophe";
				spr.y -= spr.height / 2;
			}
			else if (animName == "\\")
				animName = "back slash";
			else if (animName == "!")
				animName = "exclamation";
			else if (animName == "/")
				animName = "forward slash";
			else if (animName == "¡")
				animName = "inverted exclamation";
			else if (animName == "¿")
				animName = "inverted question";
			else if (animName == '"')
				animName = "quote";
			else if (animName == "“")
				animName = "start quote";
			else if (animName == "”")
				animName = "end quote";
			if (bold)
				animName += " bold";
			else if (animName.toLowerCase() != animName)
				animName += " uppercase";
			else if (animName.toLowerCase() == animName)
				animName += " lowercase";
			else
				animName += " normal";
			animName = animName.toLowerCase();
			spr.animation.addByPrefix("idle", animName, 24, true);
			spr.animation.play("idle");
			spr.updateHitbox();
			spr.centerOffsets();
			spr.x = x + (letterWidth + 15);
			spr.y -= spr.height;
			letterWidth += spr.width;
			group.add(spr);
		}
		switch (alignment)
		{
			case Left:
			case Center:
				group.x -= group.width / 2;
			case Right:
				group.x -= group.width;
		}
		return group;
	}
}

enum Alignment
{
	Left;
	Center;
	Right;
}
