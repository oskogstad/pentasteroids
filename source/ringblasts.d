import app;

struct Blast 
{
	bool del, shake;
	int 
		x, 
		y,
		radius,
		targetRadius;
}

Blast[] activeBlasts;
SDL_Point*[] circlePoints;
const int NUM_SIDES = 120;
const float ANGLE_STEP = (PI * 2) / NUM_SIDES;

void updateAndDraw()
{
	activeBlasts = remove!(blast => blast.del)(activeBlasts);

	// set draw color to black

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

		calcCirclePoints(x, y);
		blast.radius += 0.1;
		if(blast.radius >= blast.targetRadius) blast.del = true;
	}

	SDL_RenderDrawLines(renderer, circlePoints[0], circlePoints.length);
}

void calcCirclePoints(int x, int y)
{
	circlePoints.length = 0;

	for(int i = 0; i != NUM_SIDES; i++)
	{
		SDL_Point* start = new SDL_Point();
		SDL_Point* end = new SDL_Point();

		
		circlePoints ~= p;
	}
}

void createBlast(int x, int y, Size bs)
{
	Blast b;
	b.x = x;
	b.y = y;
	b.radius = 2;

	if(bs == Size.SMALL)
	{
		b.targetRadius = bs;
	} 
	else if(bs == Size.MEDIUM)
	{
		b.targetRadius = bs/2;
	} 
	else
	{
		b.targetRadius = bs/2;
	} 

	activeBlasts ~= b;
}