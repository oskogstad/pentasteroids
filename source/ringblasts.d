import app;

struct Blast 
{
	bool del, shake;
	float radius, targetRadius;
	int x, y;
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

		drawCircle(x, y, blast.radius);
		blast.radius += 2.5;
		if(blast.radius >= blast.targetRadius) blast.del = true;
	}
}

void drawCircle(int x, int y, float radius)
{
	SDL_Point[361] points;

    float theta = 0;
    float thetaInc = 2f*3.1415f / 360.0f;
    for (int i=0; i<=360; ++i)
    {
        points[i] = SDL_Point(cast(int)(x+cos(theta)*radius), cast(int)(y+sin(theta)*radius));
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