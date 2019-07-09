import everything;

struct PrimaryGFX 
{
	int 
		x, 
		y, 
		dx, 
		dy;

	float angle;
	bool del;
}

Mix_Chunk*[] orbHitSFX;
Mix_Chunk*[] bulletFireSFX;
PrimaryGFX[] bullets;

SDL_Texture *bulletGFX;
int bulletGFXHeight, bulletGFXWidth;
SDL_Rect bulletGFXRect;
int bulletMoveLength = 20;
ubyte bulletVolume = 55;
ubyte orbHitVolume = 70;
float fireCooldown = -1;
float angleOffset = 0.1;
int radius = 10;
bool primaryFire;
bool sequencePlaying;
int sequenceIndex = 0;
int bulletMargin = 10;

void setup()
{
	bulletGFX = IMG_LoadTexture(renderer, "img/primaryBullet.png");
	SDL_QueryTexture(bulletGFX, null, null, &bulletGFXWidth, &bulletGFXHeight);
	assert(bulletGFX);
	bulletGFXRect.w = bulletGFXWidth, bulletGFXRect.h = bulletGFXHeight;

	utils.loadSFXFromDisk("sfx/orbHitScale/", orbHitSFX);
	foreach(audio; orbHitSFX)
	{
		assert(audio);
		audio.volume = orbHitVolume;
	} 

	utils.loadSFXFromDisk("sfx/primaryScale/", bulletFireSFX);

	foreach(audio; bulletFireSFX) 
	{
		assert(audio);
		audio.volume = bulletVolume;
	}	
}

void updateAndDraw()
{
	if(primaryFire && !player.dead)
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
			left.angle = gameState.angle + angleOffset;
			left.x = cast(int) (player.xPos + player.radius * cos(left.angle)); 
			left.y = cast(int) (player.yPos + player.radius * sin(left.angle));

			left.dx = cast(int) (bulletMoveLength * cos(left.angle));
			left.dy = cast(int) (bulletMoveLength * sin(left.angle));
			bullets ~= left;

			PrimaryGFX right;
			right.angle = gameState.angle - angleOffset;
			right.x = cast(int) (player.xPos + player.radius * cos(right.angle));
			right.y = cast(int) (player.yPos + player.radius * sin(right.angle));

			right.dx = cast(int) (bulletMoveLength * cos(right.angle));
			right.dy = cast(int) (bulletMoveLength * sin(right.angle));
			bullets ~= right;

			fireCooldown = 2.1; 
		}
	}

	foreach(ref bullet; bullets)
	{
		if((bullet.x < - bulletMargin) || (bullet.x > (app.display_width + bulletMargin)) || 
			(bullet.y < - bulletMargin) || (bullet.y > (app.display_height + bulletMargin)))
		{
			bullet.del = true;
		}

		bulletGFXRect.x = bullet.x - bulletGFXRect.w/2;
		bulletGFXRect.y = bullet.y - bulletGFXRect.h/2;
		SDL_RenderCopy(renderer, bulletGFX, null, &bulletGFXRect);

		bullet.x += bullet.dx;
		bullet.y += bullet.dy;
	}
}
