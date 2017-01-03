import app;

JSONValue scoreJSON;
string filename = "highscore.json";
Highscore[] highscores;
SDL_Rect* highscoRect, headerRect, goBackRect;
SDL_Texture* header, goBack;

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
	headerRect = new SDL_Rect();
	goBackRect = new SDL_Rect();

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

	app.createTexture(renderer, headerRect.w, headerRect.h, "highscore",
		app.fontLarge, &header, score.color);
	assert(header);
	headerRect.x = app.currentDisplay.w/2 - headerRect.w/2;
	headerRect.y = 50;

	app.createTexture(renderer, goBackRect.w, goBackRect.h, "press esc to go back",
		app.fontSmall, &goBack, score.color);
	assert(header);
	goBackRect.x = app.currentDisplay.w/2 - goBackRect.w/2;
}

void updateAndDraw(SDL_Renderer* renderer)
{
	SDL_RenderCopy(renderer, header, null, headerRect);

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

	goBackRect.y = yOffset + 20;
	SDL_RenderCopy(renderer, goBack, null, goBackRect);
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
