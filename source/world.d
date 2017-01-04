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
int yMargin, xMargin;

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
ubyte currentRed = 0, currentGreen = 0 , currentBlue = 0;

int cellIndexX = 1;
int cellIndexY = 1;
WorldCell currentCell;

void setup() 
{
	stars.setup();

	backgroundRect = new SDL_Rect();
	xMargin = 800;
	yMargin = 600;

	app.loadGFXFromDisk("img/backgrounds/", renderer, backgrounds);
	foreach(texture; backgrounds) assert(texture);

	for(int i = 0; i < WORLD_WIDTH * WORLD_HEIGHT; ++i)
	{
		int row = i / WORLD_HEIGHT;
		int col = (i - row) % WORLD_HEIGHT;

		WorldCell wc;

		wc.background = backgrounds[0];
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

void updateAndDraw()
{
	currentCell = worldGrid[cellIndexX][cellIndexY];

	updateColor(currentRed, currentCell.red);
	updateColor(currentGreen, currentCell.green);
	updateColor(currentBlue, currentCell.blue);

	SDL_SetRenderDrawColor(renderer, currentRed, currentGreen, currentBlue, 0xFF);
	SDL_RenderClear(renderer);
	
	stars.updateAndDraw();

	backgroundRect.w = currentCell.backgroundWidth, backgroundRect.h = currentCell.backgroundHeight;

	if(game.angleMode)
	{
		backgroundRect.x = currentCell.backgroundWidth/2; 
		backgroundRect.y =  currentCell.backgroundHeight/2;
		SDL_RenderCopyEx(renderer, currentCell.background, null, backgroundRect, -game.angle*TO_DEG, null, 0);
	}
	else
	{
		int ax = (app.middleX) - xMargin;
		int bx = (app.middleX) + xMargin;
		int ay = (app.middleY) - yMargin;
		int by = (app.middleY) + yMargin;
		
		int newX = ((player.xPos / app.currentDisplay.w) * (bx - ax)) + ax;
		int newY = ((player.yPos / app.currentDisplay.h) * (by - ay)) + ay;

		backgroundRect.x = newX - currentCell.backgroundWidth/2; 
		backgroundRect.y = newY - currentCell.backgroundHeight/2;
		SDL_RenderCopy(renderer, currentCell.background, null, backgroundRect);
	}
}