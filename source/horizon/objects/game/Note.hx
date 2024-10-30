package horizon.objects.game;

@:publicFields
class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var holdLength:Float;
	public var mult:Float;
	public var type:String;

	public function new(json:NoteJSON)
	{
		data = json.data ?? 2;
		time = json.time ?? 0;
		noteLength = json.length ?? 0;
		mult = json.mult ?? 1;
	}
}
