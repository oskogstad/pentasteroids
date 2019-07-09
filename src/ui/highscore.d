import everything;

final class HighscoreState : AppState
{
    struct Highscore
    {
        SDL_Texture* scoreTexture,
                     nameTexture;

        BigInt score;

        int scoreWidth,
            scoreHeight,
            nameWidth,
            nameHeight;
    }

    JSONValue scoreJSON;
    string filename = "highscore.json";
    Highscore[] highscores;

    SDL_Rect highscoRect,
             headerRect,
             goBackRect;

    SDL_Texture* header, goBack;

    override void setup()
    {
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
                {"name":"OJS","score":1010101010},
                    {"name":"HAL","score":999999999},
                    {"name":"CET","score":88888888},
                    {"name":"PET","score":7777777},
                    {"name":"ETLA","score":666666},
                    {"name":"TUT","score":55555},
                    {"name":"WTD","score":4444},
                    {"name":"OMG","score":333},
                    {"name":"ADN","score":22},
                    {"name":"EOF","score":1}]}`;

            scoreJSON = parseJSON(j);
            scoreJSON["lastEntry"] = "---";
            scoreJSON["gamesPlayed"] = "0";

            append(filename, scoreJSON.toString());
        }

        assert(exists(filename));

        createHighScoreTextures();

        utils.createTexture(renderer, headerRect.w, headerRect.h, "highscore",
                app.fontLarge, &header, score.color);
        assert(header);
        headerRect.x = app.middleX - headerRect.w/2;
        headerRect.y = 50;

        utils.createTexture(renderer, goBackRect.w, goBackRect.h, "press esc to go back",
                app.fontSmall, &goBack, score.color);
        assert(header);
        goBackRect.x = app.middleX - goBackRect.w/2;
    }

    override void updateAndDraw()
    {
        SDL_RenderCopy(renderer, header, null, &headerRect);

        int yOffset = 200;
        int xOffset = 300;

        foreach(highscore; highscores)
        {
            // score
            highscoRect.w = highscore.scoreWidth;
            highscoRect.h = highscore.scoreHeight;
            highscoRect.x = app.display_width - highscoRect.w - xOffset;
            highscoRect.y = yOffset;
            SDL_RenderCopy(renderer, highscore.scoreTexture, null, &highscoRect);

            // name
            highscoRect.w = highscore.nameWidth;
            highscoRect.h = highscore.nameHeight;
            highscoRect.x = xOffset;
            highscoRect.y = yOffset;
            SDL_RenderCopy(renderer, highscore.nameTexture, null, &highscoRect);

            yOffset += highscore.scoreHeight;
        }

        goBackRect.y = display_height - (goBackRect.h + 30);
        SDL_RenderCopy(renderer, goBack, null, &goBackRect);
    }

    bool checkScore(BigInt score)
    {
        foreach(highscore; highscores)
        {
            if(highscore.score < score) return true;
        }
        return false;
    }

    void addNewScore(string name, BigInt score)
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

        foreach(int index, highscore; scoreJSON["highscores"].array)
        {
            Highscore h;
            h.score = highscore["score"].integer;

            // name texture
            string nameAndNumber = to!string(index + 1) ~ ". "~ highscore["name"].str;
            utils.createTexture(app.renderer, h.nameWidth, h.nameHeight, nameAndNumber,
                    app.fontMedium, &h.nameTexture, score.color);
            assert(h.nameTexture);

            // score texture
            utils.createTexture(app.renderer, h.scoreWidth, h.scoreHeight, to!string(highscore["score"]),
                    app.fontMedium, &h.scoreTexture, score.color);
            assert(h.scoreTexture);

            highscores ~= h;
        }
    }

    override void handleInput(ref SDL_Event event)
    {
        if(event.type == SDL_KEYUP)
        {
            auto sym = event.key.keysym.sym;
            switch(sym)
            {
                case SDLK_ESCAPE:
                {
                    gotoAppState(menuState);
                    menuState.selectedIndex = MenuState.MenuItem.START;
                    break;
                }

                default:
                    break;
            }
        }
    }
}

