import app;

enum Size
{
	TINY = 64,
	SMALL = 128,
	MEDIUM = 512,
	LARGE = 1024
}

struct Orb
{
	SDL_Texture* texture;

	Size size;

	int 
		x, 
		y,
		radius,
		radiusSquared,
		dx,
		dy,
		moveSpeed,
		hitPoints,
		hitSFXindex,
		animationOffset, 
		animationDivisor;

	bool 
		hasBeenOnScreen, 
		del, 
		isShaking;

	float 
		angle, 
		spinningSpeed, 
		shakeTimer;
}

