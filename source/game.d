module game;
import app;

double angle;
bool angleMode = false;
bool gameInProgress = false;
bool playedSFX = false;
Mix_Chunk* gameOverSFX;


const float TO_DEG = 180/PI;
const float TO_RAD = PI/180;

void setup(SDL_Renderer *renderer)
{
	gameOverSFX = Mix_LoadWAV("sfx/game_over.wav");

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

	if(!player.dead)
	{
		player.updateAndDraw(renderer);
	}
	else
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
		// draw dyinggfx at max alpha
		// fade in black overlay fade in "press key to cont"
		// show score
	}
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

		case SDLK_c:
		{
			orbs.activeOrbs.length = 0;
			break;	
		}

		
		default:
		break;           
	}
}

