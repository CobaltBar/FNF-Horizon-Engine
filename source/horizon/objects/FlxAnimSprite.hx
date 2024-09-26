package horizon.objects;

class FlxAnimSprite extends FlxSprite
{
	public var offsets:Map<String, Array<Float>> = [];

	public function new(jsonPath:String)
	{
		var json:AnimatedChracterData = Path.json(jsonPath);

		super(json.position[0] ?? 0, json.position[1] ?? 0);

		var name = PathUtil.withoutDirectory(jsonPath);
		var atlas = Path.sparrow(name);
		for (multi in json.multi)
			atlas.addAtlas(Path.sparrow(multi));
		frames = atlas;
		antialiasing = json.antialiasing;
		flipX = json.flipX;
		scale.set(json.scale, json.scale);

		for (data in json.animData)
			if (data.indices != null)
				animation.addByIndices(data.name, data.prefix, data.indices, '', data.fps ?? 24, data.looped ?? false);
			else
				animation.addByPrefix(data.name, data.prefix, data.fps ?? 24, data.looped ?? false);

		updateHitbox();
	}

	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		if (offsets.exists(animName))
			offset.set(offsets[animName][0], offsets[animName][1]);
	}
}
