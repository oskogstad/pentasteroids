module game;
import app;
import world;
import primaryfire;
import player;
import menu;
import orbs;
import stars;

bool angleMode = false;
double angle;
bool gameInProgress = false;

void setup(SDL_Renderer *renderer)
{
	world.setup(renderer);
	
	orbs.setup(renderer);

	player.setup(renderer);
	primaryfire.setup(renderer);
}

void updateAndDraw(SDL_Renderer *renderer)
{
	if(angleMode)
	{
		angle = atan2(cast(float)(currentDisplay.h/2) - spaceShipY, cast(float)(currentDisplay.w/2) - spaceShipX);
	}
	else
	{
		angle = atan2(cast(float) mouseY - spaceShipY, cast(float) mouseX - spaceShipX);
	}

	primaryfire.updateAndDraw(renderer);
	orbs.updateAndDraw(renderer);
	player.updateAndDraw(renderer);
}

void handleInput(SDL_Event event)
{
	switch(event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
		app.state = AppState.MENU;
		menu.selectedIndex = MenuItem.START; 
		break;

		case SDLK_k:
		angleMode = !angleMode;
		break;

		default:
		break;           
	}
}

