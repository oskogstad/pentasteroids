import everything;

struct Spark
{
	int
		x,
		y,
		dx,
		dy,
		ttl;

	ubyte
		red,
		green,
		blue;

	float angle;
	bool del;
}

Spark[] activeSparks;
SDL_Rect* sparkRect;

void setup()
{
	sparkRect = new SDL_Rect();
	sparkRect.w = 12; sparkRect.h = 22;
}

void updateAndDraw()
{
	foreach(ref spark; activeSparks)
	{
		if(--spark.ttl <= 0)
		{
			spark.del = true;
			continue;
		}

		spark.x += spark.dx;
		spark.y += spark.dy;

		spark.red += uniform(1, 5);
		spark.blue += uniform(1, 5);
		spark.green += uniform(1, 5);
		
		if(spark.ttl < spark.ttl*0.9)
		{
			if(spark.dx > 0)
			{
				spark.dx -= uniform(1,3);
			}
			else
			{
				spark.dx += uniform(1, 3);
			}

			if(spark.dy > 0)
			{
				spark.dy -= uniform(1, 3);
			}
			else
			{
				spark.dy += uniform(1, 3);
			}
		}

		sparkRect.x = spark.x; sparkRect.y = spark.y;
		SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
		SDL_SetRenderDrawColor(renderer, spark.red, spark.green, spark.blue, 0xFF);
		SDL_RenderFillRect(renderer, sparkRect);
	}

	activeSparks = remove!(spark => spark.del)(activeSparks);
} 

void createSparks(int x, int y ,int dx, int dy, float angle, int count)
{
	for(int i = 0; i < count; i++)
	{
		Spark s;
		s.angle = angle;
		s.x = x;
		s.y = y;
		float newDX = -dx;
		float newDY = -dy;

		float length = sqrt(newDX * newDX + newDY * newDY);
		
		newDX /= length;
		newDY /= length;
		
		newDX += uniform(-0.4f, 0.4f);
		newDY += uniform(-0.4f, 0.4f);

		s.dx = cast(int)(newDX * uniform(3, 6));
		s.dy = cast(int)(newDY *uniform(3,6));

		s.ttl = uniform(50, 100);
		s.red = to!ubyte(uniform(0, 255));
		s.green = to!ubyte(uniform(0, 255));
		s.blue = to!ubyte(uniform(0, 255));
		activeSparks ~= s;
	}
}