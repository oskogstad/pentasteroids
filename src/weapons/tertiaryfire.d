import everything;

bool hasBomb;

Mix_Chunk*
	bombSFX,
	noBombSFX;

void setup()
{
	// load bomb
}


void updateAndDraw()
{
	// if bomb alive draw bomb
	// step decr. bomb
}

void detonate()
{
	if(hasBomb)
	{
		primaryfire.primaryFire = false;
		secondaryfire.secondaryFire = false;

		// make bomb alive
	}
	else
	{
		// play no bomb sfx
	}
}