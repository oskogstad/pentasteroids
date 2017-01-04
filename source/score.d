import app;

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