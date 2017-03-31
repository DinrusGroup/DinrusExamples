// To compile:
// 	dfl rctest rctest.res -gui


import os.win.gui.all, os.win.gui.base;


class ResourceTest: os.win.gui.form.Form
{
	// Do not modify or move this block of variables.
	//~Entice Designer variables begin here.
	os.win.gui.picturebox.PictureBox pictureBox1;
	os.win.gui.picturebox.PictureBox pictureBox2;
	os.win.gui.label.Label label1;
	//~Entice Designer variables end here.
	
	
	this()
	{
		initializeResourceTest();
		
		pictureBox1.image = Application.resources.getIcon(101);
		pictureBox2.image = Application.resources.getBitmap("mspaint");
		label1.text = Application.resources.getString(3001);
	}
	
	
	private void initializeResourceTest()
	{
		// Do not manually edit this block of code.
		//~Entice Designer 0.7.2 code begins here.
		//~DFL Form
		text = "Resource Test";
		clientSize = os.win.gui.drawing.Size(296, 452);
		//~DFL os.win.gui.picturebox.PictureBox=pictureBox1
		pictureBox1 = new os.win.gui.picturebox.PictureBox();
		pictureBox1.name = "pictureBox1";
		pictureBox1.bounds = Rect(24, 16, 256, 128);
		pictureBox1.parent = this;
		//~DFL os.win.gui.picturebox.PictureBox=pictureBox2
		pictureBox2 = new os.win.gui.picturebox.PictureBox();
		pictureBox2.name = "pictureBox2";
		pictureBox2.bounds = Rect(24, 168, 256, 128);
		pictureBox2.parent = this;
		//~DFL os.win.gui.label.Label=label1
		label1 = new os.win.gui.label.Label();
		label1.name = "label1";
		label1.bounds = Rect(16, 312, 260, 128);
		label1.parent = this;
		//~Entice Designer 0.7.2 code ends here.
	}
}


int main()
{
	int result = 0;
	
	try
	{
		// Application initialization code here.
		
		Application.run(new ResourceTest());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

