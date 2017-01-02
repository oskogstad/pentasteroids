import app;

long currentScore = 0;
SDL_Texture* texture;
SDL_Rect* scoRect;
SDL_Color color = { 255, 255, 255, 0 };

void setup()
{
	scoRect = new SDL_Rect();
}

void updateAndDraw(SDL_Renderer* renderer)
{
	currentScore++;
	app.createTexture(renderer, 20, 20, to!string(currentScore), app.fontMedium, &texture, scoRect, color);
	SDL_RenderCopy(renderer, texture, null, scoRect);
}