import everything;

bool secondaryFire;
SDL_Rect sfSRect, sfDRect;
SDL_Texture* sfGFX;
float fuel;
uint sfSprite;

const int SF_NUM_FRAMES = 14;

void setup()
{
	fuel = 180;
	
	sfGFX = IMG_LoadTexture(renderer, "img/secondaryFire.png");
	assert(sfGFX);
	
	sfDRect.w = cast(int)(2300 * app.xScale);
	sfDRect.h = 200;
	
	sfSRect.w = 2300; 
	sfSRect.h = 200;
	sfSRect.x = 0;
}

void updateAndDraw()
{
	if(secondaryFire && fuel > 0)
	{
		sfSprite = (app.ticks/25) % SF_NUM_FRAMES; // /25 for slowing down animation
		sfSRect.y = sfSprite * 200; // 200 height of texture-----------------------------------------------------------------------------------------
		
		sfDRect.x = player.xPos;
		sfDRect.y = player.yPos - sfDRect.h/2;
		
		SDL_Point p; p.x = 0 ; p.y = sfDRect.h/2;

		SDL_RenderCopyEx(renderer, sfGFX, &sfSRect, &sfDRect, angle*TO_DEG, &p, 0);
		//fuel-=1f;
	}	
}

bool hitByBeam(float enemyX, float enemyY, float enemyRadius, float beamOriginX, float beamOriginY, float beamAngle, float beamWidth)
{
    float vx, vy; // Direction vector of the beam
    vx = cos(beamAngle);
    vy = sin(beamAngle);

    float ex, ey; // Vector from beam origin to enemy position
    ex = enemyX - beamOriginX;
    ey = enemyY - beamOriginY;

    float distanceFromCenterLine = abs(vx*ey - vy*ex); // the distance from the enemy center to the middle ray of the beam
    if (distanceFromCenterLine < (enemyRadius + beamWidth/2))
    {
        // Normalize the vector from beam origin to enemy. eLength is the distance from the enemy to the beam origin
        float eLength = sqrt(ex*ex + ey*ey);
        ex /= eLength;
        ey /= eLength;

        if ((vx*ex + vy*ey) <= 0)
        {
            // This is an edge case where the enemy origin is behind the beam, but it's radius might still be large enoughfor it to be hit.
            // We handle this case using normal circle vs circle collision test.
            return eLength < enemyRadius+beamWidth/2;
        }
        else
        {
            return true;
        }
    }
    else
    {
        return false;
    }
}