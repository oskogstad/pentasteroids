import app;

double angle;
bool angleMode = false;
bool gameInProgress = false;

const float TO_DEG = 180/PI;
const float TO_RAD = PI/180;

void setup(SDL_Renderer *renderer)
{
 	gameover.setup(renderer);
	world.setup(renderer);
	orbs.setup(renderer);
	player.setup(renderer);
	primaryfire.setup(renderer);
	ringblasts.setup(renderer);
	sparks.setup();
	score.setup();
}

void updateAndDraw(SDL_Renderer *renderer)
{
	if(angleMode)
	{
		angle = atan2(
			cast(float)(app.middleY) - player.yPos,
			cast(float)(app.middleX) - player.xPos
			);
	}
	else
	{
		angle = atan2(
			cast(float) mouseY - player.yPos,
			cast(float) mouseX - player.xPos
			);
	}
	
	primaryfire.updateAndDraw(renderer);
	orbs.updateAndDraw(renderer);
	ringblasts.updateAndDraw(renderer);
	sparks.updateAndDraw(renderer);

	if(!player.dead)
	{
		score.updateAndDraw(renderer);
		player.updateAndDraw(renderer);
	}
	else
	{
		gameover.updateAndDraw(renderer);
	}
}

void handleInput(SDL_Event event)
{
	if(player.dead)
	{
		// what have i done -----------------------------------------------------------------------------
		if(!(gameover.continueAlpha == 250)) return;

		// reset
		app.state = AppState.MENU;
		gameInProgress = false;
		player.dead = false;
		player.damageTaken = 0;
		orbs.activeOrbs.length = 0;
		orbs.orbSpawnTimer = 2.1;
		ringblasts.activeBlasts.length = 0;
		primaryfire.bullets.length = 0;
		gameover.continueAlpha = 0;
		gameover.fadeScreenAlpha = 0;
		gameover.playedSFX = false;
		score.currentScore = 0;
		return;
	}

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

