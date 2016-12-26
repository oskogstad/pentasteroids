module player;
import app;
import game;
import primaryfire;
import world;

SDL_Texture *spaceShip;
public SDL_Rect *spaceShipRect;
int moveLength = 10;
float thrustX = 0;    
float thrustY = 0;
float thrustDecay = 0.015;
float thrustGain = 0.08;
int spaceShipX, spaceShipY;
int spaceShipHeight, spaceShipWidth;

int mouseX, mouseY;
auto crossHairPath = "img/crosshair.png";
int crossHairHeight, crossHairWidth;
SDL_Texture *crossHair;
public SDL_Rect *crossHairRect;


void setup(SDL_Renderer *renderer)
{
	spaceShipRect = new SDL_Rect();
	crossHairRect = new SDL_Rect();
	crossHair = IMG_LoadTexture(renderer, crossHairPath.ptr);
	assert(crossHair);
	SDL_QueryTexture(crossHair, null, null, &crossHairWidth, &crossHairHeight);

	auto spaceShipPath = "img/spaceship.png";


	spaceShip = IMG_LoadTexture(renderer, spaceShipPath.ptr);
	assert(spaceShip);

	SDL_QueryTexture(spaceShip, null, null, &spaceShipWidth, &spaceShipHeight);

	spaceShipRect.w = spaceShipWidth, spaceShipRect.h = spaceShipHeight;
	spaceShipRect.x = (app.currentDisplay.w / 2) - (spaceShipRect.w / 2);
	spaceShipRect.y = (app.currentDisplay.h / 2) - (spaceShipRect.h / 2);

    // shrink /2 for offset when drawing in main loop
    spaceShipWidth /= 2; spaceShipHeight /= 2;

        //shrink /5
        crossHairWidth /= 5; crossHairHeight /= 5;
        crossHairRect.w = (crossHairWidth), crossHairRect.h = (crossHairHeight);

    // further /2 for offset when drawing in main loop
    crossHairWidth /= 2; crossHairHeight /= 2;
    
    // aim cursor end
}

void updateAndDraw(SDL_Renderer *renderer)
{
	auto keyBoardState = SDL_GetKeyboardState(null);

	if((keyBoardState[SDL_SCANCODE_UP] || keyBoardState[SDL_SCANCODE_W]) && (keyBoardState[SDL_SCANCODE_DOWN] || keyBoardState[SDL_SCANCODE_S]))
	{
		if(abs(thrustY) < thrustDecay)
		{
			thrustY = 0;
		}
		else if(thrustY > 0)
		{
			thrustY -= thrustDecay;
		}
		else 
		{
			thrustY += thrustDecay;
		}
	}

	else if((keyBoardState[SDL_SCANCODE_UP] || keyBoardState[SDL_SCANCODE_W]))
	{
		if((thrustY -= thrustGain) < -1) thrustY = -1;
	}
	else if((keyBoardState[SDL_SCANCODE_DOWN] || keyBoardState[SDL_SCANCODE_S]))
	{
		if((thrustY += thrustGain) > 1) thrustY= 1;
	}
	else
	{
		if(abs(thrustY) < thrustDecay)
		{
			thrustY = 0;
		}
		else if(thrustY > 0)
		{
			thrustY -= thrustDecay;
		}
		else 
		{
			thrustY += thrustDecay;
		} 
	}

	if((keyBoardState[SDL_SCANCODE_LEFT] || keyBoardState[SDL_SCANCODE_A]) && (keyBoardState[SDL_SCANCODE_RIGHT] || keyBoardState[SDL_SCANCODE_D]))
	{
		if(abs(thrustX) < thrustDecay)
		{
			thrustX = 0;
		}
		else if(thrustX > 0)
		{
			thrustX -= thrustDecay;
		}
		else 
		{
			thrustX += thrustDecay;
		}
	}

	else if((keyBoardState[SDL_SCANCODE_LEFT] || keyBoardState[SDL_SCANCODE_A]))
	{
		if((thrustX -= thrustGain) < -1) thrustX = -1;
	}
	else if((keyBoardState[SDL_SCANCODE_RIGHT] || keyBoardState[SDL_SCANCODE_D]))
	{
		if((thrustX += thrustGain) > 1) thrustX= 1;
	}
	else
	{
		if(abs(thrustX) < thrustDecay)
		{
			thrustX = 0;
		}
		else if(thrustX > 0)
		{
			thrustX -= thrustDecay;
		}
		else 
		{
			thrustX += thrustDecay;
		}
	}

	spaceShipRect.y += cast(int) ceil(thrustY * moveLength);
	spaceShipRect.x += cast(int) ceil(thrustX * moveLength);

	spaceShipX = (spaceShipRect.x + (spaceShipWidth));
	spaceShipY = (spaceShipRect.y + (spaceShipHeight));

	if(spaceShipY < 0)
	{
		spaceShipRect.y = (app.currentDisplay.h + spaceShipRect.y);
		world.cellIndexY = abs(++world.cellIndexY % world.worldHeight);
	}
	else if(spaceShipY > app.currentDisplay.h)
	{
		spaceShipRect.y = 0 + (spaceShipRect.y - app.currentDisplay.h);
		world.cellIndexY = abs(--world.cellIndexY % world.worldHeight);
	}

	if(spaceShipX < 0)
	{
		spaceShipRect.x = (app.currentDisplay.w + spaceShipRect.x);
		world.cellIndexX = abs(--world.cellIndexX % world.worldWidth);

	}
	else if(spaceShipX > app.currentDisplay.w)
	{
		spaceShipRect.x = 0 + (spaceShipRect.x - app.currentDisplay.w);
		world.cellIndexX = abs(++world.cellIndexX % world.worldWidth);

	}

	auto mouseState = SDL_GetMouseState(&mouseX, &mouseY);
	crossHairRect.y = mouseY - crossHairHeight, crossHairRect.x = mouseX - crossHairWidth;
	if (mouseState & SDL_BUTTON(SDL_BUTTON_LEFT)) 
	{
		primaryfire.primaryFire = true;
	}
	else 
	{
		primaryfire.primaryFire = false;
		primaryfire.sequencePlaying = false;
	}

	if (mouseState & SDL_BUTTON(SDL_BUTTON_RIGHT)) {writeln("RIGHT FIRE");}
	if (mouseState & SDL_BUTTON(SDL_BUTTON_MIDDLE)) {writeln("MID FIRE");}

	SDL_RenderCopyEx(renderer, spaceShip, null, spaceShipRect, game.angle, null, 0);
	if(!game.angleMode) SDL_RenderCopy(renderer, crossHair, null, crossHairRect);
}