import derelict.allegro.all;
import game;
import expl;
import demo;
import demo;
import data;
import display;
import dirty;


/* info about the asteroids (they used to be asteroids at least,
 * even if the current graphics look more like asteroids :-) 
 */
const int MAX_ASTEROIDS     = 50;

struct ASTEROID {
   int x, y;
   int d;
   int state;
   int shot;
}

/*volatile*/ ASTEROID asteroid[MAX_ASTEROIDS];

private int asteroid_count;


void init_asteroids()
{
   int c;
   for (c = 0; c < MAX_ASTEROIDS; c++) {
      asteroid[c].x = 16 + AL_RAND() % (SCREEN_W - 32);
      asteroid[c].y = -60 - (AL_RAND() & 0x3f);
      asteroid[c].d = (AL_RAND() & 1) ? 1 : -1;
      asteroid[c].state = -1;
      asteroid[c].shot = FALSE;
   }
   asteroid_count = 2;
}



void scroll_asteroids()
{
   int c;
   for (c = 0; c < asteroid_count; c++)
      asteroid[c].y++;
}



void add_asteroid()
{
   if (asteroid_count < MAX_ASTEROIDS)
      asteroid_count++;
}



void move_asteroids()
{
   int c;
   for (c = 0; c < asteroid_count; c++) {
      if (asteroid[c].shot) {
         /* dying asteroid */
         if (skip_count <= 0) {
            if (asteroid[c].state < EXPLODE_FLAG + EXPLODE_FRAMES - 1) {
               asteroid[c].state++;
               if (asteroid[c].state & 1)
                  asteroid[c].x += asteroid[c].d;
            }
            else {
               asteroid[c].x = 16 + AL_RAND() % (SCREEN_W - 32);
               asteroid[c].y = -60 - (AL_RAND() & 0x3f);
               asteroid[c].d = (AL_RAND() & 1) ? 1 : -1;
               asteroid[c].shot = FALSE;
               asteroid[c].state = -1;
            }
         }
      }
      else {
         /* move asteroid sideways */
         asteroid[c].x += asteroid[c].d;
         if (asteroid[c].x < -60)
            asteroid[c].x = SCREEN_W;
         else if (asteroid[c].x > SCREEN_W + 60)
            asteroid[c].x = -60;
      }

      /* move asteroid vertically */
      asteroid[c].y += 1;

      if (asteroid[c].y > SCREEN_H + 30) {
         if (!asteroid[c].shot) {
            asteroid[c].x = AL_RAND() % (SCREEN_W - 32);
            asteroid[c].y = -32 - (AL_RAND() & 0x3f);
            asteroid[c].d = (AL_RAND() & 1) ? 1 : -1;
         }
      }
      else {
         /* asteroid collided with player? */
         if ((ABS(asteroid[c].x - (player_x_pos >> SPEED_SHIFT)) < 48)
             && (ABS(asteroid[c].y - (SCREEN_H - 42)) < 32)) {
            if ((!player_hit) && (!asteroid[c].shot)) {
               if (!cheat) {
                  ship_state = EXPLODE_FLAG;
                  player_hit = TRUE;
               }
               if ((!cheat) || (!asteroid[c].shot))
                  play_sample(cast(SAMPLE*)datafile[DEATH_SPL].dat, 255,
                     PAN(player_x_pos >> SPEED_SHIFT), 1000, FALSE);
            }
            if (!asteroid[c].shot) {
               asteroid[c].shot = TRUE;
               asteroid[c].state = EXPLODE_FLAG;
            }
         }
      }
   }
}



int asteroid_collision(int x, int y, int s)
{
   int i;
   for (i = 0; i < asteroid_count; i++) {
      if ((ABS(y - asteroid[i].y) < s)
         && (ABS(x - asteroid[i].x) < s)
         && (!asteroid[i].shot)) {
         asteroid[i].shot = TRUE;
         asteroid[i].state = EXPLODE_FLAG;
         return 1;
      }
   }
   return 0;
}



void draw_asteroids(BITMAP *bmp)
{
   int i, j, c, x, y;
   RLE_SPRITE *spr;
   for (c = 0; c < asteroid_count; c++) {
      x = asteroid[c].x;
      y = asteroid[c].y;

      if (asteroid[c].state >= EXPLODE_FLAG) {
         spr = explosion[asteroid[c].state - EXPLODE_FLAG];
      }
      else {
         switch (c % 3) {
            case 0:
               i = ASTA01;
               break;
            case 1:
               i = ASTB01;
               break;
            case 2:
               i = ASTC01;
               break;
            default:
               i = 0;
               break;
         }
         j = (retrace_count / (6 - (c & 3)) + c) % 15;
         if (c & 1)
            spr = cast(RLE_SPRITE *) datafile[i + 14 - j].dat;
         else
            spr = cast(RLE_SPRITE *) datafile[i + j].dat;
      }

      draw_rle_sprite(bmp, spr, x - spr.w / 2, y - spr.h / 2);
      if (animation_type == ANIMATION_TYPE.DIRTY_RECTANGLE)
         dirty_rectangle(x - spr.h / 2, y - spr.h / 2, spr.w,
            spr.h);
   }
}
