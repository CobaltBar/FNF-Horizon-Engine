package modding;

class Song
{
	public var name:String;
	public var difficulties:Array<String>;
	public var icon:String;
	public var audioCombo:Int = 0; // 0: Inst 1: Inst+Voices 2:Inst+Voices_Player+Voices_Opponent
	public var score:Int = 0;
	public var accuracy:Float = 0;

	public function new(name:String, difficulties:Array<String>, icon:String, audioCombo:Int, score:Int, accuracy:Float)
	{
		this.name = name;
		this.difficulties = difficulties;
		this.icon = icon;
		this.audioCombo = audioCombo;
		this.score = score;
		this.accuracy = accuracy;
	}
}
