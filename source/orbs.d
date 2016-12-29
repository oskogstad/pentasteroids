module orbs;
import app;

struct Orb
{
	SDL_Texture* texture;

	int 
		x, 
		y,
		radius,
		size,
		dx,
		dy,
		moveSpeed,
		hitPoints,
		hitSFXindex;

	bool 
		hasBeenOnScreen, 
		del, 
		isShaking;

	float 
		angle, 
		spinningSpeed, 
		shakeTimer;
}

SDL_Rect *orbRect;
SDL_Texture*[] orbTextures;

const float TO_DEG = 180/PI;
const float TO_RAD = PI/180;

auto orbTimerDecay = .03;
auto orbSpawnTimer = 2.1;

Orb[] activeOrbs;

float distanceSquared(int p1x, int p1y, int p2x, int p2y)
{
	return (p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y);
}

void setup(SDL_Renderer *renderer)
{
	orbRect = new SDL_Rect();
	/// --------------------------------------------------------------------------------- temp, need different sized orbs
	orbRect.w = 128; orbRect.h = 128;
	app.loadGFXFromDisk("img/orbs/", renderer, orbTextures);
	foreach(texture; orbTextures) assert(texture);
}


void updateAndDraw(SDL_Renderer *renderer)
{
	player.currentlyBeingHit = false;
	foreach(ref orb; activeOrbs)
	{
		float ors = orb.radius * orb.radius;
		float playerDist = distanceSquared(orb.x, orb.y, spaceShipRect.x, spaceShipRect.y);
		if(playerDist < ors) player.currentlyBeingHit = true;

		foreach(ref bullet; bullets)
		{
			float dist = distanceSquared(orb.x, orb.y, bullet.x, bullet.y);
			if(dist < orb.radius * orb.radius)
			{
				if(--orb.hitPoints == 0) orb.del = true;
				orb.isShaking = true;
				Mix_PlayChannel(-1, orbHitSFX[uniform(0, orbHitSFX.length)], 0);
				bullet.del = true;
			}
		}
	}

	bullets = remove!(bullet => bullet.del)(bullets);
	activeOrbs = remove!(orb => orb.del)(activeOrbs);


	if(orbSpawnTimer < 0)
	{
		Orb o;
		o.x = uniform(0, currentDisplay.w);
		o.hitPoints = 3;
		o.hitSFXindex = 4;
		o.shakeTimer = 6;
		o.y = uniform(0, currentDisplay.h);
		o.moveSpeed = uniform(3,6);
		o.angle = uniform(0,359);
		o.radius = 128;
		o.dx = cast(int) (o.moveSpeed * cos(o.angle * TO_RAD));
		o.dy = cast(int) (o.moveSpeed * sin(o.angle * TO_RAD));
		int orbIndex = uniform(0, orbTextures.length - 1);
		o.texture = orbTextures[orbIndex];
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

		if(orb.isShaking)
		{
			orbRect.x = orb.x - 64 + uniform(-7, 7);
			orbRect.y = orb.y - 64 + uniform(-7, 7);
			orb.shakeTimer -= 0.1;
			if(orb.shakeTimer < 0)
			{
				orb.isShaking = false;
				orb.shakeTimer = 4;
			}
		}
		else
		{
			orbRect.x = orb.x - 64;
			orbRect.y = orb.y - 64;                    
		}

		SDL_RenderCopyEx(renderer, orb.texture, null, orbRect, orb.angle, null, 0);
	}
}