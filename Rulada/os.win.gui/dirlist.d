private import os.win.gui.all;

import std.file, os.win.gui.base;


class DirList: os.win.gui.form.Form
{
	// Do not modify or move this block of variables.
	//~Entice Designer variables begin here.
	os.win.gui.label.Label dirName;
	os.win.gui.treeview.TreeView dirView;
	//~Entice Designer variables end here.
	
	
	this()
	{
		initializeDirList();
		
		dirName.click ~= &dirName_click;
	}
	
	
	private void dirName_click(Object sender, EventArgs ea)
	{
		auto fbd = new FolderBrowserDialog;
		fbd.description = "Select a directory to list";
		char[] s = dirName.text;
		if(s.length && s[0] != '<')
			fbd.selectedPath = s;
		if(DialogResult.OK == fbd.showDialog(this))
		{
			dirName.text = "Loading...";
			dirName.enabled = false; // Disable changing the dir while it's loading one.
			dirView.beginUpdate();
			scope(exit)
			{
				dirName.enabled = true;
				dirView.endUpdate();
			}
			s = fbd.selectedPath;
			dirView.nodes.clear();
			int i = 0;
			listdir(s,
				(char[] fn)
				{
					if(++i == 10)
					{
						i = 0;
						Application.doEvents(); // Don't lock up the window.
					}
					dirView.nodes.add(fn);
					return true; // continue
				});
			dirName.text = s; // Note: the label might cut off some of the path.
		}
	}
	
	
	private void initializeDirList()
	{
		// Do not manually edit this block of code.
		//~Entice Designer 0.8 code begins here.
		//~DFL Form
		text = "Dir List";
		clientSize = os.win.gui.drawing.Size(492, 466);
		//~DFL os.win.gui.label.Label=dirName
		dirName = new os.win.gui.label.Label();
		dirName.name = "dirName";
		dirName.dock = os.win.gui.control.DockStyle.TOP;
		dirName.font = new os.win.gui.drawing.Font("Courier New", 9f, os.win.gui.drawing.FontStyle.REGULAR);
		dirName.text = "<Click here>";
		dirName.borderStyle = os.win.gui.base.BorderStyle.FIXED_3D;
		dirName.textAlign = os.win.gui.base.ContentAlignment.MIDDLE_LEFT;
		dirName.bounds = Rect(0, 0, 492, 23);
		dirName.parent = this;
		//~DFL os.win.gui.treeview.TreeView=dirView
		dirView = new os.win.gui.treeview.TreeView();
		dirView.name = "dirView";
		dirView.backColor = os.win.gui.drawing.SystemColors.control;
		dirView.dock = os.win.gui.control.DockStyle.FILL;
		dirView.borderStyle = os.win.gui.base.BorderStyle.NONE;
		dirView.bounds = Rect(0, 23, 492, 443);
		dirView.parent = this;
		//~Entice Designer 0.8 code ends here.
	}
}


int main()
{
	int result = 0;
	
	try
	{
		Application.enableVisualStyles();
		
		Application.run(new DirList());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

