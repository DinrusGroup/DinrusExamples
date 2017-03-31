private import os.win.gui.all, os.win.gui.base;


class DflScroller: os.win.gui.form.Form
{
	// Do not modify or move this block of variables.
	//~Entice Designer variables begin here.
	os.win.gui.label.Label topLabel;
	os.win.gui.label.Label bottomLabel;
	//~Entice Designer variables end here.
	
	
	this()
	{
		initializeDflScroller();
		
		scrollSize = Size(bottomLabel.right, bottomLabel.bottom);
		vScroll = true;
		hScroll = true;
	}
	
	
	private void initializeDflScroller()
	{
		// Do not manually edit this block of code.
		//~Entice Designer 0.8.1 code begins here.
		//~DFL Form
		text = "DFL Scroller";
		clientSize = os.win.gui.drawing.Size(292, 266);
		//~DFL os.win.gui.label.Label=topLabel
		topLabel = new os.win.gui.label.Label();
		topLabel.name = "topLabel";
		topLabel.backColor = os.win.gui.drawing.Color(0, 193, 97);
		topLabel.font = new os.win.gui.drawing.Font("Courier New", 14f, os.win.gui.drawing.FontStyle.BOLD);
		topLabel.foreColor = os.win.gui.drawing.Color(0, 0, 0);
		topLabel.text = "Top";
		topLabel.bounds = Rect(8, 8, 124, 71);
		topLabel.parent = this;
		//~DFL os.win.gui.label.Label=bottomLabel
		bottomLabel = new os.win.gui.label.Label();
		bottomLabel.name = "bottomLabel";
		bottomLabel.backColor = os.win.gui.drawing.Color(23, 138, 232);
		bottomLabel.font = new os.win.gui.drawing.Font("Tahoma", 14f, os.win.gui.drawing.FontStyle.BOLD);
		bottomLabel.foreColor = os.win.gui.drawing.Color(255, 255, 255);
		bottomLabel.text = "Bottom";
		bottomLabel.textAlign = os.win.gui.base.ContentAlignment.BOTTOM_RIGHT;
		bottomLabel.bounds = Rect(8, 352, 220, 31);
		bottomLabel.parent = this;
		//~Entice Designer 0.8.1 code ends here.
	}
}


int main()
{
	int result = 0;
	
	try
	{
		// Application initialization code here.
		
		Application.run(new DflScroller());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

