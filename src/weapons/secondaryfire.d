import everything;

bool secondaryFire;
SDL_Rect sfSRect, sfDRect;
SDL_Texture* sfGFX;
float fuel;
uint sfSprite;

const int SF_NUM_FRAMES = 14;

void setup()
{
	fuel = 180;
	
	sfGFX = IMG_LoadTexture(renderer, "img/secondaryFire.png");
	assert(sfGFX);
	
	sfDRect.w = cast(int)(2300 * app.xScale);
	sfDRect.h = 200;
	
	sfSRect.w = 2300; 
	sfSRect.h = 200;
	sfSRect.x = 0;

	sfDRect.x = 1;
	sfDRect.y = 1;
}

void updateAndDraw()
{
	if(secondaryFire && fuel > 0)
	{
		sfSprite = (app.ticks/25) % SF_NUM_FRAMES;
		sfSRect.y = sfSprite * 200;
 		
 		float s = sin(angle);
  		float c = cos(angle);
		
		//sfDRect.x = -player.xPos;
		//sfDRect.y = -player.yPos;
		
		float xnew = sfDRect.x * c - sfDRect.y * s;
  		float ynew = sfDRect.x * s + sfDRect.y * c;

  		sfDRect.x = cast(int)xnew;
  		sfDRect.y = cast(int)ynew;
		SDL_Point p; p.x = player.xPos; p.y = player.yPos;
		SDL_RenderCopyEx(renderer, sfGFX, &sfSRect, &sfDRect, angle*TO_DEG, &p, 0);
		//fuel-=0.1f;
	}	
}