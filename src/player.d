import everything;

Mix_Chunk *playerHitSFX;
bool currentlyBeingHit;
int damageTaken = 0;
int hitPoints, hitPointsMidThreshold, hitPointsTopThreshold;
bool shake, dead;

SDL_Texture* playerTexture;
SDL_Texture* playerBGTexture;
SDL_Rect bgRect;
SDL_Rect playerSrcRect;
SDL_Rect playerTextureRect;
int playerSpriteSize;
SDL_Texture* crossHair;
SDL_Rect crossHairRect;
SDL_Texture* dyingOverlayTop,
	         dyingOverlayMiddle,
	         dyingOverlayBottom;
SDL_Rect dyingOverlayRect;

int framesInAnim = 3;
int currentAnimFrame = 0;
int ticksPerFrame = 10;
int tickCounter = 0;

SDL_Rect fuelRect;

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

	dyingOverlayTop = IMG_LoadTexture(renderer, "img/dying_overlay_top.png");
	assert(dyingOverlayTop);
	dyingOverlayMiddle = IMG_LoadTexture(renderer, "img/dying_overlay_middle.png");
	assert(dyingOverlayMiddle);
	dyingOverlayBottom = IMG_LoadTexture(renderer, "img/dying_overlay_bottom.png");
	assert(dyingOverlayBottom);

    SDL_QueryTexture(dyingOverlayBottom, null, null, &dyingOverlayRect.w, &dyingOverlayRect.h);

	crossHair = IMG_LoadTexture(renderer, "img/crosshair.png");
	assert(crossHair);
	SDL_QueryTexture(crossHair, null, null, &crossHairWidth, &crossHairHeight);

	playerTexture = IMG_LoadTexture(renderer, "img/player.png");
	assert(playerTexture);

	radius = 81;
    playerSpriteSize = 162;
	player.radiusSquared = radius * radius;
	playerTextureRect.w = radius*2, playerTextureRect.h = radius*2;

    playerBGTexture = IMG_LoadTexture(renderer, "img/playerbg.png");
    bgRect.w = bgRect.h = 100;

    fuelRect.w = 40;
    fuelRect.h = 64;

    playerSrcRect.w = playerSpriteSize, playerSrcRect.h = playerSpriteSize;

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
		yPos = (app.display_height + yPos);
		world.cellIndexY = abs(++world.cellIndexY % world.worldHeight);
	}
	else if(yPos > app.display_height)
	{
		yPos = 0 + (yPos - app.display_height);
		world.cellIndexY = abs(--world.cellIndexY % world.worldHeight);
	}

	if(xPos < 0)
	{
		xPos = (app.display_width + xPos);
		world.cellIndexX = abs(++world.cellIndexX % world.worldWidth);
	}
	else if(xPos > app.display_width)
	{
		xPos = 0 + (xPos - app.display_width);
		world.cellIndexX = abs(--world.cellIndexX % world.worldWidth);
	}

	auto mouseState = SDL_GetMouseState(&mouseX, &mouseY);
	// w and h allready /2
	crossHairRect.y = mouseY - crossHairHeight, crossHairRect.x = mouseX - crossHairWidth; 

	playerTextureRect.x = xPos - playerTextureRect.w/2;
	playerTextureRect.y = yPos - playerTextureRect.h/2;

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
		if(damageTaken > 0 && !primaryfire.primaryFire) --damageTaken;
	}

	if(shake)
	{
		playerTextureRect.x += uniform(-7,7);
		playerTextureRect.y += uniform(-7,7);
	}

    // Do anim stuff
    if(++tickCounter >= ticksPerFrame) {
        tickCounter = 0;
        if(++currentAnimFrame >= framesInAnim) currentAnimFrame = 0;
        playerSrcRect.x = playerSpriteSize * currentAnimFrame;
    }

    // Update fuel rect
    fuelRect.x = xPos;
    fuelRect.y = yPos - fuelRect.h/2;
    fuelRect.w = cast(int)mapToRange!float(secondaryfire.fuel, 0, secondaryfire.maxFuel, 10, 40);
    immutable SDL_Point pivot = SDL_Point(0, fuelRect.h/2);

    bgRect.x = xPos - bgRect.w/2;
    bgRect.y = yPos - bgRect.h/2;

    // Now we make the light gree when fuel is full, but when bombs are implemented, it should probably be used for that instead
    if(secondaryfire.fuel >= maxFuel) {
        playerSrcRect.y = playerSpriteSize;
    }
    else {
        playerSrcRect.y = 0;
    }

    SDL_RenderCopy(renderer, playerBGTexture, null, &bgRect);
    SDL_RenderCopyEx(renderer, secondaryfire.sfGFX, &secondaryfire.sfSRect, &fuelRect, (game.angle * TO_DEG), &pivot, 0);
	SDL_RenderCopyEx(renderer, playerTexture, &playerSrcRect, &playerTextureRect, (game.angle * TO_DEG + 90), null, 0); // +90 because rotation stuff 
	if(!game.angleMode) SDL_RenderCopy(renderer, crossHair, null, &crossHairRect);

	if(damageTaken > 0)
	{
		// X lands between A and B, map to Y between C and D:
		// Y = (X-A)/(B-A) * (D-C) + C

		if(damageTaken > hitPointsTopThreshold)
		{
			ubyte alphaMod = cast(ubyte)( 
				(((cast(float)damageTaken) - hitPointsTopThreshold) / (hitPoints - hitPointsTopThreshold)) * 255
				);
			dyingOverlayRect.x = uniform(-2, 2); // textures are 1923*1083
			dyingOverlayRect.y = uniform(-2, 2);
			SDL_SetTextureAlphaMod(dyingOverlayBottom, alphaMod);
			SDL_RenderCopy(renderer, dyingOverlayBottom, null, &dyingOverlayRect);
		}
		
		if(damageTaken > hitPointsMidThreshold)
		{
			ubyte alphaMod = cast(ubyte)(
				(((cast(float)damageTaken) - hitPointsMidThreshold) / (hitPoints - hitPointsMidThreshold)) * 255
				);
			dyingOverlayRect.x = uniform(-2, 2); // textures are 1923*1083
			dyingOverlayRect.y = uniform(-2, 2);
			SDL_SetTextureAlphaMod(dyingOverlayMiddle, alphaMod);
			SDL_RenderCopy(renderer, dyingOverlayMiddle, null, &dyingOverlayRect);
		}

		ubyte alphaMod = cast(ubyte) (((cast(float)damageTaken)/hitPoints) * 255);
		dyingOverlayRect.x = uniform(-2, 2);
		dyingOverlayRect.y = uniform(-2, 2);
		SDL_SetTextureAlphaMod(dyingOverlayTop, alphaMod);
		SDL_RenderCopy(renderer, dyingOverlayTop, null, &dyingOverlayRect);
	}
}
