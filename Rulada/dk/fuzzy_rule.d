import amigos.dk.dkinter;

import std.io;
import std.conv;
import std.string;

struct Coord
{
  float x;
  float y;
}

class PlotCanvas:public Frame
{
  // wwidth- размер предметной области по X
  this(Widget master,float wwidth ,int w,int h)
    {
      super(master);
      m_canvas=new Canvas(this,w,h);
      m_canvas.pack();
      width=w;
      height=h;
      this.wwidth=wwidth;
      init();
      this.m_canvas.bind("<Button-1>",&this.onClick);
      last_x=cast(float)0;
      last_y=cast(float)height;
    }
  
  void init()
  {
    int xstep=cast(int)(height/10);
    int ystep=cast(int)(width/10);

    this.m_canvas.configure("bg","grey");


    float txt=1;
    for(int i=0;i<height;i+=xstep)
      {
	this.m_canvas.line([0,i,width,i]);
	string t=.toString(txt);

	if(t.length>4)
	  t=t[0..4];

	this.m_canvas.text(t,25,i+10);
	txt-=0.1;
      }

    for(int i=30;i<width;i+=ystep)
      this.m_canvas.line([i,0,i,height]);
  }
  void onClick(Widget w,Event e)
  {
    writefln("x=",e.x," y=",e.y);
    this.m_canvas.oval("white",e.x-20,e.y-20,e.x+20,e.y+20);
    writefln("rx=",(e.x*wwidth/width)," ry=",1-(e.y/cast(float)height));
    Coord c={(e.x*wwidth/width),1-(e.y/cast(float)height)};
    m_coords~=[c];
    writefln("lx=",last_x," ly=",last_y);
    m_canvas.line("white",[cast(int)last_x,cast(int)last_y,cast(int)e.x,cast(int)e.y]);
    string last_line=m_canvas.line("white",[cast(int)e.x,cast(int)e.y,width,height]);
    m_canvas.cdelete("Templ");
    m_canvas.addtag("Templ","withtag",last_line);
    last_x=e.x;
    last_y=e.y;
  }
 protected:
  Coord[] m_coords;
  Canvas  m_canvas;
  int     width,height;
  float   last_x;
  float   last_y;
  float   wwidth;      /// размер предметной области по X
}

void main (string[] argc)
{
  auto root=new Tk();

  auto canv=new PlotCanvas(root,1000.0,800,600);
  canv.pack();
  auto btn=new Button(root,"Exit",&root.exit);
  btn.pack();
  root.mainloop();
}
