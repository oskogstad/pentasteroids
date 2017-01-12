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
}

void updateAndDraw()
{
	if(secondaryFire && fuel > 0)
	{
		sfSprite = (app.ticks/25) % SF_NUM_FRAMES; // /25 for slowing down animation
		sfSRect.y = sfSprite * 200; // 200 height of texture-----------------------------------------------------------------------------------------
		
		sfDRect.x = player.xPos;
		sfDRect.y = player.yPos - sfDRect.h/2;
		
		SDL_Point p; p.x = 0 ; p.y = sfDRect.h/2;

		SDL_RenderCopyEx(renderer, sfGFX, &sfSRect, &sfDRect, angle*TO_DEG, &p, 0);
		//fuel-=1f;
	}	
}