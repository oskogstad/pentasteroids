import everything;

final class MenuState : AppState
{
    enum MenuItem
    {
        START,
        HIGHSCORE,
        CREDITS,
        QUIT
    }

    SDL_Texture*[string] menuGFX;
    ubyte menuSFXVolume = 60;

    int menuSFXIndexOne,
        menuSFXIndexTwo,
        menuSFXIndexThree;

    SDL_Rect* menuRect;
    Mix_Chunk*[] menuSFX;

    int selectedIndex;
    int spacing;

    override void setup()
    {
        spacing = 100;

        selectedIndex = MenuItem.START;

        menuRect = new SDL_Rect();

        foreach(path; dirEntries("img/menu/", SpanMode.depth))
        {
            string chomp = chomp(path, ".png");
            chomp = chompPrefix(chomp, "img/menu/");
            menuGFX[chomp] = IMG_LoadTexture(renderer, path.toStringz());
        }
        foreach(sfx; menuGFX) assert(sfx);

        utils.loadSFXFromDisk("sfx/menuScale/", menuSFX);
        foreach(sfx;menuSFX)
        {
            assert(sfx);
            sfx.volume = menuSFXVolume;
        }
    }

    override void updateAndDraw()
    {
        menuRect.w = app.display_width;
        menuRect.h = 160;
        menuRect.x = 0; menuRect.y = 450;
        SDL_RenderCopy(renderer, menuGFX["logo"], null, menuRect);

        menuRect.h = spacing;
        menuRect.y = 650;

        if(selectedIndex == MenuItem.START)
        {
            drawMenuItem("continue", "start", gameState.gameInProgress);
        }
        else
        {
            drawMenuItem("continue_", "start_", gameState.gameInProgress);
        }

        menuRect.y += spacing;
        drawMenuItem("highscore", "highscore_", selectedIndex == MenuItem.HIGHSCORE);

        menuRect.y += spacing;
        drawMenuItem("credits", "credits_", selectedIndex == MenuItem.CREDITS);

        menuRect.y += spacing;
        drawMenuItem("quit", "quit_", selectedIndex == MenuItem.QUIT);
    }

    void drawMenuItem(string item, string item_, bool condition)
    {
        if(condition)
        {
            SDL_RenderCopy(renderer, menuGFX[item], null, menuRect);
        }
        else
        {
            SDL_RenderCopy(renderer, menuGFX[item_], null, menuRect);
        }
    }

    override void handleInput(ref SDL_Event event)
    {
        playSFX();

        if(event.type == SDL_KEYUP)
        {
            auto sym = event.key.keysym.sym;

            switch(sym)
            {
                case SDLK_ESCAPE:
                {
                    running = false;
                    break;
                }

                case SDLK_RETURN:
                {
                    switch(selectedIndex) with (MenuItem)
                    {
                        case START:
                            gotoAppState(gameState);
                            gameState.gameInProgress = true;
                            break;

                        case HIGHSCORE:
                            gotoAppState(highscoreState);
                            break;

                        case CREDITS:
                            gotoAppState(creditsState);
                            break;

                        case QUIT:
                            app.running = false;
                            break;

                        default:
                            break;
                    }
                    break;
                }

                case SDLK_w:
                case SDLK_UP:
                {
                    if(--selectedIndex < MenuItem.min) selectedIndex = MenuItem.max;
                    break;
                }

                case SDLK_s:
                case SDLK_DOWN:
                {
                    if(++selectedIndex > MenuItem.max) selectedIndex = MenuItem.min;
                    break;
                }

                default:
                    break;
            }
        }
    }

    void playSFX()
    {
        menuSFXIndexOne = uniform(0, 4);
        menuSFXIndexTwo = uniform(4, 8);
        menuSFXIndexThree = uniform(8, 11);

        Mix_PlayChannel(-1, menuSFX[menuSFXIndexOne], 0);
        Mix_PlayChannel(-1, menuSFX[menuSFXIndexTwo], 0);
        Mix_PlayChannel(-1, menuSFX[menuSFXIndexThree], 0);
    }
}

