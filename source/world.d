module world;
import app;

struct WorldCell
{
	SDL_Texture *background;
    // background color
    ubyte red, green, blue;
    // todo -------------------------------------------------------------------------------------------------
    // each cell should have a chord, or set of chords?
    // their own texture?
}

WorldCell[3][3] worldGrid;
int worldWidth = 3, worldHeight = 3;
ubyte currentRed = 0, currentGreen = 67 , currentBlue = 67;
int cellIndexX = 1;
int cellIndexY = 1;
WorldCell currentCell;

void setup(SDL_Renderer *renderer) 
{
	for(int i = 0; i < worldHeight; ++i){
		for(int j = 0; j < worldWidth; ++j)
		{
            // random bgColor for now --------------------------------------------------------------------------------------
            // 0x00, 0x43, 0x43 // want this one maybe ------------------------------------------------------------------
            WorldCell wc;
            wc.red = cast(ubyte) uniform(20, 90);
            wc.green = cast(ubyte) uniform(20, 90);
            wc.blue = cast(ubyte) uniform(20, 90);
            worldGrid[i][j] = wc;
        }
    }

    currentCell = worldGrid[cellIndexX][cellIndexY];
}


void updateAndDraw(SDL_Renderer *renderer)
{
	currentCell = worldGrid[cellIndexX][cellIndexY];

	if(currentRed != currentCell.red)
	{
		if(currentRed < currentCell.red)
		{
			currentRed++;
		}
		else
		{
			currentRed--;
		}
	}
	if(currentGreen != currentCell.green)
	{
		if(currentGreen < currentCell.green)
		{
			currentGreen++;
		}
		else
		{
			currentGreen--;
		}
	}
	if(currentBlue != currentCell.blue)
	{
		if(currentBlue < currentCell.blue)
		{
			currentBlue++;
		}
		else
		{
			currentBlue--;
		}
	}

	SDL_SetRenderDrawColor(renderer, currentRed, currentGreen, currentBlue, 0xFF);
	SDL_RenderClear(renderer);
}