import everything;

const string FONT_BY = "font by";
const string ZAC_FREELAND = "zac freeland";
const string ZAC_WEBSITE = "http://zacfreeland.com";
const string OJS = "ole j. skogstad";
const string CODE_BY = "code, gfx, and sfx by";
const string PROTOMAGIC = "http://protomagic.no";
const string HALLGEIR = "hallgeir loekken";
const string CREDITS = "credits";
const string GO_BACK = "press esc to go back";

SDL_Rect 
	creditsRect,
	freelandRect,
	freeLandWWWRect,
	ojsRect,
	hallgeirRect,
	protomagicRect,
	fontByRect,
	codeByRect,
	goBackRect;

SDL_Texture* 
	creditsT,
	fontBy,
	freeland,
	freeLandWWW,
	ojs,
	hallgeir,
	protomagic,
	codeBy,
	goBack;

void setup()
{
	// header
	utils.createTexture(renderer, creditsRect.w, creditsRect.h, CREDITS,
		app.fontLarge, &creditsT, score.color);
	assert(creditsT);

	creditsRect.x = app.middleX - creditsRect.w/2;
	creditsRect.y = cast(int)(50 * yScale);

	// code by
	utils.createTexture(renderer, codeByRect.w, codeByRect.h, CODE_BY,
		app.fontMedium, &codeBy, score.color);
	assert(codeBy);

	codeByRect.x = app.middleX - codeByRect.w/2;

	// ole j skogstad
	utils.createTexture(renderer, ojsRect.w, ojsRect.h, OJS,
		app.fontMedium, &ojs, score.color);
	assert(ojs);

	ojsRect.x = app.middleX - ojsRect.w/2;
	
	// hallgeir loekken
	utils.createTexture(renderer, hallgeirRect.w, hallgeirRect.h, HALLGEIR,
		app.fontMedium, &hallgeir, score.color);
	assert(hallgeir);

	hallgeirRect.x = app.middleX - hallgeirRect.w/2;

	// protomagic.no
	utils.createTexture(renderer, protomagicRect.w, protomagicRect.h, PROTOMAGIC,
		app.fontSmall, &protomagic, score.color);
	assert(protomagic);

	protomagicRect.x = app.middleX - protomagicRect.w/2;

	// font by
	utils.createTexture(renderer, fontByRect.w, fontByRect.h, FONT_BY,
		app.fontMedium, &fontBy, score.color);
	assert(fontBy);

	fontByRect.x = app.middleX - fontByRect.w/2;

	// zac freeland
	utils.createTexture(renderer, freelandRect.w, freelandRect.h, ZAC_FREELAND,
		app.fontMedium, &freeland, score.color);
	assert(freeland);

	freelandRect.x = app.middleX - freelandRect.w/2;

	// freeland www
	utils.createTexture(renderer, freeLandWWWRect.w, freeLandWWWRect.h, ZAC_WEBSITE,
		app.fontSmall, &freeLandWWW, score.color);
	assert(freeLandWWW);

	freeLandWWWRect.x = app.middleX - freeLandWWWRect.w/2;

	// go back 
	utils.createTexture(renderer, goBackRect.w, goBackRect.h, GO_BACK,
		app.fontSmall, &goBack, score.color);
	assert(goBack);

	goBackRect.x = app.middleX - goBackRect.w/2;

}

void updateAndDraw()
{
	creditsRect.h = cast(int) (creditsRect.h * yScale);
	creditsRect.w = cast(int) (creditsRect.w * xScale);
	SDL_RenderCopy(renderer, creditsT, null, &creditsRect);

	int spacer = cast(int) (150 * yScale);
	int smallSpacer = cast(int) (80 * yScale);

	codeByRect.h = cast(int) (codeByRect.h * yScale);
	codeByRect.w = cast(int) (codeByRect.w * xScale);
	codeByRect.y = cast(int) ((creditsRect.y + spacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, codeBy, null, &codeByRect);

	ojsRect.h = cast(int) (ojsRect.h * yScale);
	ojsRect.w = cast(int) (ojsRect.w * xScale);
	ojsRect.y = cast(int) ((codeByRect.y + smallSpacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, ojs, null, &ojsRect);

	hallgeirRect.h = cast(int) (hallgeirRect.h * yScale);
	hallgeirRect.w = cast(int) (hallgeirRect.w * xScale);
	hallgeirRect.y = cast(int) ((ojsRect.y + smallSpacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, hallgeir, null, &hallgeirRect);

	protomagicRect.h = cast(int) (protomagicRect.h * yScale);
	protomagicRect.w = cast(int) (protomagicRect.w * xScale);
	protomagicRect.y = cast(int) ((hallgeirRect.y + smallSpacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, protomagic, null, &protomagicRect);

	fontByRect.h = cast(int) (fontByRect.h * yScale);
	fontByRect.w = cast(int) (fontByRect.w * xScale);
	fontByRect.y = cast(int) ((protomagicRect.y + spacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, fontBy, null, &fontByRect);

	freelandRect.h = cast(int) (freelandRect.h * yScale);
	freelandRect.w = cast(int) (freelandRect.w * xScale);
	freelandRect.y = cast(int) ((fontByRect.y + smallSpacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, freeland, null, &freelandRect);

	freeLandWWWRect.h = cast(int) (freeLandWWWRect.h * yScale);
	freeLandWWWRect.w = cast(int) (freeLandWWWRect.w * xScale);
	freeLandWWWRect.y = cast(int) ((freelandRect.y + smallSpacer) * yScale); // the last one + spacer
	SDL_RenderCopy(renderer, freeLandWWW, null, &freeLandWWWRect);

	goBackRect.h = cast(int) (goBackRect.h * yScale);
	goBackRect.w = cast(int) (goBackRect.w * xScale);
	goBackRect.y = cast(int)(currentDisplay.h - ((goBackRect.h + 30) * yScale)); // the last one + spacer
	SDL_RenderCopy(renderer, goBack, null, &goBackRect);

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