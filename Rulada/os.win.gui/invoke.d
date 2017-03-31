// To compile:
// 	dfl invoke -gui


private import std.string, std.thread;

private import os.win.gui.all, os.win.gui.x.winapi;


MainForm mainForm;


class MainForm: Form
{
	int tcount = 0;
	TextBox disp;
	
	
	this()
	{
		text = "invoke()";
		
		with(disp = new TextBox)
		{
			multiline = true;
			wordWrap = true;
			dock = DockStyle.LEFT;
			width = 200;
			
			parent = this;
		}
		
		with(new Button)
		{
			text = "&New Thread";
			location = Point(204, 4);
			
			parent = this;
			
			click ~= &newThreadButton_click;
		}
	}
	
	
	private void newThreadButton_click(Object sender, EventArgs ea)
	{
		with(new MyThread(++tcount))
		{
			start();
		}
	}
}


class MyThread: Thread
{
	int tnum;
	
	
	this(int threadNumber)
	{
		tnum = threadNumber;
	}
	
	
	Object invokedInFormThread(Object[] args)
	{
		if(mainForm.created)
			mainForm.disp.appendText("invoke() from thread #" ~ std.string.toString(tnum) ~ \r\n);
		
		if(tnum == 4)
			throw new Exception("Throwing exception from thread 4 invoke() just for fun!");
		
		return null;
	}
	
	
	override int run()
	{
		for(;;)
		{
			try
			{
				mainForm.invoke(&invokedInFormThread, null);
			}
			catch(Object e)
			{
				msgBox(e.toString(), "Thread " ~ std.string.toString(tnum) ~ " error");
			}
			
			Sleep(1000);
		}
		
		return 0;
	}
}


int main()
{
	int result = 0;
	
	try
	{
		mainForm = new MainForm;
		Application.run(mainForm);
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

