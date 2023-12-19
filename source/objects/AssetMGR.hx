package objects;

class AssetMGR
{
	public static var images:Map<String, String> = [
		"menuBG" => "assets/images/menuBG.png",
		"menuBGBlue" => "assets/images/menuBGBlue.png",
		"menuBGMagenta" => "assets/images/menuBGMagenta.png",
		"menuBGDesat" => "assets/images/menuBGDesat",
		"newgrounds_logo" => "assets/images/title/newgrounds_logo.png"
	];
	public static var animatedImages:Map<String, Array<String>> = [
		"alphabet" => ["assets/images/alphabet.png", "assets/images/alphabet.xml"],
		"gfDanceTitle" => ["assets/images/title/gfDanceTitle.png", "assets/images/title/gfDanceTitle.xml"],
		"logoBumpin" => ["assets/images/title/logoBumpin.png", "assets/images/title/logoBumpin.xml"],
		"titleEnter" => ["assets/images/title/titleEnter.png", "assets/images/title/titleEnter.xml"],
		"story_mode" => ["assets/images/mainMenu/story_mode.png", "assets/images/mainMenu/story_mode.xml"],
		"freeplay" => ["assets/images/mainMenu/freeplay.png", "assets/images/mainMenu/freeplay.xml"],
		"mods" => ["assets/images/mainMenu/mods.png", "assets/images/mainMenu/mods.xml"],
		"awards" => ["assets/images/mainMenu/awards.png", "assets/images/mainMenu/awards.xml"],
		"credits" => ["assets/images/mainMenu/credits.png", "assets/images/mainMenu/credits.xml"],
		"donate" => ["assets/images/mainMenu/donate.png", "assets/images/mainMenu/donate.xml"],
		"options" => ["assets/images/mainMenu/options.png", "assets/images/mainMenu/options.xml"],
	];
	public static var sounds:Map<String, String> = [
		"Scroll" => "assets/sounds/Scroll.ogg",
		"Confirm" => "assets/sounds/Confirm.ogg",
		"Cancel" => "assets/sounds/Cancel.ogg",
	];
	public static var menuSong:String = "assets/songs/menuSong.ogg";
}
