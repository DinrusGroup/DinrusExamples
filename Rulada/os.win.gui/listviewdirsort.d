// To compile:
// 	dfl -gui listviewdirsort

/*
	Generated by Entice Designer
	Entice Designer written by Christopher E. Miller
	www.dprogramming.com/entice.php
*/

private import os.win.gui.all;


import std.conv, std.file, os.win.gui.base;


class ListViewDirSort: os.win.gui.form.Form
{
	// Do not modify or move this block of variables.
	//~Entice Designer variables begin here.
	os.win.gui.listview.ListView dirlist;
	//~Entice Designer variables end here.
	
	
	this()
	{
		initializeListViewDirSort();
		
		dirlist.sorter = &filenamesorter;
		
		dirlist.columnClick ~= &dirlist_columnClick;
		
		ColumnHeader ch;
		
		ch = new ColumnHeader();
		ch.text = "Name";
		ch.width = 200;
		dirlist.columns.add(ch);
		
		ch = new ColumnHeader();
		ch.text = "Size";
		ch.width = 60;
		dirlist.columns.add(ch);
		
		listdir(".",
			(DirEntry* de)
			{
				char[] s = de.name;
				if(s.length >= 2 && s[0 .. 2] == ".\\")
					s = s[2 .. s.length];
				dirlist.addRow(s, std.string.toString(de.size));
				return true; // Continue.
			});
	}
	
	
	private void dirlist_columnClick(ListView sender, ColumnClickEventArgs ea)
	{
		switch(ea.column)
		{
			case 0: // File name.
				dirlist.sorter = &filenamesorter;
				break;
			
			case 1: // File size.
				dirlist.sorter = &filesizesorter;
				break;
			
			default:
				assert(0);
		}
	}
	
	
	private int filenamesorter(ListViewItem a, ListViewItem b)
	{
		return a.opCmp(b);
	}
	
	
	private int filesizesorter(ListViewItem a, ListViewItem b)
	{
		return std.conv.toInt(a.subItems[0].toString()) - std.conv.toInt(b.subItems[0].toString());
	}
	
	
	private void initializeListViewDirSort()
	{
		// Do not manually modify this function.
		//~Entice Designer 0.8.2.1 code begins here.
		//~DFL Form
		text = "Current Directory";
		clientSize = os.win.gui.drawing.Size(292, 273);
		//~DFL os.win.gui.listview.ListView=dirlist
		dirlist = new os.win.gui.listview.ListView();
		dirlist.name = "dirlist";
		dirlist.dock = os.win.gui.control.DockStyle.FILL;
		dirlist.view = os.win.gui.base.View.DETAILS;
		dirlist.bounds = Rect(0, 0, 292, 273);
		dirlist.parent = this;
		//~Entice Designer 0.8.2.1 code ends here.
	}
}


int main()
{
	int result = 0;
	
	try
	{
		// Application initialization code here.
		
		Application.run(new ListViewDirSort());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

