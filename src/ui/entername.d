import everything;

final class EnterNameState : AppState
{
    int charOffset;
    int charIndex = 2;

    struct MenuTexture
    {
        SDL_Texture* texture;
        SDL_Rect rect;

        void create(int x, int y, string text, TTF_Font* font)
        {
            this.text = text;
            utils.createTexture(renderer, rect.w, rect.h, text, font, &texture, score.color);
            rect.x = x - rect.w/2;
            rect.y = y - rect.h/2;
        }

        void updateTexture(char c, TTF_Font* font)
        {
            utils.createTexture(renderer, rect.w, rect.h, [c], font, &texture, score.color);
        }

        void render()
        {
            SDL_RenderCopy(renderer, texture, null, &rect);
        }
    }

    int letterCount;
    char[] initials;
    MenuTexture[7] menuTextures;

    override void setup()
    {
        charOffset = 120;

        initials ~= ['-', '-', '-'];
        menuTextures[0].create(app.middleX, 200, "new highscore!", app.fontLarge);
        menuTextures[1].create(app.middleX, 400, "enter initials", app.fontMedium);
        menuTextures[2].create(app.middleX - charOffset, 700, "-", app.fontLarge);
        menuTextures[3].create(app.middleX, 700, "-", app.fontLarge);
        menuTextures[4].create(app.middleX + charOffset, 700, "-", app.fontLarge);
        menuTextures[5].create(app.middleX,	900, "or press escape", app.fontSmall);
        menuTextures[6].create(app.middleX, 1000, "press enter to confirm", app.fontMedium);
    }


    override void updateAndDraw()
    {
        foreach(ref mt; menuTextures[0 .. $-1])
        {
            mt.render();
        }

        if(charIndex > 4) menuTextures[$-1].render();
    }

    override void handleInput(ref SDL_Event event)
    {
        if(event.type == SDL_KEYUP)
        {
            auto s = event.key.keysym.sym;
            if(s == SDLK_RETURN)
            {
                if(charIndex > 4)
                {
                    highscoreState.addNewScore(cast(string)initials, score.currentScore);
                    gameState.resetGame();
                    gotoAppState(highscoreState);
                }
            }

            else if(s == SDLK_BACKSPACE)
            {
                if(--charIndex < 2) charIndex = 2;
                menuTextures[charIndex].updateTexture('-', app.fontLarge);
                initials[charIndex - 2] = '-';
            }

            else if(s == SDLK_ESCAPE)
            {
                gotoAppState(menuState);
                menuState.selectedIndex = MenuState.MenuItem.HIGHSCORE;
            }

            else if(s >= SDLK_a && s <= SDLK_z)
            {
                if(charIndex <= 4)
                {
                    initials[charIndex - 2] = cast(char) s;
                    menuTextures[charIndex++].updateTexture(cast(char) s, app.fontLarge);
                }
            }
        }
    }
}

