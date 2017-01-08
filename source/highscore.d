import app;

JSONValue scoreJSON;
string filename = "highscore.json";
Highscore[] highscores;
SDL_Rect* 
	highscoRect, 
	headerRect, 
	goBackRect;

SDL_Texture* header, goBack;

struct Highscore
{
	SDL_Texture* 
		scoreTexture, 
		nameTexture;
		
	ulong score;

	int 
		scoreWidth, 
		scoreHeight,
		nameWidth,
		nameHeight;
}

void setup()
{
	highscoRect = new SDL_Rect();
	headerRect = new SDL_Rect();
	goBackRect = new SDL_Rect();

	scope(failure)
	{
		// todo
		// if file load/write fails
	}

	if(exists(filename))
	{
		string filetext = to!string(read(filename));
		scoreJSON = parseJSON(filetext);
	}

	else
	{
		string j = `{"highscores":[
			{"name":"OJS","score":9999999999999},
			{"name":"HAL","score":900090009000},
			{"name":"CET","score":88888888888},
			{"name":"PET","score":7777777777},
			{"name":"ETLA","score":666666666},
			{"name":"TUT","score":55555555},
			{"name":"WTD","score":4444444},
			{"name":"OMG","score":333333},
			{"name":"ADN","score":22222},
			{"name":"EOF","score":1111}]}`;

		scoreJSON = parseJSON(j);
		scoreJSON["lastEntry"] = "---";
		scoreJSON["gamesPlayed"] = "0";

		append(filename, scoreJSON.toString());
	}

	assert(exists(filename));

	createHighScoreTextures();

	app.createTexture(renderer, headerRect.w, headerRect.h, "highscore",
		app.fontLarge, &header, score.color);
	assert(header);
	headerRect.x = app.middleX - headerRect.w/2;
	headerRect.y = 50;

	app.createTexture(renderer, goBackRect.w, goBackRect.h, "press esc to go back",
		app.fontSmall, &goBack, score.color);
	assert(header);
	goBackRect.x = app.middleX - goBackRect.w/2;
}

void updateAndDraw()
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
		highscoRect.y = yOffset;
		SDL_RenderCopy(renderer, highscore.scoreTexture, null, highscoRect);

		// name
		highscoRect.w = highscore.nameWidth;
		highscoRect.h = highscore.nameHeight;
		highscoRect.x = xOffset;
		highscoRect.y = yOffset;
		SDL_RenderCopy(renderer, highscore.nameTexture, null, highscoRect);

		yOffset += highscore.scoreHeight;
	}

	goBackRect.y = yOffset + 20;
	SDL_RenderCopy(renderer, goBack, null, goBackRect);
}

bool checkScore(ulong score)
{
	foreach(highscore; highscores)
	{
		if(highscore.score < score) return true;
	}
	return false;
}

void addNewScore(string name, ulong score)
{
	string j = `{"name":"` ~ name ~ `","score":` ~ to!string(score) ~ `}`;
	scoreJSON["highscores"].array ~= parseJSON(j);
	scoreJSON["highscores"].array.sort!((a, b) => a["score"].integer > b["score"].integer);	
	scoreJSON["highscores"].array.length = 10;
	createHighScoreTextures();
	std.file.write(filename, scoreJSON.toString());
}

void createHighScoreTextures()
{
	highscores.length = 0;

	foreach(uint index, highscore; scoreJSON["highscores"])
	{
		Highscore h;
		h.score = highscore["score"].integer;

		// name texture
        string nameAndNumber = to!string(index + 1) ~ ". "~ highscore["name"].str;
        app.createTexture(app.renderer, h.nameWidth, h.nameHeight, nameAndNumber,
        	app.fontMedium, &h.nameTexture, score.color);
        assert(h.nameTexture);

		// score texture
		app.createTexture(app.renderer, h.scoreWidth, h.scoreHeight, to!string(highscore["score"]),
        	app.fontMedium, &h.scoreTexture, score.color);
        assert(h.scoreTexture);
        
        highscores ~= h;
	}
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
