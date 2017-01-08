import everything;

struct Star
{
	int x, y;
	int pulseSpeed;
	ubyte currentOpacity;
	bool rising;
}

Star[] stars;

void setup()
{
	for(int i = 0; i < 100; i++)
	{
		Star s;
		s.x = uniform(0, app.currentDisplay.w);
		s.y = uniform(0, app.currentDisplay.h);
		s.pulseSpeed = uniform(1,3);
		s.currentOpacity = cast(ubyte)uniform(20, 200);
		s.rising = uniform(0,2) == 1 ? true : false;

		stars ~= s;
	}
}

void updateAndDraw()
{
	SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_ADD);
	foreach(ref star; stars)
	{
		if(star.rising)
		{
			star.currentOpacity += star.pulseSpeed;
			if(star.currentOpacity >= 0xFF)
			{
				star.rising = false;
				star.currentOpacity = 0xFF;
			}
		}
		else
		{
			star.currentOpacity -= star.pulseSpeed;
			if(star.currentOpacity <= 0x01)
			{
				star.rising = true;
				star.currentOpacity = 0x21;
			}
		}

		SDL_SetRenderDrawColor(renderer, 0xEE, 0xEE, 0xEE, star.currentOpacity);
		SDL_RenderDrawPoint(renderer, star.x, star.y);
		SDL_RenderDrawPoint(renderer, star.x, star.y - 1);
		SDL_RenderDrawPoint(renderer, star.x - 1, star.y);
		SDL_RenderDrawPoint(renderer, star.x + 1, star.y);
		SDL_RenderDrawPoint(renderer, star.x, star.y + 1);
	}
}

