module primaryfire;
import app;

const float TO_DEG = 180/PI;
const float TO_RAD = PI/180;

struct PrimaryGFX 
{
	int x, y;
	int dx, dy;
	float angle;
	float ttl;
	bool del;
}

Mix_Chunk*[] orbHitSFX;
Mix_Chunk*[] bulletFireSFX;
PrimaryGFX[] bullets;

SDL_Texture *bulletGFX;
int bulletGFXHeight, bulletGFXWidth;
SDL_Rect *bulletGFXRect;
int bulletMoveLength = 20;
ubyte bulletVolume = 55;
float fireCooldown = -1;

// set start pos relative to spaceship
int lWepXOffset = 4, lWepYOffset = 14, rWepXOffset = 4, rWepYOffset = 136;
bool primaryFire, leftFire;
bool sequencePlaying = false;
int sequenceIndex = 0;


void setup(SDL_Renderer *renderer)
{
	bulletGFXRect = new SDL_Rect();
	bulletGFX = IMG_LoadTexture(renderer, "img/single_green_beam.png");
	SDL_QueryTexture(bulletGFX, null, null, &bulletGFXWidth, &bulletGFXHeight);
	assert(bulletGFX);
	bulletGFXRect.w = bulletGFXWidth, bulletGFXRect.h = bulletGFXHeight;
	bulletGFXRect.x = player.spaceShipRect.x; bulletGFXRect.y = player.spaceShipRect.y;

	app.loadSFXFromDisk("sfx/orbHitScale/", orbHitSFX);
	foreach(sfx; orbHitSFX) assert(sfx);

	app.loadSFXFromDisk("sfx/primaryScale/", bulletFireSFX);
	foreach(sfx; bulletFireSFX) assert(sfx);

	foreach(audio; bulletFireSFX) 
	{
		audio.volume = bulletVolume;
	}	
}

void updateAndDraw(SDL_Renderer *renderer)
{
	float s = sin(game.angle);
	float c = cos(game.angle);
	int newLWepXOffset = cast(int) ceil((lWepXOffset * c) - (lWepYOffset * s));
	int newLWepYOffset = cast(int) ceil((lWepXOffset * s) + (lWepYOffset * c));
	int newRWepXOffset = cast(int) ceil((rWepXOffset * c) - (rWepYOffset * s));
	int newRWepYOffset = cast(int) ceil((rWepXOffset * s) + (rWepYOffset * c));
	game.angle = game.angle * TO_DEG;
	game.angle += 90f;
	bulletGFXRect.x = player.spaceShipRect.x + newLWepXOffset;
	bulletGFXRect.y = player.spaceShipRect.y + newLWepYOffset;
	SDL_Point wepRotPoint = { (player.spaceShipRect.w/2), (player.spaceShipRect.h/2) };


	if(primaryFire)
	{
		if(fireCooldown > 0) 
		{
			fireCooldown -= 0.1;
		} 
		else 
		{
			if(sequencePlaying)
			{
				if(++sequenceIndex == bulletFireSFX.length) sequenceIndex = 0;
				Mix_PlayChannel(-1, bulletFireSFX[sequenceIndex], 0);

			}
			else
			{
				sequenceIndex = 0;
				partialShuffle(bulletFireSFX, 3);
				Mix_PlayChannel(-1, bulletFireSFX[sequenceIndex], 0);
				sequencePlaying = true;
			}

			PrimaryGFX left;
			left.x = bulletGFXRect.x, left.y = bulletGFXRect.y;
			left.angle = angle - 90;
			left.dx = cast(int) (bulletMoveLength * cos(left.angle * TO_RAD));
			left.dy = cast(int) (bulletMoveLength * sin(left.angle * TO_RAD));
			bullets ~= left;

			bulletGFXRect.x = player.spaceShipRect.x + newRWepXOffset;
			bulletGFXRect.y = player.spaceShipRect.y + newRWepYOffset;
			PrimaryGFX right;
			right.x = bulletGFXRect.x, right.y = bulletGFXRect.y;
			right.angle = angle - 90;
			right.dx = cast(int) (bulletMoveLength * cos(right.angle * TO_RAD));
			right.dy = cast(int) (bulletMoveLength * sin(right.angle * TO_RAD));
			bullets ~= right;

			fireCooldown = 2.1; 
		}
	}

	foreach(ref bullet; bullets)
	{
		bullet.x += bullet.dx;
		bullet.y += bullet.dy;

		if((bullet.x < -50) || (bullet.x > (app.currentDisplay.w + 50)) || (bullet.y < - 50) || (bullet.y > (app.currentDisplay.h + 50)))
		{
			bullet.del = true;
		}

		bulletGFXRect.x = bullet.x;
		bulletGFXRect.y = bullet.y;
		SDL_RenderDrawPoint(renderer, bullet.x, bullet.y);
		SDL_RenderCopyEx(renderer, bulletGFX, null, bulletGFXRect, bullet.angle + 90, &wepRotPoint, 0);
	}
}