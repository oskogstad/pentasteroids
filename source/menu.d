import everything;

enum MenuItem
{
	START,
	HIGHSCORE,
	CREDITS,
	QUIT
}

SDL_Texture*[string] menuGFX;
ubyte menuSFXVolume = 60;

int 
	menuSFXIndexOne, 
	menuSFXIndexTwo, 
	menuSFXIndexThree;

SDL_Rect* menuRect;
Mix_Chunk*[] menuSFX;

int selectedIndex;
int spacing = 100;

void setup()
{	    
	selectedIndex = MenuItem.START;

	menuRect = new SDL_Rect();

	foreach(path; dirEntries("img/menu/", SpanMode.depth))
	{
		string chomp = chomp(path, ".png");
		chomp = chompPrefix(chomp, "img/menu/");
		menuGFX[chomp] = IMG_LoadTexture(renderer, path.toStringz());
	}
	foreach(sfx; menuGFX) assert(sfx);

	app.loadSFXFromDisk("sfx/menuScale/", menuSFX);
	foreach(sfx;menuSFX) 
	{
		assert(sfx);
		sfx.volume = menuSFXVolume;
	}
}

void playSFX()
{
	menuSFXIndexOne = uniform(0, 4);
	menuSFXIndexTwo = uniform(4, 8);
	menuSFXIndexThree = uniform(8, 11); // last one cut, a bit dist ---------------------------------------------------------

	Mix_PlayChannel(-1, menuSFX[menuSFXIndexOne], 0);
	Mix_PlayChannel(-1, menuSFX[menuSFXIndexTwo], 0);
	Mix_PlayChannel(-1, menuSFX[menuSFXIndexThree], 0);
}

void handleInput(SDL_Event event)
{
	playSFX();

	switch(event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
		{
			running = false;
			break;
		}

		case SDLK_RETURN:
		{
			switch(selectedIndex) with (MenuItem)
			{
				case START:
				app.state = AppState.GAME;
				game.gameInProgress = true;
				break;

				case HIGHSCORE:
				app.state = AppState.HIGHSCORE;
				break;

				case CREDITS:
				break;

				case QUIT:
				app.running = false;
				break;  

				default:
				break;                                
			}
			break;
		}

		case SDLK_w:
		case SDLK_UP:
		{
			if(--selectedIndex < MenuItem.min) selectedIndex = MenuItem.max;
			break;	
		}


		case SDLK_s:
		case SDLK_DOWN:
		{
			if(++selectedIndex > MenuItem.max) selectedIndex = MenuItem.min;
			break;
		}

		default:
		break;
	}
}


void drawMenuItem(string item, string item_, bool condition)
{
	if(condition)
	{
		SDL_RenderCopy(renderer, menuGFX[item], null, menuRect);
	}
	else
	{
		SDL_RenderCopy(renderer, menuGFX[item_], null, menuRect);	
	}
}

void updateAndDraw()
{
	menuRect.w = app.currentDisplay.w; menuRect.h = 160; 
	menuRect.x = 0; menuRect.y = 450;
	SDL_RenderCopy(renderer, menuGFX["logo"], null, menuRect);

	menuRect.h = spacing;
	menuRect.y = 650;

	if(selectedIndex == MenuItem.START)
	{
		drawMenuItem("continue", "start", game.gameInProgress);
	}
	else 
	{
		drawMenuItem("continue_", "start_", game.gameInProgress);
	}

	menuRect.y += spacing;
	drawMenuItem("highscore", "highscore_", selectedIndex == MenuItem.HIGHSCORE);

	menuRect.y += spacing;
	drawMenuItem("credits", "credits_", selectedIndex == MenuItem.CREDITS);         

	menuRect.y += spacing;
	drawMenuItem("quit", "quit_", selectedIndex == MenuItem.QUIT);  
}
