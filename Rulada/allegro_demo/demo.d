
version (Tango) {
   import tango.stdc.stdlib;
   import tango.stdc.time;
}
else {
   import std.c;
   
}

import derelict.allegro.all;
import data;
import display;
import animsel;
import expl;
import title;
import game;


/* command line options */
bool cheat = false;
bool jumpstart = false;

/* our graphics, samples, etc. */
DATAFILE *datafile;

bool max_fps = false;


/* modifies the palette to give us nice colors for the GUI dialogs */
private void set_gui_colors()
{
   static RGB black = { 0, 0, 0, 0 };
   static RGB grey = { 48, 48, 48, 0 };
   static RGB white = { 63, 63, 63, 0 };

   set_color(0, &black);
   set_color(16, &black);
   set_color(1, &grey);
   set_color(255, &white);

   gui_fg_color = palette_color[0];
   gui_bg_color = palette_color[1];
}



private void intro_screen()
{
   BITMAP *bmp;
   play_sample(cast(SAMPLE*)datafile[INTRO_SPL].dat, 255, 128, 1000, false);

   bmp = create_sub_bitmap(screen, SCREEN_W / 2 - 160, SCREEN_H / 2 - 100,
                                                       320, 200);
   play_memory_fli(datafile[INTRO_ANIM].dat, bmp, false, null);
   destroy_bitmap(bmp);

   rest(1000);
   fade_out(1);
}



int main(char[][] args)
{
   int c, w, h;
   char[256] buf, buf2;
   ANIMATION_TYPE type;

   foreach (arg; args[1..$]) {
      if (ustricmp(arg.ptr, "-cheat") == 0)
         cheat = true;

      if (ustricmp(arg.ptr, "-jumpstart") == 0)
         jumpstart = true;
   }

   /* The fonts we are using don't contain the full latin1 charset (not to
    * mention Unicode), so in order to display correctly author names in
    * the credits with 8-bit characters, we will convert them down to 7
    * bits with a custom mapping table. Fortunately, Allegro comes with a
    * default custom mapping table which reduces Latin-1 and Extended-A
    * characters to 7 bits. We don't even need to call set_ucodepage()!
    */
   set_uformat(U_ASCII_CP);
   
   std.c.srand(rt.core.stdc.time.time(null));
   if (allegro_init() != 0)
      return 1;
   install_keyboard();
   install_timer();
   install_mouse();

   if (install_sound(DIGI_AUTODETECT, MIDI_AUTODETECT, null) != 0) {
      allegro_message("Error initialising sound\n%s\n", allegro_error);
      install_sound(DIGI_NONE, MIDI_NONE, null);
   }

   if (install_joystick(JOY_TYPE_AUTODETECT) != 0) {
      allegro_message("Error initialising joystick\n%s\n", allegro_error);
      install_joystick(JOY_TYPE_NONE);
   }

   if (set_gfx_mode(GFX_AUTODETECT, 320, 200, 0, 0) != 0) {
      if (set_gfx_mode(GFX_SAFE, 320, 200, 0, 0) != 0) {
         set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
         allegro_message("Unable to set any graphic mode\n%s\n",
                         allegro_error);
         return 1;
      }
   }

   get_executable_name(buf.ptr, buf.sizeof);
   replace_filename(buf2.ptr, buf.ptr, "demo.dat", buf2.sizeof);
   set_color_conversion(COLORCONV_NONE);
   datafile = load_datafile(buf2.ptr);
   if (!datafile) {
      set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
      allegro_message("Error loading %s\n", buf2.ptr);
      exit(1);
   }

   if (!jumpstart) {
      intro_screen();
   }

   clear_bitmap(screen);
   set_gui_colors();
   set_mouse_sprite(null);

   if (!gfx_mode_select(&c, &w, &h))
      exit(1);

   if (pick_animation_type(&type) < 0)
      exit(1);

   init_display(c, w, h, type);

   generate_explosions();

   //stop_sample(datafile[INTRO_SPL].dat);

   clear_bitmap(screen);

   while (title_screen())
      play_game();

   destroy_display();

   destroy_explosions();

   stop_midi();

   set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);

   end_title();

   unload_datafile(datafile);

   allegro_exit();

   return 0;
}
