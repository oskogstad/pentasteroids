import everything;

final class CreditsState : AppState
{
    enum FONT_BY = "font by";
    enum ZAC_FREELAND = "zac freeland";
    enum ZAC_WEBSITE = "http://zacfreeland.com";
    enum OJS = "ole j. skogstad";
    enum CODE_BY = "code, gfx, and sfx by";
    enum PROTOMAGIC = "http://protomagic.no";
    enum HALLGEIR = "hallgeir loekken";
    enum CREDITS = "credits";
    enum GO_BACK = "press esc to go back";

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

    override void setup()
    {
        int spacer = 220;
        int smallSpacer = 180;

        // header
        utils.createTexture(renderer, creditsRect.w, creditsRect.h, CREDITS,
                app.fontLarge, &creditsT, score.color);
        assert(creditsT);

        creditsRect.x = app.middleX - creditsRect.w/2;
        creditsRect.y = 50;

        // code by
        utils.createTexture(renderer, codeByRect.w, codeByRect.h, CODE_BY,
                app.fontMedium, &codeBy, score.color);
        assert(codeBy);

        codeByRect.x = app.middleX - codeByRect.w/2;
        codeByRect.y = creditsRect.y + spacer; // the last one + spacer

        // ole j skogstad
        utils.createTexture(renderer, ojsRect.w, ojsRect.h, OJS,
                app.fontMedium, &ojs, score.color);
        assert(ojs);

        ojsRect.x = app.middleX - ojsRect.w/2;
        ojsRect.y = codeByRect.y + smallSpacer; // the last one + spacer

        // hallgeir loekken
        utils.createTexture(renderer, hallgeirRect.w, hallgeirRect.h, HALLGEIR,
                app.fontMedium, &hallgeir, score.color);
        assert(hallgeir);

        hallgeirRect.x = app.middleX - hallgeirRect.w/2;
        hallgeirRect.y = ojsRect.y + smallSpacer; // the last one + spacer

        // protomagic.no
        utils.createTexture(renderer, protomagicRect.w, protomagicRect.h, PROTOMAGIC,
                app.fontSmall, &protomagic, score.color);
        assert(protomagic);

        protomagicRect.x = app.middleX - protomagicRect.w/2;
        protomagicRect.y = hallgeirRect.y + smallSpacer; // the last one + spacer

        // font by
        utils.createTexture(renderer, fontByRect.w, fontByRect.h, FONT_BY,
                app.fontMedium, &fontBy, score.color);
        assert(fontBy);

        fontByRect.x = app.middleX - fontByRect.w/2;
        fontByRect.y = protomagicRect.y + spacer; // the last one + spacer

        // zac freeland
        utils.createTexture(renderer, freelandRect.w, freelandRect.h, ZAC_FREELAND,
                app.fontMedium, &freeland, score.color);
        assert(freeland);

        freelandRect.x = app.middleX - freelandRect.w/2;
        freelandRect.y = fontByRect.y + smallSpacer; // the last one + spacer

        // freeland www
        utils.createTexture(renderer, freeLandWWWRect.w, freeLandWWWRect.h, ZAC_WEBSITE,
                app.fontSmall, &freeLandWWW, score.color);
        assert(freeLandWWW);

        freeLandWWWRect.x = app.middleX - freeLandWWWRect.w/2;
        freeLandWWWRect.y = freelandRect.y + smallSpacer; // the last one + spacer

        // go back
        utils.createTexture(renderer, goBackRect.w, goBackRect.h, GO_BACK,
                app.fontSmall, &goBack, score.color);
        assert(goBack);

        goBackRect.x = app.middleX - goBackRect.w/2;
        goBackRect.y = display_height - ((goBackRect.h + 30)); // the last one + spacer

    }

    override void updateAndDraw()
    {
        SDL_RenderCopy(renderer, creditsT, null, &creditsRect);
        SDL_RenderCopy(renderer, codeBy, null, &codeByRect);
        SDL_RenderCopy(renderer, ojs, null, &ojsRect);
        SDL_RenderCopy(renderer, hallgeir, null, &hallgeirRect);
        SDL_RenderCopy(renderer, protomagic, null, &protomagicRect);
        SDL_RenderCopy(renderer, fontBy, null, &fontByRect);
        SDL_RenderCopy(renderer, freeland, null, &freelandRect);
        SDL_RenderCopy(renderer, freeLandWWW, null, &freeLandWWWRect);
        SDL_RenderCopy(renderer, goBack, null, &goBackRect);
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

