version (Tango)
   import tango.stdc.stdlib;
else
   import std.c;

import derelict.allegro.all;
import demo;
import game;
import aster;
import data;
import dirty;
import display;


struct BULLET {
   int x;
   int y;
   BULLET *next;
}

/* position of the bullets */
const int BULLET_SPEED  = 6;

BULLET *bullet_list;

/* add a bullet to the list */
BULLET *add_bullet(int x, int y)
{
   BULLET* iter, bullet;

   bullet = cast(BULLET *) malloc(BULLET.sizeof);
   bullet.x = x;
   bullet.y = y;
   bullet.next = null;

   /* special treatment for head */
   if (!bullet_list) {
      bullet_list = bullet;
   }
   else {
      for (iter = bullet_list; iter.next; iter = iter.next) {
      }

      iter.next = bullet;
   }

   return bullet;
}



/* delete a bullet and return the next in the list */
BULLET *delete_bullet(BULLET * bullet)
{
   BULLET *iter;

   /* special treatment for head */
   if (bullet == bullet_list) {
      bullet_list = bullet.next;
      free(bullet);
      return bullet_list;
   }
   else {
      for (iter = bullet_list; iter.next != bullet; iter = iter.next) {
      }

      iter.next = bullet.next;
      free(bullet);
      return iter.next;
   }
}



void move_bullets()
{
   BULLET *bullet = bullet_list;
   while (bullet) {
      bullet.y -= BULLET_SPEED;

      /* if the bullet is at the top of the screen, delete it */
      if (bullet.y < 8) {
         bullet = delete_bullet(bullet);
         goto bullet_updated;
      }
      else {

         /* shot an asteroid? */
         if (asteroid_collision(bullet.x, bullet.y, 20)) {
            score += 10;
            play_sample(cast(SAMPLE*)datafile[BOOM_SPL].dat, 255, PAN(bullet.x), 1000, FALSE);
            /* delete the bullet that killed the alien */
            bullet = delete_bullet(bullet);
            goto bullet_updated;
         }
      }

      bullet = bullet.next;

      bullet_updated:;
   }
}



void draw_bullets(BITMAP *bmp)
{
   BULLET *bullet;
   for (bullet = bullet_list; bullet; bullet = bullet.next) {
      int x = bullet.x;
      int y = bullet.y;

      RLE_SPRITE *spr = cast(RLE_SPRITE*)datafile[ROCKET].dat;
      draw_rle_sprite(bmp, spr, x - spr.w / 2, y - spr.h / 2);
      if (animation_type == ANIMATION_TYPE.DIRTY_RECTANGLE)
         dirty_rectangle(x - spr.w / 2, y - spr.h / 2, spr.w, spr.h);
   }
}