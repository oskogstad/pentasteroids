import app;

bool playedSFX = false;
Mix_Chunk* gameOverSFX;
ubyte fadeScreenAlpha, continueAlpha;
SDL_Texture* continueTexture, fadeScreen;
SDL_Rect* fadeScreenRect, continueRect;

void setup(SDL_Renderer* renderer)
{	
	gameOverSFX = Mix_LoadWAV("sfx/game_over.wav");
	assert(gameOverSFX);

	fadeScreen = IMG_LoadTexture(renderer, "img/fade_screen.png");
	assert(fadeScreen);

	continueTexture = IMG_LoadTexture(renderer, "img/continue.png");

	fadeScreenRect = new SDL_Rect();
	fadeScreenRect.w = app.currentDisplay.w;
	fadeScreenRect.h = app.currentDisplay.h;
	fadeScreenRect.x = 0;
	fadeScreenRect.y = 0;

	continueRect = new SDL_Rect();
	continueRect.w = app.currentDisplay.w;
	continueRect.h = 100; // magic!
	continueRect.x = 0;
	continueRect.y = 650;

	fadeScreenAlpha = 0;
	continueAlpha = 0;
}

void updateAndDraw(SDL_Renderer* renderer)
{
	if(!playedSFX)
	{
		Mix_PlayChannel(-1, gameOverSFX, 0);
		playedSFX = true;
	}

	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayBottom, null, player.dyingOverlayRect);
	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayMiddle, null, player.dyingOverlayRect);
	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayTop, null, player.dyingOverlayRect);
	
	if(fadeScreenAlpha != 255) fadeScreenAlpha += 5;

	SDL_SetTextureAlphaMod(fadeScreen, fadeScreenAlpha);
	SDL_RenderCopy(renderer, fadeScreen, null, fadeScreenRect);

	if(fadeScreenAlpha > 200)
	{
		if(continueAlpha != 250) continueAlpha += 10;
	}
	SDL_SetTextureAlphaMod(continueTexture, continueAlpha);
	SDL_RenderCopy(renderer, continueTexture, null, continueRect);
}