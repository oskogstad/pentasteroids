import everything;

BigInt currentScore = 0;
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
	utils.createTexture(renderer, scoRect.w, scoRect.h, currentScore.toHex(), app.fontMedium, &texture, color);
	SDL_RenderCopy(renderer, texture, null, scoRect);
}

void addOrbHitScore(Size size)
{
	if(size == Size.SMALL)
	{
		currentScore += uniform(25, 50);
	}
	else if(size == Size.MEDIUM)
	{
		currentScore += uniform(1000, 2000);
	}
	else
	{
		currentScore += uniform(20000, 30000);
	}
}