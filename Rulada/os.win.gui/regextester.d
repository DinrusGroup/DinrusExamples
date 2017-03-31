// Donated to DFL by lsina/ideage 2007-03-14

/*
	RegexTester  by ideage lsina@126.com 2007
*/

private import os.win.gui.all;
import std.regexp;
import std.string;
import std.math, os.win.gui.base;

class RegexTester: os.win.gui.form.Form
{
	// Do not modify or move this block of variables.
	//~Entice Designer variables begin here.
	os.win.gui.textbox.TextBox txRegex;
	os.win.gui.textbox.TextBox txReplace;
	os.win.gui.label.Label label1;
	os.win.gui.label.Label label2;
	os.win.gui.textbox.TextBox txSource;
	os.win.gui.textbox.TextBox txMatches;
	os.win.gui.label.Label label3;
	os.win.gui.label.Label label4;
	os.win.gui.button.Button btisMatch;
	os.win.gui.button.Button btClear;
	os.win.gui.button.Button btReplace;
	os.win.gui.button.Button btSplit;
	os.win.gui.button.Button btMatches;
	os.win.gui.button.Button btGroup;
	os.win.gui.button.CheckBox cbIC;
	os.win.gui.button.CheckBox cbSL;
	os.win.gui.button.CheckBox cbGM;
	os.win.gui.button.Button button1;
	//~Entice Designer variables end here.
	std.regexp.RegExp mregexp;

	this()
	{
		initializeRegexTester();

		// Other RegexTester initialization code here.
	}

	private void initializeRegexTester()
	{
		// Do not manually edit this block of code.
		//~Entice Designer 0.8.1 code begins here.
		//~DFL Form
		text = "D Language Phobos.std.Regex Tester";
		clientSize = os.win.gui.drawing.Size(632, 462);
		//~DFL os.win.gui.textbox.TextBox=txRegex
		txRegex = new os.win.gui.textbox.TextBox();
		txRegex.name = "txRegex";
		txRegex.multiline = true;
		txRegex.bounds = Rect(8, 16, 616, 64);
		txRegex.parent = this;
		//~DFL os.win.gui.textbox.TextBox=txReplace
		txReplace = new os.win.gui.textbox.TextBox();
		txReplace.name = "txReplace";
		txReplace.multiline = true;
		txReplace.bounds = Rect(8, 224, 616, 56);
		txReplace.parent = this;
		//~DFL os.win.gui.label.Label=label1
		label1 = new os.win.gui.label.Label();
		label1.name = "label1";
		label1.text = "Replace";
		label1.bounds = Rect(10, 208, 120, 16);
		label1.parent = this;
		//~DFL os.win.gui.label.Label=label2
		label2 = new os.win.gui.label.Label();
		label2.name = "label2";
		label2.text = "Regex";
		label2.bounds = Rect(9, 0, 120, 16);
		label2.parent = this;
		//~DFL os.win.gui.textbox.TextBox=txSource
		txSource = new os.win.gui.textbox.TextBox();
		txSource.name = "txSource";
		txSource.multiline = true;
		txSource.bounds = Rect(8, 136, 616, 64);
		txSource.parent = this;
		//~DFL os.win.gui.textbox.TextBox=txMatches
		txMatches = new os.win.gui.textbox.TextBox();
		txMatches.name = "txMatches";
		txMatches.multiline = true;
		txMatches.bounds = Rect(8, 306, 616, 112);
		txMatches.parent = this;
		//~DFL os.win.gui.label.Label=label3
		label3 = new os.win.gui.label.Label();
		label3.name = "label3";
		label3.text = "Source";
		label3.bounds = Rect(10, 118, 88, 16);
		label3.parent = this;
		//~DFL os.win.gui.label.Label=label4
		label4 = new os.win.gui.label.Label();
		label4.name = "label4";
		label4.text = "Matches";
		label4.bounds = Rect(8, 285, 96, 24);
		label4.parent = this;
		//~DFL os.win.gui.button.Button=btisMatch
		btisMatch = new os.win.gui.button.Button();
		btisMatch.name = "btisMatch";
		btisMatch.text = "isMatch";
		btisMatch.bounds = Rect(8, 424, 88, 24);
		btisMatch.parent = this;
		//~DFL os.win.gui.button.Button=btClear
		btClear = new os.win.gui.button.Button();
		btClear.name = "btClear";
		btClear.text = "Clear";
		btClear.bounds = Rect(448, 424, 88, 24);
		btClear.parent = this;
		//~DFL os.win.gui.button.Button=btReplace
		btReplace = new os.win.gui.button.Button();
		btReplace.name = "btReplace";
		btReplace.text = "Replace";
		btReplace.bounds = Rect(96, 424, 88, 24);
		btReplace.parent = this;
		//~DFL os.win.gui.button.Button=btSplit
		btSplit = new os.win.gui.button.Button();
		btSplit.name = "btSplit";
		btSplit.text = "Split";
		btSplit.bounds = Rect(184, 424, 88, 24);
		btSplit.parent = this;
		//~DFL os.win.gui.button.Button=btMatches
		btMatches = new os.win.gui.button.Button();
		btMatches.name = "btMatches";
		btMatches.text = "Matches";
		btMatches.bounds = Rect(272, 424, 88, 24);
		btMatches.parent = this;
		//~DFL os.win.gui.button.Button=btGroup
		btGroup = new os.win.gui.button.Button();
		btGroup.name = "btGroup";
		btGroup.text = "Groups";
		btGroup.bounds = Rect(360, 424, 88, 24);
		btGroup.parent = this;
		//~DFL os.win.gui.button.CheckBox=cbIC
		cbIC = new os.win.gui.button.CheckBox();
		cbIC.name = "cbIC";
		cbIC.text = "IgnoreCase";
		cbIC.bounds = Rect(16, 88, 104, 16);
		cbIC.parent = this;
		//~DFL os.win.gui.button.CheckBox=cbSL
		cbSL = new os.win.gui.button.CheckBox();
		cbSL.name = "cbSL";
		cbSL.text = "SingleLine";
		cbSL.bounds = Rect(128, 88, 72, 16);
		cbSL.parent = this;
		//~DFL os.win.gui.button.CheckBox=cbGM
		cbGM = new os.win.gui.button.CheckBox();
		cbGM.name = "cbGM";
		cbGM.text = "Global Match";
		cbGM.bounds = Rect(224, 88, 96, 16);
		cbGM.parent = this;
		//~DFL os.win.gui.button.Button=button1
		button1 = new os.win.gui.button.Button();
		button1.name = "button1";
		button1.text = "Close";
		button1.bounds = Rect(536, 424, 88, 24);
		button1.parent = this;
		//~Entice Designer 0.8.1 code ends here.
		btisMatch.click ~= &btisMatch_click ;
		btClear.click ~= &btClear_click ;
		btReplace.click ~= &btReplace_click ;
		btSplit.click ~= &btSplit_click ;
		btMatches.click ~= &btMatches_click ;
		button1.click ~= &button1_click;
		cbSL.checked = true;
	}

	char[] regAttribute()
	{
		char[] attrib ="";
		if(cbGM.checked) attrib ~="g";
		if(cbSL.checked) attrib ~="m";
		if(cbIC.checked) attrib ~="i";
		return attrib;
	}

	private void btisMatch_click(Object sender, EventArgs ea)
	{
		char[] sur = strip(txRegex.text);
		RegExp r =  new RegExp(sur,regAttribute());
		if( cast(bool)r.test(strip(txSource.text)))
			txMatches.text="Match!!";
		else
			txMatches.text="NOT FOUND!!";
	}

	private void btReplace_click(Object sender, EventArgs ea)
	{
    char[] sur = strip(txRegex.text);
		RegExp r =  new RegExp(sur,regAttribute());
		this.txMatches.text =r.replace(txSource.text,txReplace.text);
	}

	private void btSplit_click(Object sender, EventArgs ea)
	{
		char[] sur = strip(txRegex.text);
		RegExp r =  new RegExp(sur,regAttribute());
		char[][] s = r.split(txSource.text);
		char[] a="";
		foreach(v ; s)
		{
			a ~= v;
			a ~= std.string.newline ;
		}
		this.txMatches.text  = a;
	}

	private void btGroups_click(Object sender, EventArgs ea)
	{
		//char[] sub(char[] string, char[] pattern, char[] format, char[] attributes = null);
		txMatches.text = sub(txSource.text ,txRegex.text ,txReplace.text ,regAttribute() );

	}
	private void btMatches_click(Object sender, EventArgs ea)
	{
		char[] sur = strip(txRegex.text);
		RegExp r =  new RegExp(sur,regAttribute());
		char[][] s = r.match(txSource.text);
		char[] a="";
		foreach(v ; s)
		{
			a ~= v;
			a ~= std.string.newline ;
		}
		this.txMatches.text  = a;
	}

	private void btClear_click(Object sender, EventArgs ea)
	{
		txRegex.text ="";
		txSource.text = "";
		txReplace.text =\u4e00;
		txMatches.text =\u9fa5;
	}
	private void button1_click(Object sender, EventArgs ea)
	{
		Application.exitThread();
	}

}

int main()
{
	int result = 0;

	try
	{
		Application.enableVisualStyles();
		Application.run(new RegexTester());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);

		result = 1;
	}

	return result;
}

