// This code is public domain.

// To compile:
// 	dfl beginner -gui


private import std.string;

private import os.win.gui.all;


class MainForm: Form
{
	GroupBox myGroup;
	RadioButton likeDfl, okDfl, hateDfl, whatDfl;
	TextBox myTextBox;
	Button voteBtn;
	
	
	this()
	{
		// Initialize some of this Form's properties.
		width = 220;
		startPosition = FormStartPosition.CENTER_SCREEN;
		formBorderStyle = FormBorderStyle.FIXED_DIALOG; // Don't allow resize.
		maximizeBox = false;
		text = "Пример Начинания в DFL"; // Form's caption text.
		
		// Add a GroupBox.
		with(myGroup = new GroupBox)
		{
			bounds = Rect(4, 4, this.clientSize.width - 8, 120); // Set the x, y, width, and height.
			text = "DFL &Голосуй"; // Text displayed at the top of the box.
			parent = this; // Set myGroup's parent to this Form.
		}
		
		// Add some RadioButton`s to the GroupBox myGroup..
		
		with(likeDfl = new RadioButton)
		{
			bounds = Rect(6, 18, 160, 13); // x, y, width and height within the GroupBox.
			text = "DFL нравится"; // Text displayed next to the selector thing.
			checked = true; // Check this one, but not the others.
			parent = myGroup; // Set likeDfl's parent to the GroupBox.
		}
		
		with(okDfl = new RadioButton)
		{
			bounds = Rect(6, likeDfl.bottom + 4, 160, 13); // 4px below likeDfl.
			text = "DFL пойдет";
			//checked = false; // false is default. Set one to true per group.
			parent = myGroup;
		}
		
		with(hateDfl = new RadioButton)
		{
			bounds = Rect(6, okDfl.bottom + 4, 160, 13);
			text = "Ненавижу DFL!";
			parent = myGroup;
		}
		
		with(whatDfl = new RadioButton)
		{
			bounds = Rect(6, hateDfl.bottom + 4, 160, 13);
			text = "Что такое DFL?";
			parent = myGroup;
		}
		
		// Update myGroup's height to fit all the RadioButtons.
		// The client size is the area inside the control, excluding the border.
		myGroup.clientSize = Size(myGroup.clientSize.width, whatDfl.bottom + 6);
		
		// Add a Label for the following TextBox.
		Label myLabel;
		with(myLabel = new Label)
		{
			bounds = Rect(4, myGroup.bottom + 4, 200, 13); // 4px below myGroup.
			myLabel.text = "&Мнения (одно на строку):";
			parent = this;
		}
		
		// Add a TextBox below the GroupBox.
		with(myTextBox = new TextBox)
		{
			bounds = Rect(4, myLabel.bottom + 4, this.clientSize.width - 8, 100); // 4px below Label.
			multiline = true;
			acceptsReturn = true;
			parent = this;
		}
		
		// Add a button and a click event handler.
		with(voteBtn = new Button)
		{
			location = Point(this.clientSize.width - voteBtn.width - 4, myTextBox.bottom + 4); // width/height are default.
			text = "&Голосуй";
			parent = this;
			
			click ~= &this.voteBtn_click;
		}
		
		// Set the Form's "accept button", or default button.
		acceptButton = voteBtn;
		
		// Update the Form's height to fit all the controls.
		// The client size is the area inside the Form, excluding the border and caption.
		clientSize = Size(clientSize.width, voteBtn.bottom + 4);
	}
	
	
	// Click handler for voteBtn.
	private void voteBtn_click(Object sender, EventArgs ea)
	{
		char[] s;
		char[][] comments;
		RadioButton voteOption;
		
		// Gather comments.
		comments = myTextBox.lines;
		if(!comments.length)
		{
			if(DialogResult.YES != msgBox("Вы уверены, что не хотите высказать мнение о DFL?",
				"Мнения о DFL", MsgBoxButtons.YES_NO, MsgBoxIcon.QUESTION))
			{
				// They're not sure, they want to stop the vote and add a comment..
				return; // Abort.
			}
		}
		
		// See which option they voted for.
		if(likeDfl.checked)
			voteOption = likeDfl;
		else if(okDfl.checked)
			voteOption = okDfl;
		else if(hateDfl.checked)
			voteOption = hateDfl;
		else if(whatDfl.checked)
			voteOption = whatDfl;
		else
			assert(0);
		
		s = "Вы высказались, что \"" ~ voteOption.text ~ "\".\r\n\r\n";
		if(comments.length)
		{
			s ~= "Ваше высказывание:";
			foreach(int i, char[] comment; comments)
			{
				s ~= "\r\n   " ~ std.string.toString(i + 1) ~ ") " ~ comment;
			}
		}
		else
		{
			s ~= "Вы не оставили комментариев.";
		}
		
		msgBox(s, "Спасибо за Мнение!", MsgBoxButtons.OK, MsgBoxIcon.INFORMATION);
		
		// Now reset everything.
		voteOption.checked = false;
		likeDfl.checked = true;
		myTextBox.text = "";
	}
}

int AppRun(){
int result = 0;
	
	try
	{
	//Application.autoCollect = false;
		Application.run(new MainForm);
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

void main()
{
	AppRun();	
}

