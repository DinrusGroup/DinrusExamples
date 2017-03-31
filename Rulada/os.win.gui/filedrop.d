private import os.win.gui.all;
import os.win.gui.base;

class FileDropForm: os.win.gui.form.Form
{
	os.win.gui.listbox.ListBox fileList;
	
	
	this()
	{
		startPosition = os.win.gui.form.FormStartPosition.CENTER_SCREEN;
		text = "File Drop";
		clientSize = os.win.gui.drawing.Size(248, 294);
		fileList = new os.win.gui.listbox.ListBox();
		fileList.name = "fileList";
		fileList.allowDrop = true;
		fileList.dock = os.win.gui.control.DockStyle.FILL;
		fileList.integralHeight = false;
		fileList.sorted = true;
		fileList.bounds = Rect(0, 0, 248, 294);
		fileList.parent = this;
		
		fileList.items.add("<Drop files here>");
		
		fileList.dragOver ~= &fileList_dragOver;
		fileList.dragDrop ~= &fileList_dragDrop;
	}
	
	
	private void fileList_dragOver(Object sender, DragEventArgs ea)
	{
		if(ea.data.getDataPresent(DataFormats.fileDrop))
		{
			ea.effect = ea.allowedEffect & DragDropEffects.LINK; // Or COPY, or MOVE, etc.
		}
	}
	
	
	private void fileList_dragDrop(Object sender, DragEventArgs ea)
	{
		if(ea.data.getDataPresent(DataFormats.fileDrop))
		{
			if(ea.allowedEffect & DragDropEffects.LINK) // If can LINK, or COPY, or MOVE, etc.
			{
				char[][] fileNames;
				fileNames = ea.data.getData(DataFormats.fileDrop).getStrings();
				fileList.items.addRange(fileNames);
				
				ea.effect = DragDropEffects.LINK;  // Or COPY, or MOVE, etc; says what happened.
			}
		}
	}
}


int main()
{
	int result = 0;
	
	try
	{
		Application.enableVisualStyles();
		Application.autoCollect = false;
		
		Application.run(new FileDropForm());
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

