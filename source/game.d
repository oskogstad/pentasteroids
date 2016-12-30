module game;
import app;

bool angleMode = false;
double angle;
bool gameInProgress = false;

void setup(SDL_Renderer *renderer)
{
	world.setup(renderer);
	
	orbs.setup(renderer);

	player.setup(renderer);
	primaryfire.setup(renderer);
	ringblasts.setup(renderer);
}

void updateAndDraw(SDL_Renderer *renderer)
{
	if(angleMode)
	{
		angle = atan2(cast(float)(currentDisplay.h/2) - player.yPos, cast(float)(currentDisplay.w/2) - player.xPos);
	}
	else
	{
		angle = atan2(cast(float) mouseY - player.yPos, cast(float) mouseX - player.xPos);
	}

	primaryfire.updateAndDraw(renderer);
	orbs.updateAndDraw(renderer);
	ringblasts.updateAndDraw(renderer);
	player.updateAndDraw(renderer);
}

void handleInput(SDL_Event event)
{
	switch(event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
		{
			app.state = AppState.MENU;
			menu.selectedIndex = MenuItem.START; 
			break;			
		}

		case SDLK_k:
		{
			angleMode = !angleMode;
			break;
		}
		
		case SDLK_o:
		{
			orbs.orbSpawnTimer = -1;
			break;	
		}
		
		default:
		break;           
	}
}

