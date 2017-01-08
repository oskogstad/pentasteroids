import everything;

ulong currentScore = 0;
SDL_Texture* texture;
SDL_Rect* scoRect;
SDL_Color color = { 255, 255, 255, 0 };

void setup()
{
	scoRect = new SDL_Rect();
}

void updateAndDraw()
{
	currentScore++;
	scoRect.x = 20; scoRect.y = 20;
	app.createTexture(renderer, scoRect.w, scoRect.h, to!string(currentScore), app.fontMedium, &texture, color);
	SDL_RenderCopy(renderer, texture, null, scoRect);
}

void addOrbHitScore(Size size)
{
	if(size == Size.SMALL)
	{
		currentScore += uniform(250000, 500000);
	}
	else if(size == Size.MEDIUM)
	{
		currentScore += uniform(10000000, 20000000);
	}
	else
	{
		currentScore += uniform(200000000, 300000000);
	}
}