import everything;

Mix_Chunk *playerHitSFX;
bool currentlyBeingHit;
int damageTaken = 0;
int hitPoints, hitPointsMidThreshold, hitPointsTopThreshold;
bool shake, dead;

SDL_Texture* playerTexture;
SDL_Rect* playerTextureRect;
SDL_Texture* crossHair;
SDL_Rect* crossHairRect;
SDL_Texture* 
	dyingOverlayTop,
	dyingOverlayMiddle,
	dyingOverlayBottom;
SDL_Rect* dyingOverlayRect;

int moveLength = 10;
float thrustX = 0;    
float thrustY = 0;
float thrustDecay = 0.015;
float thrustGain = 0.08;
float radiusSquared;

int 
	xPos, 
	yPos,
	radius,
	mouseX, 
	mouseY,
	crossHairHeight, 
	crossHairWidth;


void setup()
{
	hitPoints = 180;
	hitPointsMidThreshold = cast(int) (hitPoints * 0.4);
	hitPointsTopThreshold = cast(int) (hitPoints * 0.6);

	dyingOverlayRect = new SDL_Rect();
	dyingOverlayTop = IMG_LoadTexture(renderer, "img/dying_overlay_top.png");
	assert(dyingOverlayTop);
	dyingOverlayMiddle = IMG_LoadTexture(renderer, "img/dying_overlay_middle.png");
	assert(dyingOverlayMiddle);
	dyingOverlayBottom = IMG_LoadTexture(renderer, "img/dying_overlay_bottom.png");
	assert(dyingOverlayBottom);

	int overlayW, overlayH;
	SDL_QueryTexture(dyingOverlayTop, null, null, &overlayW, &overlayH);
	dyingOverlayRect.w = overlayW; dyingOverlayRect.h = overlayH;

	crossHairRect = new SDL_Rect();
	crossHair = IMG_LoadTexture(renderer, "img/crosshair.png");
	assert(crossHair);
	SDL_QueryTexture(crossHair, null, null, &crossHairWidth, &crossHairHeight);

	playerTextureRect = new SDL_Rect();
	playerTexture = IMG_LoadTexture(renderer, "img/player.png");
	assert(playerTexture);

	int twidth, theight;
	SDL_QueryTexture(playerTexture, null, null, &twidth, &theight);
	playerTextureRect.w = twidth, playerTextureRect.h = theight;
	radius = twidth / 2;
	player.radiusSquared = radius * radius; // something is broken with orb-player-crash-detection

	xPos = app.middleX;
	yPos = app.middleY;

    //shrink /5
    crossHairWidth /= 5; crossHairHeight /= 5;
    crossHairRect.w = (crossHairWidth), crossHairRect.h = (crossHairHeight);

    // further /2 for offset when drawing in main loop
    crossHairWidth /= 2; crossHairHeight /= 2;
    playerHitSFX = Mix_LoadWAV("sfx/player_hit.wav");
    assert(playerHitSFX); 
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

void updateAndDraw()
{
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

	yPos += cast(int) ceil(thrustY * moveLength);
	xPos += cast(int) ceil(thrustX * moveLength);

	if(yPos < 0)
	{
		yPos = (app.currentDisplay.h + yPos);
		world.cellIndexY = abs(++world.cellIndexY % world.worldHeight);
	}
	else if(yPos > app.currentDisplay.h)
	{
		yPos = 0 + (yPos - app.currentDisplay.h);
		world.cellIndexY = abs(--world.cellIndexY % world.worldHeight);
	}

	if(xPos < 0)
	{
		xPos = (app.currentDisplay.w + xPos);
		world.cellIndexX = abs(++world.cellIndexX % world.worldWidth);
	}
	else if(xPos > app.currentDisplay.w)
	{
		xPos = 0 + (xPos - app.currentDisplay.w);
		world.cellIndexX = abs(--world.cellIndexX % world.worldWidth);
	}

	auto mouseState = SDL_GetMouseState(&mouseX, &mouseY);
	// w and h allready /2
	crossHairRect.y = mouseY - crossHairHeight, crossHairRect.x = mouseX - crossHairWidth; 
	
	// trying something 
	//if (mouseState & SDL_BUTTON(SDL_BUTTON_LEFT)) 
	//{
	//	primaryfire.primaryFire = true;
	//}
	//else 
	//{
	//	primaryfire.primaryFire = false;
	//	primaryfire.sequencePlaying = false;
	//}

	if (mouseState & SDL_BUTTON(SDL_BUTTON_RIGHT)) {writeln("RIGHT FIRE");}
	if (mouseState & SDL_BUTTON(SDL_BUTTON_MIDDLE)) {writeln("MID FIRE");}


	playerTextureRect.x = xPos - 80; // temp, trying to find bug
	playerTextureRect.y = yPos - 80;

	if(currentlyBeingHit)
	{
		shake = true;
		if(Mix_Paused(0) || !Mix_Playing(0))
		{
			Mix_PlayChannel(0, playerHitSFX, 0);
		}

		++damageTaken;
		if(damageTaken >= hitPoints)
		{
			dead = true;
		}
	}
	else
	{
		shake = false;
		if(Mix_Playing(0)) 
		{
			Mix_Pause(0);
		}
		if(damageTaken > 0) --damageTaken;
	}

	if(shake)
	{
		playerTextureRect.x += uniform(-7,7);
		playerTextureRect.y += uniform(-7,7);
	}


	SDL_RenderCopyEx(renderer, playerTexture, null, playerTextureRect, (game.angle * TO_DEG + 90), null, 0); // +90 because rotation stuff 
	if(!game.angleMode) SDL_RenderCopy(renderer, crossHair, null, crossHairRect);

	if(damageTaken > 0)
	{
		// X lands between A and B, map to Y between C and D:
		// Y = (X-A)/(B-A) * (D-C) + C

		if(damageTaken > hitPointsTopThreshold)
		{
			ubyte alphaMod = cast(ubyte)( 
				(((cast(float)damageTaken) - hitPointsTopThreshold) / (hitPoints - hitPointsTopThreshold)) * 255
				);
			dyingOverlayRect.x = uniform(-3, 1); // textures are 1923*1083
			dyingOverlayRect.y = uniform(-3, 1);
			SDL_SetTextureAlphaMod(dyingOverlayBottom, alphaMod);
			SDL_RenderCopy(renderer, dyingOverlayBottom, null, dyingOverlayRect);
		}
		
		if(damageTaken > hitPointsMidThreshold)
		{
			ubyte alphaMod = cast(ubyte)(
				(((cast(float)damageTaken) - hitPointsMidThreshold) / (hitPoints - hitPointsMidThreshold)) * 255
				);
			dyingOverlayRect.x = uniform(-3, 1); // textures are 1923*1083
			dyingOverlayRect.y = uniform(-3, 1);
			SDL_SetTextureAlphaMod(dyingOverlayMiddle, alphaMod);
			SDL_RenderCopy(renderer, dyingOverlayMiddle, null, dyingOverlayRect);
		}

		ubyte alphaMod = cast(ubyte) (((cast(float)damageTaken)/hitPoints) * 255);
		dyingOverlayRect.x = uniform(-3, 1);
		dyingOverlayRect.y = uniform(-3, 1);
		SDL_SetTextureAlphaMod(dyingOverlayTop, alphaMod);
		SDL_RenderCopy(renderer, dyingOverlayTop, null, dyingOverlayRect);
	}
}