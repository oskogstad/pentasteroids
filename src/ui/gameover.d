import everything;

bool playedSFX = false;
Mix_Chunk* gameOverSFX;
ubyte fadeScreenAlpha, continueAlpha;
SDL_Texture* continueTexture, fadeScreen, finalScore;
SDL_Rect* fadeScreenRect, continueRect, finalScoRect;

void setup()
{	
	gameOverSFX = Mix_LoadWAV("sfx/game_over.wav");
	assert(gameOverSFX);

	fadeScreen = IMG_LoadTexture(renderer, "img/fade_screen.png");
	assert(fadeScreen);

	continueTexture = IMG_LoadTexture(renderer, "img/menu/anykey.png");

	fadeScreenRect = new SDL_Rect();
	fadeScreenRect.w = app.display_width;
	fadeScreenRect.h = app.display_height;
	fadeScreenRect.x = 0;
	fadeScreenRect.y = 0;

	continueRect = new SDL_Rect();
	continueRect.w = app.display_width;
	continueRect.h = 100; // magic!
	continueRect.x = 0;
	continueRect.y = 650;

	fadeScreenAlpha = 0;
	continueAlpha = 0;

	finalScoRect = new SDL_Rect();
}

void updateAndDraw()
{
	if(highscore.checkScore(score.currentScore)) 
	{
		app.state = AppState.ENTER_NAME;
		return;
	}
	
	if(!playedSFX)
	{
		Mix_FadeOutChannel(1, 250);
		Mix_PlayChannel(2, gameOverSFX, 0);
		utils.createTexture(renderer, finalScoRect.w, finalScoRect.h, 
			"Score: " ~ to!string(currentScore), 
			app.fontMedium, &finalScore, score.color);
		assert(finalScore);
		finalScoRect.x = app.middleX - finalScoRect.w/2;
		finalScoRect.y = 400;		
		playedSFX = true;
	}

	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayBottom, null, &player.dyingOverlayRect);
	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayMiddle, null, &player.dyingOverlayRect);
	player.dyingOverlayRect.x = uniform(-3, 1);
	player.dyingOverlayRect.y = uniform(-3, 1);
	SDL_RenderCopy(renderer, player.dyingOverlayTop, null, &player.dyingOverlayRect);
	
	if(fadeScreenAlpha != 255) fadeScreenAlpha += 5;

	SDL_SetTextureAlphaMod(fadeScreen, fadeScreenAlpha);
	SDL_RenderCopy(renderer, fadeScreen, null, fadeScreenRect);

	if(fadeScreenAlpha > 200)
	{
		if(continueAlpha != 250) continueAlpha += 10;
	}

	SDL_SetTextureAlphaMod(continueTexture, continueAlpha);
	SDL_RenderCopy(renderer, continueTexture, null, continueRect);
	
	SDL_SetTextureAlphaMod(finalScore, continueAlpha);
	SDL_RenderCopy(renderer, finalScore, null, finalScoRect);
}
