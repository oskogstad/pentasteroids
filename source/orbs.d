import app;

struct Orb
{
	SDL_Texture* texture;

	int 
		x, 
		y,
		radius,
		radiusSquared,
		size,
		dx,
		dy,
		moveSpeed,
		hitPoints,
		hitSFXindex,
		animationOffset, 
		animationDivisor;

	bool 
		hasBeenOnScreen, 
		del, 
		isShaking;

	float 
		angle, 
		spinningSpeed, 
		shakeTimer;
}

SDL_Rect* orbSRect, orbDRect;
SDL_Texture*[] smallOrbTextures;

const int SMALL_ORB_FRAMES = 40;
uint sprite;

auto orbTimerDecay = .03;
auto orbSpawnTimer = 2.1;

Orb[] activeOrbs;

float distanceSquared(int p1x, int p1y, int p2x, int p2y)
{
	return (p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y);
}

void setup(SDL_Renderer *renderer)
{
	orbSRect = new SDL_Rect();
	orbDRect = new SDL_Rect();

	/// --------------------------------------------------------------------------------- temp, need different sized orbs
	orbSRect.w = 128; orbSRect.h = 128;
	orbSRect.y = 0;

	orbDRect.w = 128; orbDRect.h = 128;
	app.loadGFXFromDisk("img/orbs/small/", renderer, smallOrbTextures);
	foreach(texture; smallOrbTextures) assert(texture);
}


void updateAndDraw(SDL_Renderer *renderer)
{
	player.currentlyBeingHit = false;
	foreach(ref orb; activeOrbs)
	{
		float playerDist = distanceSquared(orb.x, orb.y, player.xPos, player.yPos);
		if(playerDist < (orb.radiusSquared + player.radiusSquared))
		{
			player.currentlyBeingHit = true;
		} 

		foreach(ref bullet; bullets)
		{
			float dist = distanceSquared(orb.x, orb.y, bullet.x, bullet.y);
			if(dist < (orb.radiusSquared + primaryfire.radiusSquared))
			{
				if(--orb.hitPoints == 0) orb.del = true;
				orb.isShaking = true;
				ringblasts.createBlast(bullet.x, bullet.y, BlastSize.SMALL);
				Mix_PlayChannel(-1, orbHitSFX[uniform(0, orbHitSFX.length)], 0);
				bullet.del = true;
			}
		}
	}

	primaryfire.bullets = remove!(bullet => bullet.del)(bullets);
	activeOrbs = remove!(orb => orb.del)(activeOrbs);


	if(orbSpawnTimer < 0 && !player.dead)
	{
		// size, divisor name, texture, radius, spawntimer - keeps getting faster over time,  ------------------------------
		Orb o;
		o.x = uniform(0, currentDisplay.w);
		o.hitPoints = uniform(3,6);
		o.hitSFXindex = 4;
		o.shakeTimer = 6;
		o.y = uniform(0, currentDisplay.h);
		o.moveSpeed = uniform(3,6);
		o.angle = uniform(0,359);
		o.radius = 64;
		o.radiusSquared = o.radius * o.radius;
		o.dx = cast(int) (o.moveSpeed * cos(o.angle));
		o.dy = cast(int) (o.moveSpeed * sin(o.angle));
		int orbIndex = uniform(0, smallOrbTextures.length);
		o.texture = smallOrbTextures[orbIndex];
		o.animationOffset = uniform(0, SMALL_ORB_FRAMES);
		o.animationDivisor = uniform(50, 80);
		o.spinningSpeed = uniform(-0.5f, 0.5f);
		activeOrbs ~= o;
		orbSpawnTimer = uniform(2,4);
	}

	else
	{
		orbSpawnTimer -= orbTimerDecay;
	}

	foreach(ref orb; activeOrbs)
	{
		orb.x += orb.dx;
		orb.y += orb.dy;

		if(orb.y < 0)
		{
			orb.y = (currentDisplay.h + orb.y);
		}
		else if(orb.y > currentDisplay.h)
		{
			orb.y = 0 + (orb.y - currentDisplay.h);
		}

		if(orb.x < 0)
		{
			orb.x = (currentDisplay.w + orb.x);
		}
		else if(orb.x > currentDisplay.w)
		{
			orb.x = 0 + (orb.x - currentDisplay.w);
		}

		orb.angle += orb.spinningSpeed;

		if(orb.isShaking || player.shake)
		{
			orbDRect.x = orb.x - 64 + uniform(-7, 7); // size -----------------------------------------------------------
			orbDRect.y = orb.y - 64 + uniform(-7, 7);
			orb.shakeTimer -= 0.1;
			if(orb.shakeTimer < 0)
			{
				orb.isShaking = false;
				orb.shakeTimer = 4;
			}
		}
		else
		{
			orbDRect.x = orb.x - 64; // size -----------------------------------------------------------
			orbDRect.y = orb.y - 64;                    
		}

		sprite = ((app.ticks/ orb.animationDivisor) + orb.animationOffset) % SMALL_ORB_FRAMES;
		orbSRect.x = sprite * 128;

		SDL_RenderCopyEx(renderer, orb.texture, orbSRect, orbDRect, orb.angle, null, 0);
	}
}