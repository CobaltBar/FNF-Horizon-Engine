package objects;

class Note extends NoteSprite
{
	public var data:Int = 0;
	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String;
	public var mult:Float = 1;

	public function resetNote(?json:NoteJson):Void
	{
		data = json?.data ?? 0;
		time = json?.time ?? 0;
		length = json?.length ?? 0;
		type = json?.type;
		mult = json?.mult ?? 1;
	}
}
