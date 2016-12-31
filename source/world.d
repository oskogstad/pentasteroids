import app;

struct WorldCell
{
	SDL_Texture *background;
	int backgroundWidth, backgroundHeight;
    ubyte red, green, blue;
    Mix_Chunk*[] chords;
}

const int WORLD_WIDTH = 3, WORLD_HEIGHT = 3;

SDL_Rect* backgroundRect;
SDL_Texture*[] backgrounds;

ubyte[3][9] backgroundColors = 
[
	[47, 84, 78], 
	[33, 59, 55],
	[60, 100, 100],
	[54, 75, 84],
	[37, 52, 59],
	[0, 67, 67], // initial cell
	[100, 80, 40],
	[80, 100, 70],
	[90, 70, 100]
];

WorldCell[WORLD_HEIGHT][WORLD_WIDTH] worldGrid;

int worldWidth = 3, worldHeight = 3;
ubyte currentRed = 0, currentGreen = 67 , currentBlue = 67;

int cellIndexX = 1;
int cellIndexY = 1;
WorldCell currentCell;

void setup(SDL_Renderer *renderer) 
{
	stars.setup();

	backgroundRect = new SDL_Rect();

	app.loadGFXFromDisk("img/backgrounds/", renderer, backgrounds);
	foreach(texture; backgrounds) assert(texture);

	for(int i = 0; i < WORLD_WIDTH * WORLD_HEIGHT; ++i)
	{
		int row = i / WORLD_HEIGHT;
		int col = (i - row) % WORLD_HEIGHT;

		WorldCell wc;

		wc.background = backgrounds[i];
        SDL_QueryTexture(wc.background, null, null, &wc.backgroundWidth, &wc.backgroundHeight);

        wc.red = backgroundColors[i][0];
        wc.green = backgroundColors[i][1];
        wc.blue = backgroundColors[i][2];
        
        worldGrid[row][col] = wc;
	}	

    currentCell = worldGrid[cellIndexX][cellIndexY];
}

void updateColor(ref ubyte current, ubyte target)
{
	if(current != target)
	{
		if(current < target)
		{
			current++;
		}
		else
		{
			current--;
		}	
	}
}

void updateAndDraw(SDL_Renderer *renderer)
{
	currentCell = worldGrid[cellIndexX][cellIndexY];

	updateColor(currentRed, currentCell.red);
	updateColor(currentGreen, currentCell.green);
	updateColor(currentBlue, currentCell.blue);

	SDL_SetRenderDrawColor(renderer, currentRed, currentGreen, currentBlue, 0xFF);
	SDL_RenderClear(renderer);
	
	stars.updateAndDraw(renderer);

	backgroundRect.w = currentCell.backgroundWidth, backgroundRect.h = currentCell.backgroundHeight;
	backgroundRect.x = (app.currentDisplay.w / 2) - (currentCell.backgroundWidth / 2);
	backgroundRect.y = (app.currentDisplay.h / 2) - (currentCell.backgroundHeight / 2);

	if(game.angleMode)
	{
		SDL_RenderCopyEx(renderer, currentCell.background, null, backgroundRect, -game.angle, null, 0);
	}
	else
	{
		backgroundRect.x += cast(int)(player.xPos * 0.05); 
		backgroundRect.y += cast(int) (player.yPos * 0.05);
		SDL_RenderCopy(renderer, currentCell.background, null, backgroundRect);
	}
}