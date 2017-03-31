// This is just a basic layout of some client application.
// This code is public domain.

// To compile:
// 	dfl client -gui


module client;

private import os.windows, std.string, std.socket;

private import os.win.gui.all;


char[] nserver;
uint nip = InternetAddress.ADDR_NONE;
ushort nport = 119;
char[] nuser, npass;


class ClientForm: Form
{
	const int PADDING = 8;
	const int TEXTBOX_HEIGHT = 20;
	const int LABEL_HEIGHT = 16;
	
	ListBox groups;
	ListBox msgs;
	
	
	void fileExitClick(Object sender, EventArgs ea)
	{
		Application.exitThread();
	}
	
	
	void fileActionMinClick(Object sender, EventArgs ea)
	{
		windowState = FormWindowState.MINIMIZED;
	}
	
	
	void fileActionMaxClick(Object sender, EventArgs ea)
	{
		windowState = FormWindowState.MAXIMIZED;
	}
	
	
	void fileActionRestoreClick(Object sender, EventArgs ea)
	{
		windowState = FormWindowState.NORMAL;
	}
	
	
	this()
	{
		text = "Client";
		startPosition = FormStartPosition.WINDOWS_DEFAULT_LOCATION;
		
		MenuItem mmenu;
		MenuItem mi, mi2;
		
		this.menu = new MainMenu;
		
		mmenu = new MenuItem;
		mmenu.text = "&Файл";
		this.menu.menuItems.add(mmenu);
		
		mi2 = new MenuItem;
		mi2.text = "&Действие";
		mmenu.menuItems.add(mi2);
		
		mi = new MenuItem;
		mi.text = "С&вернуть";
		mi.click ~= &fileActionMinClick;
		mi2.menuItems.add(mi);
		
		mi = new MenuItem;
		mi.text = "Ра&звернуть";
		mi.click ~= &fileActionMaxClick;
		mi2.menuItems.add(mi);
		
		mi = new MenuItem;
		mi.text = "Во&сстановить";
		mi.click ~= &fileActionRestoreClick;
		mi2.menuItems.add(mi);
		
		mi = new MenuItem;
		mi.text = "-";
		mmenu.menuItems.add(mi);
		
		mi = new MenuItem;
		mi.text = "Вы&ход";
		mi.click ~= &fileExitClick;
		mmenu.menuItems.add(mi);
		
		suspendLayout();
		
		dockPadding.all = PADDING;
		
		groups = new ListBox;
		groups.width = 160;
		groups.dock = DockStyle.LEFT;
		groups.integralHeight = false;
		groups.parent = this;
		
		Splitter split;
		split = new Splitter;
		split.width = PADDING;
		split.minSize = 100;
		//split.minExtra = 200;
		split.dock = DockStyle.LEFT;
		split.parent = this;
		
		msgs = new ListBox;
		msgs.dock = DockStyle.FILL;
		msgs.integralHeight = false;
		msgs.parent = this;
		
		resumeLayout(false);
		
		show(); // Show me first.
		showCommunicationsDialog();
	}
	
	
	void showCommunicationsDialog()
	{
		Form cmc;
		
		with(cmc = new Form)
		{
			text = "Коммуникации";
			icon = null;
			//icon = new Icon(LoadIconA(null, cast(LPSTR)32514));
			clientSize = Size(300, 192);
			startPosition = FormStartPosition.CENTER_PARENT;
			formBorderStyle = FormBorderStyle.FIXED_DIALOG;
			maximizeBox = false;
			minimizeBox = false;
		}
			
		Label label;
		with(label = new Label)
		{
			label.text = "&Сервер:";
			bounds = Rect(PADDING, PADDING + 2, 80, LABEL_HEIGHT);
			parent = cmc;
		}
		
		TextBox serverBox;
		with(serverBox = new TextBox)
		{
			if(nport == nport.init)
				text = nserver;
			else
				text = nserver ~ ":" ~ std.string.toString(nport);
			bounds = Rect(100, PADDING, cmc.clientSize.width - 100 - PADDING, TEXTBOX_HEIGHT);
			maxLength = 70;
			parent = cmc;
		}
		
		GroupBox gbox;
		with(gbox = new GroupBox)
		{
			text = "Авторизация";
			bounds = Rect(PADDING, PADDING + TEXTBOX_HEIGHT + PADDING, cmc.clientSize.width - PADDING * 2, 112);
			parent = cmc;
		}
		
		with(label = new Label)
		{
			label.text = "&Пользователь:";
			bounds = Rect(gbox.displayRectangle.x + PADDING, gbox.displayRectangle.y + PADDING + 2, 80, LABEL_HEIGHT);
			parent = gbox;
		}
		
		TextBox userBox;
		with(userBox = new TextBox)
		{
			bounds = Rect(100, gbox.displayRectangle.y + PADDING, gbox.displayRectangle.width - 100 - PADDING, TEXTBOX_HEIGHT);
			maxLength = 70;
			parent = gbox;
		}
		
		with(label = new Label)
		{
			label.text = "&Пароль:";
			bounds = Rect(gbox.displayRectangle.x + PADDING, gbox.displayRectangle.y + PADDING + TEXTBOX_HEIGHT + PADDING + 2,
				80, LABEL_HEIGHT);
			parent = gbox;
		}
		
		TextBox passBox;
		with(passBox = new TextBox)
		{
			bounds = Rect(100, gbox.displayRectangle.y + PADDING + TEXTBOX_HEIGHT + PADDING,
				gbox.displayRectangle.width - 100 - PADDING, TEXTBOX_HEIGHT);
			parent = gbox;
		}
		
		with(label = new Label)
		{
			label.text = "Примечание: авторизация нужна не всем.";
			bounds = Rect(gbox.displayRectangle.x + PADDING, gbox.displayRectangle.y + PADDING +
				TEXTBOX_HEIGHT + PADDING + TEXTBOX_HEIGHT + PADDING + 2, gbox.clientSize.width - PADDING * 2, LABEL_HEIGHT);
			parent = gbox;
		}
		
		
		void onOkClick(Object sender, EventArgs e)
		{
			char[] s;
			int i;
			
			s = serverBox.text;
			if(s.length < 4)
				throw new Exception("Неверный сервер.");
			
			i = std.string.find(s, ':');
			if(i != -1)
			{
				nport = std.conv.toUshort(s[i + 1 .. s.length]);
				nserver = s[0 .. i];
			}
			else
			{
				nport = nport.init;
				nserver = s;
			}
			
			nuser = userBox.text;
			npass = passBox.text;
			
			cmc.close();
		}
		
		
		Button okBtn;
		with(okBtn = new Button)
		{
			text = "OK";
			location = Point(cmc.clientSize.width - size.width - PADDING - width - PADDING,
				cmc.clientSize.height - size.height - PADDING);
			parent = cmc;
			cmc.acceptButton = okBtn;
			click ~= &onOkClick;
		}
		
		Button cancelBtn;
		with(cancelBtn = new Button)
		{
			text = "Отмена";
			location = Point(cmc.clientSize.width - size.width - PADDING,
				cmc.clientSize.height - size.height - PADDING);
			parent = cmc;
			cmc.cancelButton = cancelBtn;
			click ~= delegate(Object sender, EventArgs e) { cmc.close(); };
		}
		
		cmc.showDialog(this);
	}
	
	
	override Size defaultSize() // getter
	{
		return Size(500, 400);
	}
	
	
	void netEvent(Socket sock, EventType type, int err)
	{
		switch(type)
		{
			case EventType.CLOSE:
				
				break;
			
			default: ;
		}
	}
}


int main()
{
	int result = 0;
	
	try
	{
		Application.enableVisualStyles();
		Application.run(new ClientForm);
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Непоправимая Ошибка", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

