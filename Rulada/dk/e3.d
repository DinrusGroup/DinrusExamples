import amigos.dk.dkinter;
import std.io, std.console;

int main(string[] args)
{
  auto root=new Tk();

  auto e=new Entry(root);
  e.pack();
  auto b1=new Button(root,"OK",delegate (Widget w,Event)
		     {
		       say(e.text()).nl;
		       e.text("Привет, юзер! :)");
		     });  
  b1.pack();

  e.bind("<Button-1>",delegate(Widget,Event ev)
	 {
	   say("Нажато!!!");
	   writefln("x=",ev.x," y=",ev.y);
	 });
  
  root.mainloop();
  return 0;
}
