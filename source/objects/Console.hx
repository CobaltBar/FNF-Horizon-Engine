package objects;

import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.containers.dialogs.Dialog;

@:xml('
<dialog title="Console" width="1024" height="576" destroyOnClose="false">
    <scrollview width="100%" height="100%" contentWidth="100%">
        <label id="output" text="" width="100%"/>
    </scrollview>
</dialog>')
class Console extends Dialog
{
	@:noCompletion public var actuallyVisible:Bool = false;

	public function new()
	{
		super();
		closable = false;
		dialogTitleLabel.fontSize = 18;
		var input = new TextField();
		input.placeholder = "Enter Command...";
		input.width = 512;
		var button = new Button();
		button.text = "Run";
		addFooterComponent(input);
		addFooterComponent(button);
	}

	public override function show()
	{
		super.show();
		actuallyVisible = true;
	}

	public override function hide()
	{
		super.hide();
		actuallyVisible = false;
	}
}

class ConsoleManager extends FlxBasic
{
	var console:Console;

	public function new()
	{
		super();
		console = new Console();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.debug)
		{
			console.actuallyVisible ? console.hide() : console.showDialog(false);
		}
	}
}
