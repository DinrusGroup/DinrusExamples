import amigos.dk.dkinter;
import std.io;


int main(string[] args)
{
  auto root=new Tk();

  auto sc=new Scale(root,"масштаб");sc.pack();
  sc.cfg(["orient":HORIZONTAL]);
  auto sbtn=new Button(root,"Вывести",
		       delegate (Widget w,Event)
		       {
			 writefln("get: ",sc.get());
			 sc.set(10);
		       });
  sbtn.pack();
  auto btn=new Button(root,"Выход",delegate (Widget w,Event){root.exit();});btn.pack();
  root.mainloop();
  return 0;
}
