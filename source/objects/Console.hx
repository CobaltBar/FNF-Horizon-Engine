package objects;

import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.containers.dialogs.Dialog;
import hscript.Expr.Error;
import hscript.Interp;
import hscript.Parser;

@:xml('
<dialog title="Console" width="800" height="450">
    <scrollview width="100%" height="100%" contentWidth="100%">
        <label id="output" text="" width="100%"/>
    </scrollview>
</dialog>')
class Console extends Dialog
{
	public var shouldDestroy:Bool = false;

	var parser:Parser;
	var interp:Interp;

	var input:TextArea;

	public function new()
	{
		super();
		destroyOnClose = modal = autoCenterDialog = centerDialog = false;
		dialogTitleLabel.fontSize = 18;
		output.fontSize = 12;
		input = new TextArea();
		input.placeholder = "Enter Command...";
		input.setSize(700, 48);
		input.customStyle.fontSize = 12;
		input.invalidateComponentStyle();
		var button = new Button();
		button.setSize(72, 48);
		button.text = "Run";
		button.fontSize = 18;
		addFooterComponent(input);
		addFooterComponent(button);
		button.onClick = event -> run(input.text.trim());
		parser = new Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp = new Interp();
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxBasic", FlxBasic);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("Log", Log);
		interp.variables.set("Create", Create);
	}

	function run(text:String):Void
	{
		if (text.startsWith('run '))
		{
			try
			{
				var result = interp.execute(parser.parseString(text.substring(3, text.length)));
				if (result == null)
					output.text += 'Executed.\n';
				else
					output.text += '$result\n';
			}
			catch (e:Error)
			{
				output.text += '${e.toString()}\n';
			}
		}
		input.text = "";
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (input.focus)
		{
			if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get('accept')[1]]) && !hidden)
				run(input.text.trim());
			Main.inputEnabled = false;
		}
		else
			Main.inputEnabled = true;
	}

	private override function onReady()
	{
		super.onReady();
		centerDialogComponent(this);
	}

	override function destroy()
	{
		if (shouldDestroy)
			super.destroy();
	}
}
