module game;
import app;

float distanceSquared(int p1x, int p1y, int p2x, int p2y)
{
    return (p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y);
}

struct WorldCell
{
    // background color
    ubyte red, green, blue;
    // todo -------------------------------------------------------------------------------------------------
    // each cell should have a chord, or set of chords?

    // their own texture?
}


class Game
{
	this()
	{

	}
}
