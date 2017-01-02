import app;

JSONValue currentHighScore;
string filename = "highscore.json";
struct Highscore
{
	SDL_Texture* texture;

}

void setup(SDL_Renderer* renderer)
{
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
			"OJS 999,999,999,999",
			"HAL 900,090,009,000",
			"CET 888,888,888,888",
			"PET 777,777,777,777",
			"ETLA 666,666,666,666",
			"TUT 555,555,555,555",
			"WTD 444,444,444,444",
			"OMG 333,333,333,333",
			"ADN 222,222,222,222",
			"EOF 111,111,111,111"
		];
		append(filename, currentHighScore.toString());
	}

	// create all menu-items, with delays, textures
}

void updateAndDraw(SDL_Renderer* renderer)
{
	// update animation
}

bool checkScore(long score)
{
	return false;
}

void addNewScore(string name, long score)
{

}
