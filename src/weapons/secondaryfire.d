import everything;

bool secondaryFire;
SDL_Rect sfSRect, sfDRect;
SDL_Texture* sfGFX;
float fuel;
uint sfSprite;

const int SF_NUM_FRAMES = 14;

immutable float maxFuel = 180;
immutable float fuelDepletionRate = 1.0f;
immutable float fuelRegenRate = 0.1f;

void setup()
{
	fuel = maxFuel;
	
	sfGFX = IMG_LoadTexture(renderer, "img/secondaryFire.png");
	assert(sfGFX);
	
	sfDRect.w = 2300;
	sfDRect.h = 200;
	
	sfSRect.w = 2300; 
	sfSRect.h = 200;
	sfSRect.x = 0;
}

void updateAndDraw()
{
    // Keep this outside the if, because we use it to animate the fuel meter in Player as well
    sfSprite = (app.ticks/25) % SF_NUM_FRAMES; // /25 for slowing down animation
    sfSRect.y = sfSprite * 200; // 200 height of texture-----------------------------------------------------------------------------------------

	if(secondaryFire && fuel > 0)
	{
		sfDRect.x = player.xPos;
		sfDRect.y = player.yPos - sfDRect.h/2;
		
		immutable SDL_Point p = SDL_Point(0, sfDRect.h/2);

		SDL_RenderCopyEx(renderer, sfGFX, &sfSRect, &sfDRect, angle*TO_DEG, &p, 0);

		fuel -= fuelDepletionRate;
        if(fuel < 0) {
            fuel = 0;
            secondaryFire = false;
        }
	}	
    else {
        if((fuel += fuelRegenRate) > 180) fuel = maxFuel;
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
