import app;

JSONValue currentHighScore;
string filename = "highscore.json";
Highscore[] textures;
SDL_Rect* highscoRect;

struct Highscore
{
	SDL_Texture* texture;
	long score;
	int width, height;
}

void setup(SDL_Renderer* renderer)
{
	highscoRect = new SDL_Rect();

	if(exists(filename))
	{
		string filetext = to!string(read(filename));
		currentHighScore = parseJSON(filetext);
	}

	else
	{
		currentHighScore["lastEntry"] = "---";
		currentHighScore["gamesPlayed"] = 0;
		currentHighScore["highscores"] = 
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

		append(filename, currentHighScore.toString());
	}

	assert(exists(filename));

	// create all menu-items, with delays, textures
	foreach(uint index, highscore; currentHighScore["highscores"])
	{
		Highscore h;
		auto splitline = split(highscore.toString().replace("\"", ""));
		h.score = to!long(splitline[1]);
		app.createTexture(renderer, h.width, h.height, highscore.toString().replace("\"", ""),
        app.fontMedium, &h.texture, score.color);
        assert(h.texture);
        textures ~= h;
	}
}

void updateAndDraw(SDL_Renderer* renderer)
{
	int offset = 0;
	foreach(highscore; textures)
	{
		highscoRect.w = highscore.width;
		highscoRect.h = highscore.height;

		highscoRect.x = app.currentDisplay.w/2 - highscoRect.w/2;
		highscoRect.y = 0 + offset;
		writeln(highscoRect);
		SDL_RenderCopy(renderer, highscore.texture, null, highscoRect);
		offset += highscore.height;
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
