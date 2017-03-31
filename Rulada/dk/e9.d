import amigos.dk.dkinter;
import std.io;


int main(string[] args)
{
  auto корень=new Tk();

  auto канва=new Canvas(корень,800,600);
  канва.line([10,10,1000,1000]);
  канва.line("red",[50,500,100,100]);
  канва.oval("green",50,50,70,70);
  auto txt=канва.text("синий",110,150);
  канва.addtag("Text","withtag",txt);
  канва.pack();
  auto btn=new Button(корень,"Выход",delegate (Widget w,Event){корень.exit();});btn.pack();
  корень.mainloop();
  return 0;
}
