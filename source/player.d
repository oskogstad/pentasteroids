module player;
import app;

Mix_Chunk *playerHitSFX;
bool currentlyBeingHit;
int hitPoints = 180;
bool shake;

SDL_Texture *spaceShip;
SDL_Rect *spaceShipRect;
SDL_Texture *crossHair;
SDL_Rect *crossHairRect;

int moveLength = 10;
float thrustX = 0;    
float thrustY = 0;
float thrustDecay = 0.015;
float thrustGain = 0.08;

int 
	spaceShipX, 
	spaceShipY,
	spaceShipHeight, 
	spaceShipWidth,
	mouseX, 
	mouseY,
	crossHairHeight, 
	crossHairWidth;


void setup(SDL_Renderer *renderer)
{
	crossHairRect = new SDL_Rect();
	crossHair = IMG_LoadTexture(renderer, "img/crosshair.png");
	assert(crossHair);
	SDL_QueryTexture(crossHair, null, null, &crossHairWidth, &crossHairHeight);

	spaceShipRect = new SDL_Rect();
	spaceShip = IMG_LoadTexture(renderer, "img/spaceship.png");
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
    auto arst = "sfx/player_hit.wav";
    playerHitSFX = Mix_LoadWAV(arst.toStringz());
    assert(playerHitSFX); 
    writeln(playerHitSFX);
}

void decay(ref float thrust)
{
	if(abs(thrust) < thrustDecay)
	{
		thrust = 0;
	}
	else if(thrust > 0)
	{
		thrust -= thrustDecay;
	}
	else 
	{
		thrust += thrustDecay;
	}
}

void checkKeysDown(ref float thrust, ubyte pos, ubyte posAlt, ubyte neg, ubyte negAlt)
{
	if((pos || posAlt) && (neg || negAlt))
	{
		decay(thrust);
	}
	else if(neg || negAlt)
	{
		if((thrust -= thrustGain) < -1) thrust = -1;
	}
	else if(pos || posAlt)
	{
		if((thrust += thrustGain) > 1) thrust = 1;
	}
	else
	{
		decay(thrust);
	}
}

void updateAndDraw(SDL_Renderer *renderer)
{
	if(currentlyBeingHit)
	{
		shake = true;
		if(Mix_Paused(0) || !Mix_Playing(0))
		{
			Mix_PlayChannel(0, playerHitSFX, 0);
		}

		--hitPoints;
		// if(hitPoints <= 0)
	}
	else
	{
		shake = false;
		if(Mix_Playing(0)) 
		{
			Mix_Pause(0);
		}
	}

	auto keyBoardState = SDL_GetKeyboardState(null);

	// y thrust update
	checkKeysDown(
		thrustY, 
		keyBoardState[SDL_SCANCODE_DOWN], 
		keyBoardState[SDL_SCANCODE_S], 
		keyBoardState[SDL_SCANCODE_UP], 
		keyBoardState[SDL_SCANCODE_W]);

	// x thrust update
	checkKeysDown(
		thrustX,
		keyBoardState[SDL_SCANCODE_RIGHT],
		keyBoardState[SDL_SCANCODE_D],
		keyBoardState[SDL_SCANCODE_LEFT],
		keyBoardState[SDL_SCANCODE_A]);


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
		world.cellIndexX = abs(++world.cellIndexX % world.worldWidth);
	}
	else if(spaceShipX > app.currentDisplay.w)
	{
		spaceShipRect.x = 0 + (spaceShipRect.x - app.currentDisplay.w);
		world.cellIndexX = abs(--world.cellIndexX % world.worldWidth);
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

	if(shake)
	{
		spaceShipRect.x += uniform(-7,7);
		spaceShipRect.y += uniform(-7,7);
	}

	SDL_RenderCopyEx(renderer, spaceShip, null, spaceShipRect, game.angle, null, 0);
	if(!game.angleMode) SDL_RenderCopy(renderer, crossHair, null, crossHairRect);
}