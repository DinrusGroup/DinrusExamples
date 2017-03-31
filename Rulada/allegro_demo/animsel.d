import derelict.allegro.all;
import display;
import demo;


/* d_list_proc() callback for the animation mode dialog */
private extern (C) char *anim_list_getter(int index, int *list_size)
{
   static char *s[4] = [
      "Double buffered",
      "Page flipping",
      "Triple buffered",
      "Dirty rectangles"
   ];

   if (index < 0) {
      *list_size = s.sizeof / s[0].sizeof;
      return null;
   }

   return s[index];
}



private DIALOG anim_type_dlg[] = [
   /* (dialog proc)     (x)   (y)   (w)   (h)   (fg)  (bg)  (key) (flags)     (d1)  (d2)  (dp)                 (dp2) (dp3) */
   {&d_shadow_box_proc, 0, 0, 281, 151, 0, 1, 0, 0, 0, 0, null, null, null},
   {&d_ctext_proc, 140, 8, 1, 1, 0, 1, 0, 0, 0, 0, "Animation Method".ptr, null,
    null},
   {&anim_list_proc, 16, 28, 153, 36, 0, 1, 0, D_EXIT, 3, 0,
    &anim_list_getter, null, null},
   {&d_check_proc, 16, 70, 248, 12, 0, 0, 0, 0, 0, 0, "Maximum FPS (uses 100% CPU)".ptr, null, null},
   {&anim_desc_proc, 16, 90, 248, 48, 0, 1, 0, 0, 0, 0, null, null, null},
   {&d_button_proc, 184, 28, 80, 16, 0, 1, 0, D_EXIT, 0, 0, "OK".ptr, null,
    null},
   {&d_button_proc, 184, 50, 80, 16, 0, 1, 27, D_EXIT, 0, 0, "Cancel".ptr, null,
    null},
   {&d_yield_proc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, null},
   {null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, null}
];



extern (C)
private int anim_list_proc(int msg, DIALOG * d, int c)
{
   int sel, ret;

   sel = d.d1;

   ret = d_list_proc(msg, d, c);

   if (sel != d.d1)
      ret |= D_REDRAW;

   return ret;
}



/* dialog procedure for the animation type dialog */
private extern (C) int anim_desc_proc(int msg, DIALOG * d, int c)
{
   static char *double_buffer_desc[5] = [
      "Draws onto a memory bitmap,",
      "and then uses a brute-force",
      "blit to copy the entire",
      "image across to the screen.",
      null
   ];

   static char *page_flip_desc[7] = [
      "Uses two pages of video",
      "memory, and flips back and",
      "forth between them. It will",
      "only work if there is enough",
      "video memory to set up dual",
      "pages.",
      null
   ];

   static char *triple_buffer_desc[6] = [
      "Uses three pages of video",
      "memory, to avoid wasting time",
      "waiting for retraces. Only",
      "some drivers and hardware",
      "support this.",
      null
   ];

   static char *dirty_rectangle_desc[7] = [
      "This is similar to double",
      "buffering, but stores a list",
      "of which parts of the screen",
      "have changed, to minimise the",
      "amount of drawing that needs",
      "to be done.",
      null
   ];

   static char **descs[4] = [
      double_buffer_desc.ptr,
      page_flip_desc.ptr,
      triple_buffer_desc.ptr,
      dirty_rectangle_desc.ptr
   ];

   char **p;
   int y;

   if (msg == MSG_DRAW) {
      rectfill(screen, d.x, d.y, d.x + d.w, d.y + d.h, d.bg);

      p = descs[anim_type_dlg[2].d1];
      y = d.y;

      while (*p) {
         textout_ex(screen, font, *p, d.x, y, d.fg, d.bg);
         y += 8;
         p++;
      }
   }

   return D_O_K;
}



/* allows the user to choose an animation type */
int pick_animation_type(ANIMATION_TYPE *type)
{
   int ret;

   centre_dialog(anim_type_dlg.ptr);

   clear_bitmap(screen);

   /* we set up colors to match screen color depth */
   for (ret = 0; anim_type_dlg[ret].proc; ret++) {
      anim_type_dlg[ret].fg = palette_color[0];
      anim_type_dlg[ret].bg = palette_color[1];
   }

   ret = do_dialog(anim_type_dlg.ptr, 2);

   *type = cast(ANIMATION_TYPE)(anim_type_dlg[2].d1 + 1);
   max_fps = (anim_type_dlg[3].flags & D_SELECTED) != 0;

   assert(*type >= ANIMATION_TYPE.DOUBLE_BUFFER &&
                  *type <= ANIMATION_TYPE.DIRTY_RECTANGLE);

   return (ret == 6) ? -1 : ret;
}
