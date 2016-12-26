module menu;
import app;
import game;

enum MenuItem
{
	START,
	HIGHSCORE,
	CREDITS,
	QUIT
}

SDL_Texture*[string] menuGFX;
int menuSFXIndexOne, menuSFXIndexTwo, menuSFXIndexThree;
SDL_Rect* menuRect;
Mix_Chunk*[] menuSFX;
int selectedIndex;
int spacing = 100;

void setup(SDL_Renderer* renderer)
{	    
	selectedIndex = MenuItem.START;

	menuRect = new SDL_Rect();

	foreach(path; dirEntries("img/menu/", SpanMode.depth))
	{
		string chomp = chomp(path, ".png");
		chomp = chompPrefix(chomp, "img/menu/");
		menuGFX[chomp] = IMG_LoadTexture(renderer, path.toStringz());
	}
	foreach(a; menuGFX){assert(a);}


	foreach(path; dirEntries("sfx/menuScale/", SpanMode.depth))
	{
		menuSFX ~= Mix_LoadWAV(path.toStringz());
	}
	foreach(a;menuSFX){assert(a);}
}

void playSFX()
{
	menuSFXIndexOne = uniform(0, 4);
	menuSFXIndexTwo = uniform(4, 8);
	menuSFXIndexThree = uniform(8, 12);

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
			switch(selectedIndex)
			{
				case MenuItem.START:
				app.state = AppState.GAME;
				game.gameInProgress = true;
				break;

				case MenuItem.HIGHSCORE:
				break;

				case MenuItem.CREDITS:
				break;

				case MenuItem.QUIT:
				running = false;
				break;  

				default:
				break;                                
			}
			break;
		}

		case SDLK_w:
		case SDLK_UP:
		if(--selectedIndex < 0) selectedIndex = MenuItem.QUIT;
		break;

		case SDLK_s:
		case SDLK_DOWN:
		if(++selectedIndex > 3) selectedIndex = MenuItem.START;
		break;

		default:
		break;
	}
}

void updateAndDraw(SDL_Renderer* renderer)
{
	menuRect.w = app.currentDisplay.w; menuRect.h = 160; 
	menuRect.x = 0; menuRect.y = 450;
	SDL_RenderCopy(renderer, menuGFX["logo"], null, menuRect);

	menuRect.h = spacing;

	menuRect.y = 650;
	if(selectedIndex == MenuItem.START)
	{
		if(game.gameInProgress)
		{
			SDL_RenderCopy(renderer, menuGFX["continue"], null, menuRect);
		}
		else
		{
			SDL_RenderCopy(renderer, menuGFX["start"], null, menuRect);
		}
	}
	else 
	{
		if(game.gameInProgress)
		{
			SDL_RenderCopy(renderer, menuGFX["continue_"], null, menuRect);
		}
		else
		{
			SDL_RenderCopy(renderer, menuGFX["start_"], null, menuRect);
		}
	}

	menuRect.y += spacing;

	if(selectedIndex == MenuItem.HIGHSCORE)
	{
		SDL_RenderCopy(renderer, menuGFX["highscore"], null, menuRect);
	}
	else
	{
		SDL_RenderCopy(renderer, menuGFX["highscore_"], null, menuRect);
	}


	menuRect.y += spacing;

	if(selectedIndex == MenuItem.CREDITS)
	{
		SDL_RenderCopy(renderer, menuGFX["credits"], null, menuRect);
	}
	else
	{
		SDL_RenderCopy(renderer, menuGFX["credits_"], null, menuRect);
	}            

	menuRect.y += spacing;

	if(selectedIndex == MenuItem.QUIT)
	{
		SDL_RenderCopy(renderer, menuGFX["quit"], null, menuRect);
	}
	else
	{
		SDL_RenderCopy(renderer, menuGFX["quit_"], null, menuRect);
	}     
}
