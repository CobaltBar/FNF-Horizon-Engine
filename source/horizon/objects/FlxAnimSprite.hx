package horizon.objects;

class FlxAnimSprite extends FlxSprite
{
	public var offsets:Map<String, Array<Float>> = [];

	public function new(x:Float, y:Float, jsonPath:String, ?mods:Array<Mod>, ?json:GenericAnimatedSprite)
	{
		json ??= Path.json(jsonPath, mods);
		super(x, y);
		var name = PathUtil.withoutDirectory(jsonPath);
		var atlas = Path.atlas(name, mods);
		if (json.multi != null)
			for (multi in json.multi)
				atlas.addAtlas(Path.atlas(multi, mods));
		frames = atlas;

		for (data in json.animData)
		{
			if (data.indices != null)
				animation.addByIndices(data.name, data.prefix, data.indices, '', data.fps ?? 24, data.looped ?? false);
			else
				animation.addByPrefix(data.name, data.prefix, data.fps ?? 24, data.looped ?? false);

			if (data.offsets != null)
				offsets.set(data.name, data.offsets);
		}

		antialiasing = json.antialiasing ?? Settings.antialiasing;
		flipX = json.flipX ?? false;
		if (json.scale != null)
			scale.set(json.scale, json.scale);

		updateHitbox();
		centerOffsets();
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		if (offsets.exists(animName))
			offset.set(offsets[animName][0], offsets[animName][1]);
		else
			centerOffsets();
	}
}
