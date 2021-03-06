import everything;

SDL_Rect orbSRect, orbDRect;
SDL_Texture*[] smallOrbTextures;
SDL_Texture*[] mediumOrbTextures;
Orb[] activeOrbs;

const int 
	ORB_FRAMES_SMALL = 4, 
	ORB_FRAMES_MEDIUM = 6,
	ORB_FRAMES_LARGE = 40;

const float 
	SMALL_TIMER = 4.1, 
	MEDIUM_TIMER = 12.1,
	LARGE_TIMER = 45.1;

uint sprite;

int
	orbMargin,
	smallOrbMin,
	smallOrbXMax,
	smallOrbYMax,
	mediumOrbMin,
	mediumOrbXMax,
	mediumOrbYMax,
	largeOrbMin,
	largeOrbXMax,
	largeOrbYMax;

float 
	orbTimerDecay = .03, 
	smallOrbTimer, 
	mediumOrbTimer, 
	largeOrbTimer;

float distanceSquared(int p1x, int p1y, int p2x, int p2y)
{
	return (p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y);
}

void createOrb(
		Size size, int numFrames, int min, int xMax, int yMax, 
		int hitPointsMin, int hitPointsMax, int moveMin, int moveMax, int x, int y)
{
	Orb o;
	if(x == int.max)
	{
		o.x = uniform(app.display_width + 5 + size, xMax);
		o.y = uniform(app.display_height + 5 + size, yMax);
	}
	else
	{
		o.x = x + uniform(-5, 5);
		o.y = y + uniform(-5, 5);
	}

	o.hitPoints = uniform(hitPointsMin, hitPointsMax);
	o.shakeTimer = 6;
	o.moveSpeed = uniform(moveMin,moveMax);
	o.angle = uniform(0,2f*PI);
	o.size = size;
	o.radius = size/2;
	o.radiusSquared = o.radius * o.radius;
	o.dx = cast(int) (o.moveSpeed * cos(o.angle));
	o.dy = cast(int) (o.moveSpeed * sin(o.angle));
	o.animationOffset = uniform(0, numFrames);
	o.animationDivisor = uniform(50, 80); // spin/speed
	o.spinningSpeed = uniform(-0.5f, 0.5f);

	// set timer for size
	if(size == Size.SMALL)
	{
		int orbIndex = cast(int)uniform(0, smallOrbTextures.length);
		o.texture = smallOrbTextures[orbIndex];
		smallOrbTimer = SMALL_TIMER;
	}
	else if(size == Size.MEDIUM)
	{
		int orbIndex = cast(int)uniform(0, mediumOrbTextures.length);
		o.texture = mediumOrbTextures[orbIndex];
		mediumOrbTimer = 8.1;
	}
	
	activeOrbs ~= o;
}

void resetTimers()
{
	smallOrbTimer = SMALL_TIMER;
	mediumOrbTimer = MEDIUM_TIMER;
	largeOrbTimer = LARGE_TIMER;
}

void orbSpawner()
{
	if(player.dead) return;

	if(smallOrbTimer < 0)
	{
		// size, numFrames, XYmin, xMax, yMax, 
		// hitPointsMin, hitPointsMax, 										 moveMax, moveMin        spawn x / ;
		createOrb(Size.SMALL, ORB_FRAMES_SMALL, smallOrbMin, smallOrbXMax, smallOrbYMax, 3, 6, 5, 7, int.max, int.max);
	}
	else
	{
		smallOrbTimer -= orbTimerDecay;
	}

	if(mediumOrbTimer < 0)
	{																			  //movespeed
		createOrb(Size.MEDIUM, ORB_FRAMES_MEDIUM, mediumOrbMin, mediumOrbXMax, mediumOrbYMax, 10, 15, 3,5, int.max, int.max);
	}
	else
	{
		mediumOrbTimer -= orbTimerDecay;
	}

	if(largeOrbTimer < 0)
	{
		//createOrb(Size.LARGE, ORB_FRAMES_LARGE, largeOrbMin, largeOrbXMax, largeOrbYMax, 100, 200, 1, 2);
	}
}

void checkBounds(ref Orb orb, int min, int xMax, int yMax)
{
		if(orb.y < min)
		{
			orb.y = (yMax + orb.y);
		}
		else if(orb.y > yMax)
		{
			orb.y = (min);
		}

		if(orb.x < min)
		{
			orb.x = (xMax + orb.x);
		}
		else if(orb.x > xMax)
		{
			orb.x = (min);
		}
}

void setup()
{
	resetTimers();

	orbSRect.y = 0;

	utils.loadGFXFromDisk("img/orbs/small/", renderer, smallOrbTextures);
	foreach(texture; smallOrbTextures) assert(texture);

	utils.loadGFXFromDisk("img/orbs/medium/", renderer, mediumOrbTextures);
	foreach(texture; mediumOrbTextures) assert(texture);

	// setting spawn area limits for orbs, also use these for teleport edges
	orbMargin = 20;
	smallOrbMin = -Size.SMALL - orbMargin;
	smallOrbXMax = app.display_width + Size.SMALL + orbMargin;
	smallOrbYMax = app.display_height + Size.SMALL + orbMargin;
	mediumOrbMin = -Size.MEDIUM - orbMargin;
	mediumOrbXMax = app.display_width + Size.MEDIUM + orbMargin;
	mediumOrbYMax = app.display_height + Size.MEDIUM + orbMargin;
	largeOrbMin = -Size.LARGE - orbMargin;
	largeOrbXMax = app.display_width + Size.LARGE + orbMargin;
	largeOrbYMax = app.display_height + Size.LARGE + orbMargin;
}

void updateAndDraw() 
{
	player.currentlyBeingHit = false;
	foreach(ref orb; activeOrbs)
	{
		// secondary wep
		if(secondaryfire.secondaryFire)
		{
			if(secondaryfire.hitByBeam(orb.x, orb.y, orb.radius, player.xPos, player.yPos, gameState.angle, 120f)) // beam-hit-radius
			{
				orb.del = true;
			}
		}

		// player/orb
		float playerDist = distanceSquared(orb.x, orb.y, player.xPos, player.yPos);
		if(playerDist < (orb.radius + player.radius)^^2)
		{	
			player.currentlyBeingHit = true;
		}

		// bullets
		foreach(ref bullet; bullets)
		{
			float dist = distanceSquared(orb.x, orb.y, bullet.x, bullet.y);
			if(dist < (orb.radius + primaryfire.radius)^^2)
			{
				if(--orb.hitPoints == 0) 
				{
					orb.del = true;
					if(orb.size == Size.MEDIUM) 
					{
						// spawn small orbs
						int numChildren = uniform(4,8);
						for(int i = 0; i < numChildren; ++i)
						{
							createOrb(Size.SMALL, ORB_FRAMES_SMALL, smallOrbMin, smallOrbXMax, smallOrbYMax, 3, 6, 5, 7, orb.x, orb.y);
						}
					}
					else if(orb.size == Size.LARGE)
					{
						// spawn medium orbs
					}
				}

				orb.isShaking = true;
				ringblasts.createBlast(bullet.x, bullet.y, orb.size);
				score.addOrbHitScore(orb.size);
				sparks.createSparks(bullet.x, bullet.y, bullet.dx, bullet.dy, bullet.angle, uniform(3,8));
				Mix_PlayChannel(-1, orbHitSFX[uniform(0, orbHitSFX.length)], 0);
				bullet.del = true;
			}
		}
	}

	primaryfire.bullets = remove!(bullet => bullet.del)(bullets);
	activeOrbs = remove!(orb => orb.del)(activeOrbs);

	orbSpawner();

	foreach(ref orb; activeOrbs)
	{
		orb.x += orb.dx;
		orb.y += orb.dy;

		if(orb.size == Size.SMALL)
		{
			checkBounds(orb, smallOrbMin, smallOrbXMax, smallOrbYMax);
		}
		else if(orb.size == Size.MEDIUM) 
		{
			checkBounds(orb, mediumOrbMin, mediumOrbXMax, mediumOrbYMax);
		}
		else 
		{
			checkBounds(orb, largeOrbMin, largeOrbXMax, largeOrbYMax);
		} 

		orb.angle += orb.spinningSpeed;

		orbDRect.w = orb.size;
		orbDRect.h = orb.size;

		if(orb.isShaking || player.shake)
		{
			orbDRect.x = orb.x - orb.size/2 + uniform(-7, 7);
			orbDRect.y = orb.y - orb.size/2 + uniform(-7, 7);
			orb.shakeTimer -= 0.1;
			if(orb.shakeTimer < 0)
			{
				orb.isShaking = false;
				orb.shakeTimer = 4;
			}
		}
		else
		{
			orbDRect.x = orb.x - orb.size/2; 
			orbDRect.y = orb.y - orb.size/2;                    
		}

		orbSRect.w = orb.size;
		orbSRect.h = orb.size;

		sprite = ((app.ticks / orb.animationDivisor) + orb.animationOffset);

		if(orb.size == Size.SMALL) sprite %= ORB_FRAMES_SMALL;
		else if(orb.size == Size.MEDIUM) sprite %= ORB_FRAMES_MEDIUM;
		else sprite %= ORB_FRAMES_LARGE;

		orbSRect.x = sprite * orb.size;
		SDL_RenderCopyEx(renderer, orb.texture, &orbSRect, &orbDRect, orb.angle, null, 0);
	}
}
