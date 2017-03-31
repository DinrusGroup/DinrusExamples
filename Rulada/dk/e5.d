import amigos.dk.dkinter;
import std.io;

int main(string[] args)
{
  auto root=new Tk();

  auto lb=new Radiobutton(root,"Радио",0);lb.pack();
  auto b1=new Button(root,"Вспышка",delegate (Widget w,Event){lb.flash();});b1.pack();
  auto b2=new Button(root,"Погасить",delegate (Widget w,Event){lb.deselect();});b2.pack();
  auto b3=new Button(root,"Выделить",delegate (Widget w,Event){lb.select();});b3.pack();
  root.mainloop();
  return 0;
}
