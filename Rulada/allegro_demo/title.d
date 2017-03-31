version (Tango) {
   import tango.stdc.stdlib;
   import tango.stdc.string;
}
else {
   import std.c;//.stdlib;
   //import std.c.string;
}

import derelict.allegro.all;
import star;
import demo;
import data;
import display;
import dirty;


/* for parsing readme.txt */
struct TEXT_LIST {
   char *text;
   TEXT_LIST *next;
}

struct README_SECTION {
   TEXT_LIST *head;
   TEXT_LIST *tail;
   char *flat;
   char *desc;
}

/* for parsing thanks._tx and the various source files */
struct CREDIT_NAME {
   char *name;
   char *text;
   TEXT_LIST *files;
   CREDIT_NAME *next;
}

/* text messages (loaded from readme.txt) */
private char *title_text;
private int title_size;
private int title_alloced;

private char *end_text;

private PALETTE title_palette;

/* author credits scroller */
private int credit_width = 0;
private int credit_scroll = 0;
private int credit_offset = 0;
private int credit_age = 0;
private int credit_speed = 32;
private int credit_skip = 1;

/* text scroller at the bottom */
private int text_scroll = 0;
private BITMAP *text_bmp;
private int text_char;
private int text_pix;
private int text_width;

CREDIT_NAME *credit_name = null;

private CREDIT_NAME *credits = null;

/* timer callback for controlling the speed of the scrolling text */
private /*volatile*/ int scroll_count;



private extern (C) void scroll_counter()
{
   volatile scroll_count++;
}
//END_OF_STATIC_FUNCTION(scroll_counter);

/* formats a list of TEXT_LIST structure into a single string */
private char *format_text(TEXT_LIST * head, char *eol, char *gap)
{
   TEXT_LIST *l;
   int size = 0;
   char *s;

   l = head;
   while (l) {
      if (l.text[0])
         size += strlen(l.text) + strlen(eol);
      else
         size += strlen(gap) + strlen(eol);
      l = l.next;
   }

   s = cast(char*)malloc(size + 1);
   s[0] = 0;

   l = head;
   while (l) {
      if (l.text[0])
         strcat(s, l.text);
      else
         strcat(s, gap);
      strcat(s, eol);
      l = l.next;
   }

   return s;
}



/* loads the scroller message from readme.txt */
private void load_text()
{
   static README_SECTION sect[4] = [
      {null, null, null, "Introduction"},
      {null, null, null, "Features"},
      {null, null, null, "Copyright"},
      {null, null, null, "Contact info"}
   ];

const char* SPLITTER = "                                ";

   static char* intro_msg =
       "Welcome to the Allegro demonstration game, by Shawn Hargreaves." ~
       SPLITTER ~
       "Your mission: to go where no man has gone before, to seek out strange new life, and to boldly blast it to smithereens." ~
       SPLITTER ~
       "Your controls: the arrow keys to move left and right, the up arrow to accelerate (the faster you go, the more score you get), and the space bar to fire." ~
       SPLITTER ~
       "What complexity!" ~
       SPLITTER ~
       "What subtlety." ~
       SPLITTER ~
       "What originality." ~
       SPLITTER  ~ "But enough of that. On to the serious stuff..."  ~ SPLITTER;

   static char* splitter = SPLITTER;
   static char* marker = "--------";
   char[256] buf, buf2;
   README_SECTION *sec = null;
   TEXT_LIST* l, p;
   PACKFILE *f;
   int inblank = true;
   char *s;
   int i;

   get_executable_name(buf.ptr, buf.sizeof);

   replace_filename(buf2.ptr, buf.ptr, "readme.txt", buf2.sizeof);
   f = pack_fopen(buf2.ptr, F_READ);

   if (!f) {
      replace_filename(buf2.ptr, buf.ptr, "../readme.txt", buf2.sizeof);
      f = pack_fopen(buf2.ptr, F_READ);

      if (!f) {
         title_text =
             "Can't find readme.txt, so this scroller is empty.                ";
         title_size = strlen(title_text);
         title_alloced = false;
         end_text = null;
         return;
      }
   }

   while (pack_fgets(buf.ptr, buf.sizeof - 1, f) != null) {
      if (buf[0] == '=') {
         s = strchr(buf.ptr, ' ');
         if (s) {
            for (i = strlen(s) - 1; (uisspace(s[i])) || (s[i] == '='); i--)
               s[i] = 0;

            s++;

            sec = null;
            inblank = true;

            for (i = 0; i < cast(int)(sect.sizeof) / sect[0].sizeof; i++) {
               if (ustricmp(s, sect[i].desc) == 0) {
                  sec = &sect[i];
                  break;
               }
            }
         }
      }
      else if (sec) {
         s = buf.ptr;

         while ((*s) && (uisspace(*s)))
            s++;

         for (i = strlen(s) - 1; (i >= 0) && (uisspace(s[i])); i--)
            s[i] = 0;

         if ((s[0]) || (!inblank)) {
            l = cast(TEXT_LIST*)malloc(TEXT_LIST.sizeof);
            l.next = null;
            l.text = cast(char*)malloc(strlen(s) + 1);
            strcpy(l.text, s);

            if (sec.tail)
               sec.tail.next = l;
            else
               sec.head = l;

            sec.tail = l;
         }

         inblank = (s[0] == 0);
      }
   }

   pack_fclose(f);

   if (sect[2].head)
      end_text = format_text(sect[2].head, "\n", "");
   else
      end_text = null;

   title_size = strlen(intro_msg);

   for (i = 0; i < cast(int)(sect.sizeof / sect[0].sizeof); i++) {
      if (sect[i].head) {
         sect[i].flat = format_text(sect[i].head, " ", splitter);
         title_size += strlen(sect[i].flat) + strlen(sect[i].desc) +
             strlen(splitter) + strlen(marker) * 2 + 2;
      }
   }

   title_text = cast(char*)malloc(title_size + 1);
   title_alloced = true;

   strcpy(title_text, intro_msg);

   for (i = 0; i < cast(int)sect.sizeof / sect[0].sizeof; i++) {
      if (sect[i].flat) {
         strcat(title_text, marker);
         strcat(title_text, " ");
         strcat(title_text, sect[i].desc);
         strcat(title_text, " ");
         strcat(title_text, marker);
         strcat(title_text, splitter);
         strcat(title_text, sect[i].flat);
      }
   }

   for (i = 0; i < cast(int)sect.sizeof / sect[0].sizeof; i++) {
      l = sect[i].head;
      while (l) {
         free(l.text);
         p = l;
         l = l.next;
         free(p);
      }
      if (sect[i].flat)
         free(sect[i].flat);
   }
}



/* reads credit info from a source file */
extern (C)
private int parse_source(/*AL_CONST */char *filename, int attrib, void *param)
{
   char buf[256];
   PACKFILE *f;
   CREDIT_NAME *c;
   TEXT_LIST *d;
   char *p;

   if (attrib & FA_DIREC) {
      p = get_filename(filename);

      if ((ustricmp(p, ".") != 0) && (ustricmp(p, "..") != 0) &&
          (ustricmp(p, "lib") != 0) && (ustricmp(p, "obj") != 0)) {

         /* recurse inside a directory */
         strcpy(buf.ptr, filename);
         put_backslash(buf.ptr);
         strcat(buf.ptr, "*.*");

         for_each_file_ex(buf.ptr, 0, ~(FA_ARCH | FA_RDONLY | FA_DIREC),
                          &parse_source, param);
      }
   }
   else {
      p = get_extension(filename);

      if ((ustricmp(p, "c") == 0) || (ustricmp(p, "cpp") == 0) ||
          (ustricmp(p, "h") == 0) || (ustricmp(p, "inc") == 0) ||
          (ustricmp(p, "s") == 0) || (ustricmp(p, "asm") == 0)) {

         /* parse a source file */
         f = pack_fopen(filename, F_READ);
         if (!f)
            return -1;

         textprintf_centre_ex(screen, font, SCREEN_W / 2, SCREEN_H / 2 + 8,
                              makecol(160, 160, 160), 0,
                              "                %s                ",
                              filename + cast(int)(cast(ulong)param));

         while (pack_fgets(buf.ptr, buf.sizeof - 1, f) != null) {
            if (strstr(buf.ptr, "*/"))
               break;

            c = credits;

            while (c) {
               if (strstr(buf.ptr, c.name)) {
                  for (d = c.files; d; d = d.next) {
                     if (strcmp
                         (d.text,
                          filename + cast(int)(cast(ulong)param)) == 0)
                        break;
                  }

                  if (!d) {
                     d = cast(TEXT_LIST*)malloc(TEXT_LIST.sizeof);
                     d.text =
                         cast(char*)malloc(strlen
                                (filename + cast(int)cast(ulong)param) +
                                1);
                     strcpy(d.text, filename + cast(int)cast(ulong)param);
                     d.next = c.files;
                     c.files = d;
                  }
               }

               c = c.next;
            }
         }

         pack_fclose(f);
      }
   }

   return 0;
}



/* sorts a list of text strings */
private void sort_text_list(TEXT_LIST ** head)
{
   TEXT_LIST **prev;
   TEXT_LIST *p;
   int done;

   do {
      done = true;

      prev = head;
      p = *head;

      while ((p) && (p.next)) {
         if (ustricmp(p.text, p.next.text) > 0) {
            *prev = p.next;
            p.next = p.next.next;
            (*prev).next = p;
            p = *prev;

            done = false;
         }

         prev = &p.next;
         p = p.next;
      }

   } while (!done);
}



/* sorts a list of credit strings */
private void sort_credit_list()
{
   CREDIT_NAME **prev;
   CREDIT_NAME *p;
   TEXT_LIST *t;
   int n, done;

   do {
      done = true;

      prev = &credits;
      p = credits;

      while ((p) && (p.next)) {
         n = 0;

         for (t = p.files; t; t = t.next)
            n--;

         for (t = p.next.files; t; t = t.next)
            n++;

         if (n == 0)
            n = ustricmp(p.name, p.next.name);

         if (n > 0) {
            *prev = p.next;
            p.next = p.next.next;
            (*prev).next = p;
            p = *prev;

            done = false;
         }

         prev = &p.next;
         p = p.next;
      }

   } while (!done);
}



/* reads credit info from various places */
private void load_credits()
{
   static int once = false;
   char[256] buf, buf2;
   char* p, p2;
   CREDIT_NAME *c = null;
   PACKFILE *f;

   if (once)
      return;
   once = true;

   textout_centre_ex(screen, font, "Scanning for author credits...",
                     SCREEN_W / 2, SCREEN_H / 2 - 16, makecol(160, 160,
                                                              160), 0);

   load_text();

   /* Don't load top scroller with small screens. */
   if (SCREEN_W < 640)
      return;

   /* parse thanks._tx */
   get_executable_name(buf.ptr, buf.sizeof);
   replace_filename(buf2.ptr, buf.ptr, "../docs/src/thanks._tx", buf2.sizeof);

   f = pack_fopen(buf2.ptr, F_READ);
   if (!f)
      return;

   while (pack_fgets(buf.ptr, buf.sizeof - 1, f) != null) {
      if (ustricmp(buf.ptr, "Thanks!") == 0)
         break;

      while ((p = strstr(buf.ptr, "&lt")) != null) {
         *p = '<';
         memmove(p + 1, p + 3, strlen(p + 2));
      }

      while ((p = strstr(buf.ptr, "&gt")) != null) {
         *p = '>';
         memmove(p + 1, p + 3, strlen(p + 2));
      }

      p = buf.ptr;

      while ((*p) && (uisspace(*p)))
         p++;

      p2 = p;

      while ((*p2) && ((!uisspace(*p2)) || (*(p2 + 1) != '(')))
         p2++;

      if ((strncmp(p2, " (<email>", 9) == 0) ||
          (strncmp(p2, " (email", 7) == 0)) {
         *p2 = 0;

         c = cast(CREDIT_NAME*) malloc(CREDIT_NAME.sizeof);

         c.name = cast(char*)malloc(strlen(p) + 1);
         strcpy(c.name, p);

         c.text = null;
         c.files = null;

         c.next = credits;
         credits = c;
      }
      else if (*p) {
         if (c) {
            p2 = p + strlen(p) - 1;
            while ((p2 > p) && (uisspace(*p2)))
               *(p2--) = 0;

            if (c.text) {
               c.text = cast(char*)realloc(c.text, strlen(c.text) + strlen(p) + 2);
               strcat(c.text, " ");
               strcat(c.text, p);
            }
            else {
               c.text = cast(char*)malloc(strlen(p) + 1);
               strcpy(c.text, p);
            }
         }
      }
      else
         c = null;
   }

   pack_fclose(f);

   /* parse source files */
   get_executable_name(buf.ptr, buf.sizeof);
   replace_filename(buf2.ptr, buf.ptr, "../*.*", buf2.sizeof);

   for_each_file_ex(buf2.ptr, 0, ~(FA_ARCH | FA_RDONLY | FA_DIREC),
                    &parse_source,
                    cast(void *)cast(ulong)(strlen(buf2.ptr) - 3));

   /* sort the lists */
   sort_credit_list();

   for (c = credits; c; c = c.next) {
      sort_text_list(&c.files);
   }
}



private void scroller()
{
   int c, n;
   TEXT_LIST *tl;

   starfield_3d();

   /* move the scroller at the bottom */
   text_scroll++;

   /* update the credits position */
   if (credit_scroll <= 0) {
      if (credit_name)
         credit_name = credit_name.next;

      if (!credit_name)
         credit_name = credits;

      if (credit_name) {
         credit_width =
             text_length(cast(FONT*)datafile[TITLE_FONT].dat, credit_name.name) + 24;

         if (credit_name.text)
            credit_scroll = strlen(credit_name.text) * 8 + SCREEN_W -
               credit_width + 64;
         else
            credit_scroll = 256;

         tl = credit_name.files;
         n = 0;

         while (tl) {
            n++;
            tl = tl.next;
         }

         credit_offset = 0;

         if (n) {
            credit_skip = 1 + n / 50;
            credit_speed =
                8 + fixtoi(fixdiv(itofix(512), itofix(n)));
            if (credit_speed > 200)
               credit_speed = 200;
            c = 1024 + (n - 1) * credit_speed;
            if (credit_scroll < c) {
               credit_offset = credit_scroll - c;
               credit_scroll = c;
            }
         }

         credit_age = 0;
      }
   }
   else {
      credit_scroll--;
      credit_age++;
   }
}



private void draw_scroller(BITMAP *bmp)
{
   /* for the text scroller */
   char buf[2] = " \0";
   TEXT_LIST *tl;
   int n, n2, c, c2, c3;
   char *p;
   char cbuf[2] = " \0";
   FONT *bigfont = cast(FONT*)datafile[TITLE_FONT].dat;
   int th = text_height(bigfont);

   /* draw the text scroller at the bottom */
   blit(text_bmp, text_bmp, text_scroll, 0, 0, 0, SCREEN_W, th);
   rectfill(text_bmp, SCREEN_W - text_scroll, 0, SCREEN_W, th, 0);

   while (text_scroll > 0) {
      text_pix += text_scroll;
      if (text_char >= 0)
         buf[0] = title_text[text_char];
      textout_ex(text_bmp, bigfont, buf.ptr,
                 SCREEN_W - text_pix, 0, -1, 0);
      if (text_pix >= text_width) {
         text_scroll = text_pix - text_width;
         text_char++;
         if (text_char >= title_size)
            text_char = 0;
         buf[0] = title_text[text_char];
         text_pix = 0;
         text_width = text_length(cast(FONT*)datafile[TITLE_FONT].dat, buf.ptr);
      }
      else
         text_scroll = 0;
   }

   blit(text_bmp, bmp, 0, 0, 0, SCREEN_H - th, SCREEN_W, th);
   if (animation_type == ANIMATION_TYPE.DIRTY_RECTANGLE)
       dirty_rectangle(0, SCREEN_H - th, SCREEN_W, th);

   /* draw author file credits */
   if (credit_name) {
      int x, y, z;
      int ix, iy;
      tl = credit_name.files;
      n = credit_width;
      n2 = 0;

      while (tl) {
         c = 1024 + n2 * credit_speed - credit_age;

         if ((c > 0) && (c < 1024) && ((n2 % credit_skip) == 0)) {
            x = itofix(SCREEN_W / 2);
            y = itofix(SCREEN_H / 2 - 32);

            c2 = c * ((n / 13) % 17 + 1) / 32;
            if (n & 1)
               c2 = -c2;

            c2 -= 96;

            c3 = (32 +
                  fixtoi(ABS(fixsin(itofix(c / (15 + n % 42) + n))) *
                         128)) * SCREEN_W / 640;

            x += fixsin(itofix(c2)) * c3;
            y += fixcos(itofix(c2)) * c3;

            if (c < 512) {
               z = fixsqrt(itofix(c) / 512);

               x = fixmul(itofix(32), itofix(1) - z) + fixmul(x, z);
               y = fixmul(itofix(16), itofix(1) - z) + fixmul(y, z);
            }
            else if (c > 768) {
               z = fixsqrt(itofix(1024 - c) / 256);

               if (n & 2)
                  x = fixmul(itofix(128), itofix(1) - z) + fixmul(x, z);
               else
                  x = fixmul(itofix(SCREEN_W - 128),
                             itofix(1) - z) + fixmul(x, z);

               y = fixmul(itofix(SCREEN_H - 128),
                          itofix(1) - z) + fixmul(y, z);
            }

            c = 128 + (512 - ABS(512 - c)) / 24;
            c = cast(int)MIN(255, c * 1.25);

            ix = fixtoi(x);
            iy = fixtoi(y);

            c2 = strlen(tl.text);
            ix -= c2 * 4;

            textout_ex(bmp, font, tl.text, ix, iy, c, 0);
            if (animation_type == ANIMATION_TYPE.DIRTY_RECTANGLE)
               dirty_rectangle(ix, iy, c2 * 8, 8);
         }

         tl = tl.next;
         n += 1234567;
         n2++;
      }
   }

   draw_starfield_3d(bmp);

   /* draw author name/desc credits */
   if (credit_name) {
      if (credit_name.text) {
         c = credit_scroll + credit_offset;
         p = credit_name.text;
         c2 = strlen(p);

         if (c > 0) {
            if (c2 > c / 8) {
               p += c2 - c / 8;
               c &= 7;
            }
            else {
               c -= c2 * 8;
            }

            c += credit_width;

            while ((*p) && (c < SCREEN_W - 32)) {
               if (c < credit_width + 96)
                  c2 = 128 + (c - credit_width - 32) * 127 / 64;
               else if (c > SCREEN_W - 96)
                  c2 = 128 + (SCREEN_W - 32 - c) * 127 / 64;
               else
                  c2 = 255;

               if ((c2 > 128) && (c2 <= 255)) {
                  cbuf[0] = *p;
                  textout_ex(bmp, font, cbuf.ptr, c, 16, c2, 0);
               }

               p++;
               c += 8;
            }
         }
      }

      c = 4;

      if (credit_age < 100)
         c -= (100 - credit_age) * (100 -
                                    credit_age) * credit_width / 10000;

      if (credit_scroll < 150)
         c += (150 - credit_scroll) * (150 -
                                       credit_scroll) * SCREEN_W /
             22500;

      textprintf_ex(bmp, cast(FONT*)datafile[TITLE_FONT].dat, c, 4, -1, 0, "%s:",
                    credit_name.name);
      if (animation_type == ANIMATION_TYPE.DIRTY_RECTANGLE)
         dirty_rectangle(0, 4, SCREEN_W, text_height(cast(FONT*)datafile[TITLE_FONT].dat));
   }

   /* draw the Allegro logo over the top */
   draw_sprite(bmp, cast(BITMAP*)datafile[TITLE_BMP].dat, SCREEN_W / 2 - 160,
               SCREEN_H / 2 - 96);
}



/* displays the title screen */
int title_screen()
{
   static int color = 0;
   int c;
   BITMAP *bmp;
   RGB rgb;
   int updated;
   int scroll_pos = 0;

   text_scroll = 0;
   credit_width = 0;
   credit_scroll = 0;
   credit_offset = 0;
   credit_age = 0;
   credit_speed = 32;
   credit_skip = 1;

   text_char = -1;
   text_pix = 0;
   text_width = 0;
   text_bmp = create_bitmap(SCREEN_W, 24);
   clear_bitmap(text_bmp);

   play_midi(cast(MIDI*)datafile[TITLE_MUSIC].dat, true);
   play_sample(cast(SAMPLE*)datafile[WELCOME_SPL].dat, 255, 127, 1000, false);

   load_credits();

   init_starfield_3d();

   for (c = 0; c < 8; c++)
      title_palette[c] = (cast(RGB *) datafile[TITLE_PAL].dat)[c];

   /* set up the colors differently each time we display the title screen */
   for (c = 8; c < PAL_SIZE / 2; c++) {
      rgb = (cast(RGB *) datafile[TITLE_PAL].dat)[c];
      switch (color) {
         case 0:
            rgb.b = rgb.r;
            rgb.r = 0;
            break;
         case 1:
            rgb.g = rgb.r;
            rgb.r = 0;
            break;
         case 3:
            rgb.g = rgb.r;
            break;
         default:
            break;
      }
      title_palette[c] = rgb;
   }

   for (c = PAL_SIZE / 2; c < PAL_SIZE; c++)
      title_palette[c] = (cast(RGB *) datafile[TITLE_PAL].dat)[c];

   color++;
   if (color > 3)
      color = 0;

   clear_display();

   set_palette(title_palette);

   //LOCK_VARIABLE(scroll_count);
   //LOCK_FUNCTION(scroll_counter);
   scroll_count = 1;
   install_int(&scroll_counter, 5);

   volatile while ((c = scroll_count) < 160)
      stretch_blit(cast(BITMAP*)datafile[TITLE_BMP].dat, screen, 0, 0, 320, 128,
                   SCREEN_W / 2 - c, SCREEN_H / 2 - c * 64 / 160 - 32,
                   c * 2, c * 128 / 160);

   remove_int(&scroll_counter);

   blit(cast(BITMAP*)datafile[TITLE_BMP].dat, screen, 0, 0, SCREEN_W / 2 - 160,
        SCREEN_H / 2 - 96, 320, 128);

   clear_keybuf();

   scroll_count = 0;

   install_int(&scroll_counter, 6);

   do {
      updated = 0;
      volatile while (scroll_pos <= scroll_count) {
         scroller();
         scroll_pos++;
         updated = 1;
      }

      if (max_fps || updated) {
         bmp = prepare_display();
         draw_scroller(bmp);
         flip_display();
      }

      /* rest for a short while if we're not in CPU-hog mode and too fast */
      if (!max_fps && !updated) {
         rest(1);
      }

      poll_joystick();

   } while ((!keypressed()) && (!joy[0].button[0].b)
            && (!joy[0].button[1].b));

   remove_int(&scroll_counter);

   fade_out(5);

   destroy_bitmap(text_bmp);

   while (keypressed())
      if ((readkey() & 0xff) == 27)
         return false;

   return true;
}



void end_title()
{
   CREDIT_NAME *cred;
   TEXT_LIST *tl;

   if (end_text) {
      allegro_message("%shttp://alleg.sourceforge.net/\n\n", end_text);
      free(end_text);
   }

   if ((title_text) && (title_alloced))
      free(title_text);

   while (credits) {
      cred = credits;
      credits = cred.next;

      if (cred.name)
         free(cred.name);

      if (cred.text)
         free(cred.text);

      while (cred.files) {
         tl = cred.files;
         cred.files = tl.next;

         if (tl.text)
            free(tl.text);

         free(tl);
      }

      free(cred);
   }
}

