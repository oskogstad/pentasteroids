import app;

struct MenuTexture
{
	SDL_Texture* texture;
	SDL_Rect* rect;
	string text;
}

const string[7] itemText =
[
	"new highscore!",
	"enter initials",
	"-",
	"-",
	"-",
	"press enter to confirm",
	"or press escape to not be on the list all like :(",
];

int letterCount;
string initials;

void setup()
{
	foreach(text; itemText)
	{
		MenuTexture mt;
		mt.rect = new SDL_Rect();
		mt.text = text;
		if(mt.text == "new highscore!" || mt.text == "-")
		{
			app.createTexture(renderer, mt.rect.w, mt.rect.h, text,
				app.fontLarge, &mt.texture, score.color);
		}
		else if(mt.text == "enter initials" || mt.text == "press enter to confirm")
		{
			app.createTexture(renderer, mt.rect.w, mt.rect.h, text,
				app.fontMedium, &mt.texture, score.color);
		}
		else
		{
			app.createTexture(renderer, mt.rect.w, mt.rect.h, text,
				app.fontSmall, &mt.texture, score.color);
		}
	}
}
		

void updateAndDraw()
{

}

void handleInput(SDL_Event event)
{
	switch(event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
		{
			app.state = AppState.MENU;
			menu.selectedIndex = MenuItem.HIGHSCORE; 
			break;			
		}


		default:
			break;
	}
}