﻿// Written by Christopher E. Miller
// This code is public domain.
// www.dprogramming.com

// To compile:
// 	dfl dnote dnote.res -gui


module dnote;

private import std.path, std.stream, std.system;
private import std.utf;

private import os.win.gui.all, os.win.gui.x.winapi;


const char[] TITLE = "DNote";
const char[] VERSION = "1.1";
const char[] FULLTITLE = TITLE ~ " " ~ VERSION;

const char* IDI_ICON1 = cast(char*)101;

RegistryKey rkey;


class DNoteForm: Form
{
	const char[] UNTITLED = "Без названия";
	const char[] FILE_DIALOG_FILTER = "Текстовые документы (*.txt)|*.txt|Спецфайлы (*.spec)|*.d|Все файлы|*.*";
	
	DNoteTextBox pad; // The note pad.
	char[] fileName;
	bit isUntitled;
	int ibom = -1; // Current file's BOM. -1 for none.
	
	MenuItem editUndoMenu, editCutMenu, editCopyMenu, editPasteMenu,
		editDeleteMenu, editSelectAllMenu, formatWordWrapMenu;
	
	
	this(char[] fileName = UNTITLED)
	{
		icon = new Icon(LoadIconA(GetModuleHandleA(null), IDI_ICON1));
		setFileName(fileName);
		
		RegistryValueDword regDword;
		RegistryValueSz regSz;
		
		// Set the window bounds. Try to load from registry.
		regDword = cast(RegistryValueDword)rkey.getValue("X");
		if(!regDword)
		{
			// Bounds not in registry, let Windows set it.
			startPosition = FormStartPosition.WINDOWS_DEFAULT_BOUNDS;
		}
		else
		{
			startPosition = FormStartPosition.MANUAL;
			
			left = regDword.value;
			regDword = cast(RegistryValueDword)rkey.getValue("Y");
			if(regDword)
				top = regDword.value;
			regDword = cast(RegistryValueDword)rkey.getValue("DX");
			if(regDword && regDword.value >= width)
				width = regDword.value;
			regDword = cast(RegistryValueDword)rkey.getValue("DY");
			if(regDword && regDword.value >= height)
				height = regDword.value;
		}
		
		with(pad = new DNoteTextBox)
		{
			acceptsReturn = true;
			acceptsTab = true;
			
			multiline = true;
			maxLength = uint.max;
			dock = DockStyle.FILL;
			scrollBars = ScrollBars.BOTH;
			//wordWrap = false;
			hideSelection = true;
			
			regDword = cast(RegistryValueDword)rkey.getValue("WWrap");
			wordWrap = regDword && regDword.value;
			
			//font = new Font("Courier New", 10);
			char[] fontname;
			int fontsize;
			FontStyle fontstyle;
			ubyte fontscript = DEFAULT_CHARSET; // GDI charset ?
			
			regSz = cast(RegistryValueSz)rkey.getValue("fontname");
			if(regSz)
			{
				try
				{
					fontname = regSz.value;
					
					regDword = cast(RegistryValueDword)rkey.getValue("fontsize");
					if(regDword && regDword.value > 3 && regDword.value < 200)
						fontsize = cast(int)regDword.value;
					else
						fontsize = 10;
					
					regDword = cast(RegistryValueDword)rkey.getValue("fontstyle");
					if(regDword)
						fontstyle = cast(FontStyle)(regDword.value & (FontStyle.BOLD | FontStyle.ITALIC |
						FontStyle.STRIKEOUT | FontStyle.UNDERLINE));
					else
						fontstyle = FontStyle.REGULAR;
					
					regDword = cast(RegistryValueDword)rkey.getValue("fontscript");
					if(regDword)
						fontscript = cast(ubyte)regDword.value;
					
					font = new Font(fontname, cast(float)fontsize, fontstyle, GraphicsUnit.POINT, fontscript);
				}
				catch
				{
					fontname = null;
				}
				
				if(!fontname.length)
					goto def_font;
			}
			else
			{
				def_font:
				font = new Font("Courier New", 10);
			}
			
			textChanged ~= &padTextChangedEvent;
			gotFocus ~= &padFirstFocusEvent;
			
			parent = this;
			
			if(!isUntitled)
				loadFile(fileName);
		}
		
		MainMenu mm;
		MenuItem mpop, mi;
		
		mm = new MainMenu;
		
		with(mpop = new MenuItem)
		{
			text = "&Файл";
			index = 0;
			mm.menuItems.add(mpop);
		}
		
		with(mi = new MenuItem)
		{
			text = "&Новый\tCtrl+N";
			index = 0;
			click ~= &fileNew;
			mpop.menuItems.add(mi);
		}
		addShortcut(Keys.CONTROL | Keys.N, &fileNew);
		
		with(mi = new MenuItem)
		{
			text = "&Открыть...\tCtrl+O";
			index = 1;
			click ~= &fileOpen;
			mpop.menuItems.add(mi);
		}
		addShortcut(Keys.CONTROL | Keys.O, &fileOpen);
		
		with(mi = new MenuItem)
		{
			text = "&Сохранить\tCtrl+S";
			index = 2;
			click ~= &fileSave;
			mpop.menuItems.add(mi);
		}
		addShortcut(Keys.CONTROL | Keys.S, &fileSave);
		
		with(mi = new MenuItem)
		{
			//text = "Save &As...\tCtrl+Shift+S";
			text = "Сохранить &Как...";
			index = 3;
			click ~= &fileSaveAs;
			mpop.menuItems.add(mi);
		}
		addShortcut(Keys.CONTROL | Keys.SHIFT | Keys.S, &fileSaveAs);
		
		with(mi = new MenuItem)
		{
			text = "-";
			index = 4;
			mpop.menuItems.add(mi);
		}
		
		with(mi = new MenuItem)
		{
			text = "Вы&ход";
			index = 5;
			click ~= &fileExit;
			mpop.menuItems.add(mi);
		}
		
		with(mpop = new MenuItem)
		{
			text = "&Правка";
			index = 1;
			popup ~= &editPopupEvent;
			mm.menuItems.add(mpop);
		}
		
		with(editUndoMenu = new MenuItem)
		{
			text = "&Отменить\tCtrl+Z";
			index = 0;
			click ~= &editUndo;
			mpop.menuItems.add(editUndoMenu);
		}
		
		with(mi = new MenuItem)
		{
			text = "-";
			index = 1;
			mpop.menuItems.add(mi);
		}
		
		with(editCutMenu = new MenuItem)
		{
			text = "Выр&езать\tCtrl+X";
			index = 2;
			click ~= &editCut;
			mpop.menuItems.add(editCutMenu);
		}
		
		with(editCopyMenu = new MenuItem)
		{
			text = "&Копировать\tCtrl+C";
			index = 3;
			click ~= &editCopy;
			mpop.menuItems.add(editCopyMenu);
		}
		
		with(editPasteMenu = new MenuItem)
		{
			text = "&Вставить\tCtrl+V";
			index = 4;
			click ~= &editPaste;
			mpop.menuItems.add(editPasteMenu);
		}
		
		with(editDeleteMenu = new MenuItem)
		{
			text = "Уда&лить\tDel";
			index = 5;
			click ~= &editDelete;
			mpop.menuItems.add(editDeleteMenu);
		}
		
		with(mi = new MenuItem)
		{
			text = "-";
			index = 6;
			mpop.menuItems.add(mi);
		}
		
		with(editSelectAllMenu = new MenuItem)
		{
			//text = "Select &All\tCtrl+A";
			text = "Выбрать &Все";
			index = 7;
			click ~= &editSelectAll;
			mpop.menuItems.add(editSelectAllMenu);
		}
		
		with(mpop = new MenuItem)
		{
			text = "Ф&орматировать";
			index = 2;
			mm.menuItems.add(mpop);
		}
		
		with(formatWordWrapMenu = new MenuItem)
		{
			text = "&Очистка";
			checked = pad.wordWrap;
			index = 0;
			click ~= &formatWordWrap;
			mpop.menuItems.add(formatWordWrapMenu);
		}
		
		with(mi = new MenuItem)
		{
			text = "&Шрифр...";
			index = 1;
			click ~= &formatFont;
			mpop.menuItems.add(mi);
		}
		
		with(mpop = new MenuItem)
		{
			text = "&Справка";
			index = 3;
			mm.menuItems.add(mpop);
		}
		
		with(mi = new MenuItem)
		{
			text = "&О программе " ~ TITLE;
			index = 0;
			click ~= &helpAbout;
			mpop.menuItems.add(mi);
		}
		
		menu = mm;
	}
	
	
	protected override void onClosing(CancelEventArgs ea)
	{
		if(!canContinue)
		{
			ea.cancel = true;
		}
		else
		{
			// Closing now, so save settings...
			
			RegistryValueDword regDword;
			RegistryValueSz regSz;
			regDword = new RegistryValueDword;
			regSz = new RegistryValueSz;
			
			// Save window bounds to registry if not min/max.
			if(windowState == FormWindowState.NORMAL)
			{
				regDword.value = left;
				rkey.setValue("X", regDword);
				regDword.value = top;
				rkey.setValue("Y", regDword);
				regDword.value = width;
				rkey.setValue("DX", regDword);
				regDword.value = height;
				rkey.setValue("DY", regDword);
			}
			
			// Save word wrap mode.
			regDword.value = pad.wordWrap;
			rkey.setValue("WWrap", regDword);
			
			// Save font info.
			Font fon;
			fon = pad.font;
			regSz.value = fon.name;
			rkey.setValue("fontname", regSz);
			regDword.value = cast(DWORD)fon.size;
			rkey.setValue("fontsize", regDword);
			regDword.value = fon.style;
			rkey.setValue("fontstyle", regDword);
			regDword.value = fon.gdiCharSet;
			rkey.setValue("fontscript", regDword);
		}
	}
	
	
	final:
	void editPopupEvent(Object sender, EventArgs ea)
	{
		int slen, tlen;
		bit issel;
		bit iscliptxt;
		
		slen = pad.selectionLength;
		tlen = pad.textLength;
		issel = slen != 0;
		iscliptxt = Clipboard.getDataObject().getDataPresent(DataFormats.text);
		
		editUndoMenu.enabled = pad.canUndo;
		editCutMenu.enabled = !pad.readOnly() && issel;
		editCopyMenu.enabled = issel;
		editPasteMenu.enabled = !pad.readOnly() && iscliptxt;
		editDeleteMenu.enabled = !pad.readOnly() && issel;
		editSelectAllMenu.enabled = tlen != 0 && tlen != slen;
	}
	
	
	void padFirstFocusEvent(Object sender, EventArgs ea)
	{
		pad.selectionLength = 0;
		pad.gotFocus.removeHandler(&padFirstFocusEvent);
	}
	
	
	void formatWordWrap(Object sender, EventArgs ea)
	{
		formatWordWrapMenu.checked = !formatWordWrapMenu.checked;
		pad.changeWrap(formatWordWrapMenu.checked);
	}
	
	
	void formatFont(Object sender, EventArgs ea)
	{
		FontDialog fd;
		with(fd = new FontDialog)
		{
			fd.showEffects = false;
			fd.font = pad.font;
			if(DialogResult.OK == fd.showDialog(this))
			{
				pad.font = fd.font;
			}
		}
	}
	
	
	void helpAbout(Object sender, EventArgs ea)
	{
		msgBox(this, FULLTITLE ~ "\r\nНаписано Виталием Кулич\r\n"
			"www.github.com/DinrusGroup", "О программе " ~ TITLE, MsgBoxButtons.OK, MsgBoxIcon.INFORMATION);
	}
	
	
	void editUndo(Object sender, EventArgs ea)
	{
		pad.undo();
	}
	
	
	void editCut(Object sender, EventArgs ea)
	{
		pad.cut();
	}
	
	
	void editCopy(Object sender, EventArgs ea)
	{
		pad.copy();
	}
	
	
	void editPaste(Object sender, EventArgs ea)
	{
		pad.paste();
	}
	
	
	void editDelete(Object sender, EventArgs ea)
	{
		pad.selectedText = null;
	}
	
	
	void editSelectAll(Object sender, EventArgs ea)
	{
		pad.selectAll();
	}
	
	
	void padTextChangedEvent(Object sender, EventArgs ea)
	{
		char[] s;
		s = text;
		if(pad.modified() && s.length && s[0] != '*')
			text = "* " ~ s;
	}
	
	
	void resetTitle()
	{
		text = getBaseName(fileName) ~ " - " ~ TITLE;
	}
	
	
	void setFileName(char[] fn = UNTITLED)
	{
		fileName = fn;
		resetTitle();
		isUntitled = fn == UNTITLED;
	}
	
	
	// Only loads the contents of the file, sets the BOM
	// and loads the TextBox -pad-.
	void loadFile(char[] fn)
	{
		Stream _f;
		EndianStream f;
		char[] buf;
		
		//_f = new BufferedFile(fn, FileMode.In); // BufferedFile is not working.
		_f = new File(fn, FileMode.In);
		try
		{
			size_t i;
			
			f = new EndianStream(_f);
			ibom = f.readBOM();
			
			i = 0;
			switch(ibom)
			{
				case BOM.UTF8, -1:
					//buf = new char[f.size() - f.position()];
					buf = new char[f.size()];
					while(!f.eof())
					{
						buf[i++] = f.getc();
					}
					buf = buf[0 .. i];
					break;
				
				case BOM.UTF16LE, BOM.UTF16BE:
					wchar[] wbuf;
					//wbuf = new wchar[(f.size() - f.position()) / wchar.sizeof];
					wbuf = new wchar[f.size() / wchar.sizeof];
					while(!f.eof())
					{
						wbuf[i++] = f.getcw();
					}
					buf = std.utf.toUTF8(wbuf[0 .. i]);
					break;
				
				case BOM.UTF32LE, BOM.UTF32BE:
					dchar[] dbuf;
					//dbuf = new dchar[(f.size() - f.position()) / dchar.sizeof];
					dbuf = new dchar[f.size() / dchar.sizeof];
					while(!f.eof())
					{
						dchar dch;
						f.read(dch);
						dbuf[i++] = dch;
					}
					buf = std.utf.toUTF8(dbuf[0 .. i]);
					break;
			}
			
			pad.text = buf;
		}
		finally
		{
			delete f;
			_f.close();
			delete _f;
		}
	}
	
	
	// Only saves TextBox -pad-'s display text to the file
	// and writes a BOM if -ibom- is not -1.
	void saveFile(char[] fn)
	{
		int sz;
		Endian endian;
		char[] s;
		s = pad.text;
		
		// See if a BOM needs to be added.
		if(-1 == ibom)
		{
			foreach(char ch; s)
			{
				if(ch >= 0x80)
				{
					ibom = BOM.UTF8;
					break;
				}
			}
		}
		
		switch(ibom)
		{
			case BOM.UTF8, -1:
				sz = char.sizeof;
				endian = std.system.endian;
				break;
			
			case BOM.UTF16LE:
				sz = wchar.sizeof;
				endian = Endian.LittleEndian;
				break;
			
			case BOM.UTF16BE:
				sz = wchar.sizeof;
				endian = Endian.BigEndian;
				break;
			
			case BOM.UTF32LE:
				sz = dchar.sizeof;
				endian = Endian.LittleEndian;
				break;
			
			case BOM.UTF32BE:
				sz = dchar.sizeof;
				endian = Endian.BigEndian;
				break;
		}
		
		BufferedFile _f;
		EndianStream f;
		
		_f = new BufferedFile(fn, FileMode.OutNew);
		try
		{
			f = new EndianStream(_f, endian);
			if(ibom != -1)
				f.writeBOM(cast(BOM)ibom);
			
			switch(sz)
			{
				case char.sizeof:
					foreach(char ch; s)
					{
						//f.write(ch);
						
						//f.fixBO(&ch, char.sizeof);
						f.writeExact(&ch, char.sizeof);
					}
					break;
				
				case wchar.sizeof:
					foreach(wchar ch; s)
					{
						//f.write(ch);
						
						f.fixBO(&ch, wchar.sizeof);
						f.writeExact(&ch, wchar.sizeof);
					}
					break;
				
				case dchar.sizeof:
					foreach(dchar ch; s)
					{
						//f.write(ch);
						
						f.fixBO(&ch, dchar.sizeof);
						f.writeExact(&ch, dchar.sizeof);
					}
					break;
			}
		}
		finally
		{
			delete f;
			_f.close();
			delete _f;
		}
	}
	
	
	bit canContinue() // getter
	{
		if(isUntitled && !pad.textLength)
			return true;
		
		if(pad.modified)
		{
			switch(msgBox(this, "Текст в файле " ~ fileName ~
				" изменён.\r\n\r\nСохранить изменения?",
				TITLE, MsgBoxButtons.YES_NO_CANCEL, MsgBoxIcon.WARNING))
			{
				case DialogResult.YES:
					if(!doSave())
						return false;
					break;
				
				case DialogResult.NO:
					break;
				
				case DialogResult.CANCEL:
					return false;
			}
		}
		
		return true;
	}
	
	
	// Returns false if user pressed cancel.
	bit doSave()
	{
		if(isUntitled)
		{
			if(!askForFileName())
				return false;
		}
		doWrite();
		return true;
	}
	
	
	// Returns false if user pressed cancel.
	bit doSaveAs()
	{
		if(!askForFileName())
			return false;
		doWrite();
		return true;
	}
	
	
	// Returns false if user pressed cancel.
	bit askForFileName()
	{
		SaveFileDialog sfd;
		sfd = new SaveFileDialog;
		sfd.filter = FILE_DIALOG_FILTER;
		sfd.defaultExt = "txt";
		if(!isUntitled)
			sfd.fileName = fileName;
		if(DialogResult.OK != sfd.showDialog())
			return false;
		setFileName(sfd.fileName);
		return true;
	}
	
	
	void doWrite()
	in
	{
		assert(!isUntitled);
	}
	body
	{
		saveFile(fileName);
		pad.modified = false;
		resetTitle();
	}
	
	
	void fileNew(Object sender, EventArgs ea)
	{
		if(canContinue)
		{
			pad.clear();
			pad.modified = false;
			ibom = -1;
			setFileName();
		}
	}
	
	
	void fileOpen(Object sender, EventArgs ea)
	{
		if(canContinue)
		{
			OpenFileDialog ofd;
			ofd = new OpenFileDialog;
			ofd.filter = FILE_DIALOG_FILTER;
			ofd.defaultExt = "txt";
			if(DialogResult.OK == ofd.showDialog())
			{
				loadFile(ofd.fileName);
				pad.modified = false;
				setFileName(ofd.fileName);
			}
		}
	}
	
	
	void fileSave(Object sender, EventArgs ea)
	{
		doSave();
	}
	
	
	void fileSaveAs(Object sender, EventArgs ea)
	{
		doSaveAs();
	}
	
	
	void fileExit(Object sender, EventArgs ea)
	{
		close();
	}
}


class DNoteTextBox: TextBox
{
	final void changeWrap(bit wrap)
	{
		char[] ot;
		uint oss, osl;
		bit om;
		
		ot = text;
		oss = selectionStart;
		osl = selectionLength;
		om = modified;
		
		visible = false;
		dispose(false);
		
		wordWrap = wrap;
		createControl();
		text = ot;
		modified = om;
		show();
		focus();
		
		select(oss, osl);
		scrollToCaret(); // Not same scroll position but at least better than Notepad.
	}
}


int main()
{
	char[][] args;
	int result = 0;
	args = Environment.getCommandLineArgs();
	
	try
	{
		DNoteForm dnf;
		
		rkey = Registry.currentUser.createSubKey("Software\\" ~ TITLE);
		
		if(args.length > 1)
			dnf = new DNoteForm(args[1]);
		else
			dnf = new DNoteForm;
		
		Application.run(dnf);
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Серьёзная Ошибка", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}

