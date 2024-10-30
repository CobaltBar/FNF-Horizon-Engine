package horizon.objects.game;

@:publicFields
class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var length:Float;
	public var mult:Float;
	public var type:String;

	public function resetNote(json:NoteJSON)
	{
		data = json.data ?? 2;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		alpha = 1;
	}
}
