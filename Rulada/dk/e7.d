import amigos.dk.dkinter;
import std.io;

int main(string[] args)
{
  auto root=new Tk();

  auto enterB=new Button(root,"Enter Button",delegate (Widget w,Event){writefln("Enter");});
  enterB.tkButtonEnter();
  enterB.pack();
  auto leaveB=new Button(root,"Leave Button",delegate (Widget w,Event){writefln("Leave");});
  leaveB.tkButtonEnter();
  leaveB.pack();

  auto downB=new Button(root,"Down Button",delegate (Widget w,Event){writefln("Down");});
  downB.tkButtonEnter();
  downB.pack();

  auto upB=new Button(root,"UP Button",delegate (Widget w,Event){writefln("Up");});
  upB.tkButtonEnter();
  upB.pack();

  auto invokeB=new Button(root,"Invoke Button",delegate (Widget w,Event){writefln("Invoke");enterB.flash();});
  invokeB.tkButtonEnter();
  invokeB.pack();

  auto exitB=new Button(root,"Exit",delegate (Widget w,Event){root.exit();});
  exitB.pack();

  root.mainloop();
  return 0;
}
