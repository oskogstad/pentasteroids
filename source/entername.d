import everything;

int charOffset;
int charIndex = 2;

struct MenuTexture
{
	SDL_Texture* texture;
	SDL_Rect rect;

	void create(int x, int y, string text, TTF_Font* font)
	{
		this.text = text;
		app.createTexture(renderer, rect.w, rect.h, text, font, &texture, score.color);
		rect.w = cast(int)(rect.w * app.xScale);
		rect.h = cast(int)(rect.h*app.yScale);
		rect.x = x - rect.w/2;
		rect.y = y - rect.h/2;
	}

	void updateTexture(char c, TTF_Font* font)
	{
		app.createTexture(renderer, rect.w, rect.h, [c], font, &texture, score.color);
	}

	void render()
	{
		SDL_RenderCopy(renderer, texture, null, &rect);
	}
}

int letterCount;
char[] initials;
MenuTexture[7] menuTextures;

void setup()
{
	charOffset = cast(int)(120 * app.xScale);

    initials ~= ['-', '-', '-'];
	menuTextures[0].create(app.middleX, cast(int)(app.yScale * 200), "new highscore!", app.fontLarge);
	menuTextures[1].create(app.middleX, cast(int)(app.yScale * 400), "enter initials", app.fontMedium);
	menuTextures[2].create(app.middleX - charOffset, cast(int)(app.yScale * 700), "-", app.fontLarge);
	menuTextures[3].create(app.middleX, cast(int)(app.yScale * 700), "-", app.fontLarge);
	menuTextures[4].create(app.middleX + charOffset, cast(int)(app.yScale * 700), "-", app.fontLarge);
	menuTextures[5].create(app.middleX,	cast(int)(app.yScale * 900), "or press escape", app.fontSmall);
	menuTextures[6].create(app.middleX, cast(int)(app.yScale * 1000), "press enter to confirm", app.fontMedium);	
}
		

void updateAndDraw()
{
	foreach(ref mt; menuTextures[0 .. $-1])
	{
		mt.render();
	}

	if(charIndex > 4) menuTextures[$-1].render(); 
}

void handleInput(SDL_Event event)
{
	auto s = event.key.keysym.sym;
	if(s == SDLK_RETURN)
	{
		if(charIndex > 4)
		{
			highscore.addNewScore(cast(string)initials, score.currentScore);
			game.resetGame();
			app.state = AppState.HIGHSCORE;
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
		app.state = AppState.MENU;
		menu.selectedIndex = MenuItem.HIGHSCORE; 
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
