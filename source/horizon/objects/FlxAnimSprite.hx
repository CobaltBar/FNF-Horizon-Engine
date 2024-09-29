package horizon.objects;

class FlxAnimSprite extends FlxSprite
{
	public var offsets:Map<String, Array<Float>> = [];
	public var positions:Array<Float> = [];

	public function new(jsonPath:String, ?mods:Array<Mod>)
	{
		var json:AnimatedChracterData = Path.json(jsonPath, mods);

		positions.push(json.position[0] ?? 0);
		positions.push(json.position[1] ?? 0);

		super(json.position[0] ?? 0, json.position[1] ?? 0);

		var name = PathUtil.withoutDirectory(jsonPath);
		var atlas = Path.sparrow(name, mods);
		if (json.multi != null)
			for (multi in json.multi)
				atlas.addAtlas(Path.sparrow(multi, mods));
		frames = atlas;

		for (data in json.animData)
			if (data.indices != null)
				animation.addByIndices(data.name, data.prefix, data.indices, '', data.fps ?? 24, data.looped ?? false);
			else
				animation.addByPrefix(data.name, data.prefix, data.fps ?? 24, data.looped ?? false);

		antialiasing = json.antialiasing ?? Settings.antialiasing;
		flipX = json.flipX ?? false;
		if (json.scale != null)
			scale.set(json.scale, json.scale);

		updateHitbox();
	}

	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		if (offsets.exists(animName))
			offset.set(offsets[animName][0], offsets[animName][1]);
		else
			offset.set(0, 0);
	}
}
