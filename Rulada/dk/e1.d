import amigos.dk.dkinter;
import std.io;
pragma(lib, "amigos.lib");

int main(string[] args)
{
  auto root=new Tk();

  auto lb=new Label(root,"Привет мир!");lb.pack();
  auto mes=new Message(root,"Добро пожаловать в \ndkinter!");mes.pack();

  root.mainloop();
  return 0;
}
