import amigos.dk.dkinter;
import std.io;

int main(string[] args)
{
  auto root=new Tk();

  auto sb=new Spinbox(root);
  sb.pack();

  auto b=new Button(root,"Вывести",delegate (Widget w,Event)
		    {
		      writefln("get: ",sb.get());
		    });
  b.pack("side","left");
  
  auto exitB=new Button(root,"Выход",delegate (Widget w,Event){root.exit();});
  exitB.pack("side","left");

  root.mainloop();
  return 0;
}
