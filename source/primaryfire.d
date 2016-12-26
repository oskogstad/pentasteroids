module primaryfire;
import app;
import player;
import game;

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
Mix_Chunk*[] primaryFireSFX;
PrimaryGFX[] bullets;

auto primaryWeaponPath = "img/single_green_beam.png";
SDL_Texture *primaryWeapon;
int primaryWeaponHeight, primaryWeaponWidth;
public SDL_Rect *primaryWeaponRect;
int bulletMoveLength = 20;
float fireCooldown = -1;

// set start pos relative to spaceship
int lWepXOffset = 4, lWepYOffset = 14, rWepXOffset = 4, rWepYOffset = 136;
bool primaryFire, leftFire;
bool sequencePlaying = false;
int sequenceIndex = 0;


void setup(SDL_Renderer *renderer)
{
	primaryWeaponRect = new SDL_Rect();
	primaryWeapon = IMG_LoadTexture(renderer, primaryWeaponPath.ptr);
	SDL_QueryTexture(primaryWeapon, null, null, &primaryWeaponWidth, &primaryWeaponHeight);
	assert(primaryWeapon);
	primaryWeaponRect.w = primaryWeaponWidth, primaryWeaponRect.h = primaryWeaponHeight;
	primaryWeaponRect.x = player.spaceShipRect.x; primaryWeaponRect.y = player.spaceShipRect.y;


	foreach(path; dirEntries("sfx/orbHitScale/", SpanMode.depth))
	{
		orbHitSFX ~= Mix_LoadWAV(path.toStringz());
	}

	foreach(a; orbHitSFX){assert(a);}

	foreach(path; dirEntries("sfx/primaryScale/", SpanMode.depth))
	{
		primaryFireSFX ~= Mix_LoadWAV(path.toStringz());
	}

	foreach(a; primaryFireSFX){assert(a);}	
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
	primaryWeaponRect.x = player.spaceShipRect.x + newLWepXOffset;
	primaryWeaponRect.y = player.spaceShipRect.y + newLWepYOffset;
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
				if(++sequenceIndex == primaryFireSFX.length) sequenceIndex = 0;
				Mix_PlayChannel(-1, primaryFireSFX[sequenceIndex], 0);

			}
			else
			{
				sequenceIndex = 0;
				partialShuffle(primaryFireSFX, 3);
				Mix_PlayChannel(-1, primaryFireSFX[sequenceIndex], 0);
				sequencePlaying = true;
			}

			PrimaryGFX left;
			left.x = primaryWeaponRect.x, left.y = primaryWeaponRect.y;
			left.angle = angle - 90;
			left.dx = cast(int) (bulletMoveLength * cos(left.angle * TO_RAD));
			left.dy = cast(int) (bulletMoveLength * sin(left.angle * TO_RAD));
			bullets ~= left;

			primaryWeaponRect.x = player.spaceShipRect.x + newRWepXOffset;
			primaryWeaponRect.y = player.spaceShipRect.y + newRWepYOffset;
			PrimaryGFX right;
			right.x = primaryWeaponRect.x, right.y = primaryWeaponRect.y;
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

		primaryWeaponRect.x = bullet.x;
		primaryWeaponRect.y = bullet.y;
		SDL_RenderDrawPoint(renderer, bullet.x + bullet.dx, bullet.y + bullet.dy);
		SDL_RenderCopyEx(renderer, primaryWeapon, null, primaryWeaponRect, bullet.angle + 90, &wepRotPoint, 0);
	}
}