import app;

JSONValue scoreJSON;
string filename = "highscore.json";
Highscore[] highscores;
SDL_Rect* highscoRect;

struct Highscore
{
	SDL_Texture* 
		scoreTexture, 
		nameTexture;
	
	long score;
	
	int 
		scoreWidth, 
		scoreHeight,
		nameWidth,
		nameHeight;
}

void setup(SDL_Renderer* renderer)
{
	highscoRect = new SDL_Rect();

	if(exists(filename))
	{
		string filetext = to!string(read(filename));
		scoreJSON = parseJSON(filetext);
	}

	else
	{
		scoreJSON["lastEntry"] = "---";
		scoreJSON["gamesPlayed"] = 0;
		scoreJSON["highscores"] = 
		[
			"OJS 999999999999",
			"HAL 900090009000",
			"CET 888888888888",
			"PET 777777777777",
			"ETLA 666666666666",
			"TUT 555555555555",
			"WTD 444444444444",
			"OMG 333333333333",
			"ADN 222222222222",
			"EOF 111111111111"
		];

		append(filename, scoreJSON.toString());
	}

	assert(exists(filename));

	
	foreach(uint index, highscore; scoreJSON["highscores"])
	{
		Highscore h;
		// name [0], score [1]
		auto splitline = split(highscore.toString().replace("\"", ""));
		h.score = to!long(splitline[1]);
		
		// score texture
		app.createTexture(renderer, h.scoreWidth, h.scoreHeight, splitline[1],
        	app.fontMedium, &h.scoreTexture, score.color);
        assert(h.scoreTexture);
        
        // name texture
        string nameAndNumber = to!string(index + 1) ~ ". "~ splitline[0];
        app.createTexture(renderer, h.nameWidth, h.nameHeight, nameAndNumber,
        	app.fontMedium, &h.nameTexture, score.color);
        assert(h.nameTexture);

        highscores ~= h;
	}
}

void updateAndDraw(SDL_Renderer* renderer)
{
	int yOffset = 200;
	int xOffset = 300;

	foreach(highscore; highscores)
	{
		// score
		highscoRect.w = highscore.scoreWidth;
		highscoRect.h = highscore.scoreHeight;
		highscoRect.x = app.currentDisplay.w - highscoRect.w - xOffset;
		highscoRect.y = 0 + yOffset;
		SDL_RenderCopy(renderer, highscore.scoreTexture, null, highscoRect);

		// name
		highscoRect.w = highscore.nameWidth;
		highscoRect.h = highscore.nameHeight;
		highscoRect.x = 0 + xOffset;
		highscoRect.y = 0 + yOffset;
		SDL_RenderCopy(renderer, highscore.nameTexture, null, highscoRect);

		yOffset += highscore.scoreHeight;
	}
}

bool checkScore(long score)
{
	return false;
}

void addNewScore(string name, long score)
{

}

void handleInput(SDL_Event event)
{
	switch(event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
		{
			app.state = AppState.MENU;
			menu.selectedIndex = MenuItem.START; 
			break;			
		}

		default:
			break;
	}
}
