import everything;

struct Blast 
{
	bool 
		del, 
		shake;
	
	float 
		radius, 
		targetRadius;
	
	int 
		x, 
		y;

	ubyte	
		red,
		green,
		blue,
		alpha;
}


Blast[] activeBlasts;

void updateAndDraw()
{
	activeBlasts = remove!(blast => blast.del)(activeBlasts);

	foreach(ref blast; activeBlasts)
	{
		int x, y;
		if(blast.shake)
		{
			x = blast.x + uniform(-3, 3);
			y = blast.y + uniform(-3, 3);
		}
		else
		{
			x = blast.x;
			y = blast.y;
		}

		SDL_SetRenderDrawColor(renderer, blast.red, blast.green, blast.blue, blast.alpha);

		drawCircle(x, y, blast.radius);
		blast.red += uniform(1,3);
		drawCircle(x, y, blast.radius - 1);
		blast.green += uniform(2,5);
		drawCircle(x, y, blast.radius - 2);
		blast.blue += uniform(3,12);

		blast.radius += 2.6;
		if(blast.radius >= blast.targetRadius) blast.del = true;
	}
}

void drawCircle(int x, int y, float radius)
{
	immutable static int NUM_SEGMENTS= 181;
	SDL_Point[NUM_SEGMENTS] points;

	float theta = 0;
	float thetaInc = 2f*3.1415f / NUM_SEGMENTS;
	for (int i=0; i<NUM_SEGMENTS; ++i)
	{
		points[i] = SDL_Point(
			cast(int)(x+cos(theta)*radius),
			cast(int)(y+sin(theta)*radius));
		theta += thetaInc;
	}
	SDL_RenderDrawLines(renderer, points.ptr, points.length);
}

void createBlast(int x, int y, Size bs)
{
	Blast b;
	b.x = x;
	b.y = y;
	b.radius = 2;
	b.red = cast(ubyte)uniform(0, 256);
	b.green = cast(ubyte)uniform(0, 256);
	b.blue = cast(ubyte)uniform(0, 256);
	b.alpha = cast(ubyte) 255;

	if(bs == Size.SMALL)
	{
		b.targetRadius = bs;
	} 
	else if(bs == Size.MEDIUM)
	{
		b.targetRadius = bs/2;
	} 
	else if(bs == Size.TINY)
	{
		b.targetRadius = bs;
	}

	activeBlasts ~= b;
}