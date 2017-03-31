/*
 * This file is part of gtkD.
 * 
 * gtkD is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 * 
 * gtkD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with gtkD; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

module TestThemes;

private import gtkD.gtk.Window;

private import gtkD.gtk.VBox;
private import gtkD.gtk.ScrolledWindow;
private import gtkD.gtk.Widget;
private import gtkD.gtk.ComboBox;
private import gtkD.gtk.ButtonBox;
private import gtkD.gtk.HButtonBox;
private import gtkD.gtk.Button;

class TestThemes : VBox
{

	Window window;
	ScrolledWindow sw;
		
	this(Window window)
	{
		this.window = window;
		debug(1)
		{
			printf("instantiating TestThemes\n");
		}

		super(false,8);
		
		sw = new ScrolledWindow(null,null);
		
		sw.addWithViewport(initTable());

		ButtonBox hBox = HButtonBox.createActionBox();

		packStart(sw,true,true,0);
		packStart(hBox,false,false,0);

	}

	Widget initTable()
	{
		
		return new ComboBox();
	}
}
