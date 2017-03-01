import everything;

enum AppState
{
    MENU,
    HIGHSCORE,
    CREDITS,
    GAME,
    ENTER_NAME
}

const int FPS = 60;
int state = AppState.MENU;
bool running = true;
bool windowVisible = false;

SDL_DisplayMode currentDisplay;
SDL_Renderer* renderer;
uint ticks;
TTF_Font* fontSmall, fontMedium, fontLarge, fontYuge;
const string fontPath = "font/Cornerstone.ttf";
int middleX, middleY;
float xScale, yScale;

void main()
{
    if (!initSDL()) return;
    scope(exit)
    {
        cleanupSDL();
    }

    SDL_GetCurrentDisplayMode(0, &currentDisplay);
    
    auto window = SDL_CreateWindow(
        "Pentasteroids", 
        SDL_WINDOWPOS_CENTERED, 
        SDL_WINDOWPOS_CENTERED, 
        currentDisplay.w, 
        currentDisplay.h, 
        0);

    assert(window);
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    assert(renderer);

    scope(exit)
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
    }
    
    middleX = currentDisplay.w/2;
    middleY = currentDisplay.h/2;
    
    yScale = app.currentDisplay.h / 1080f;
    xScale = app.currentDisplay.w / 1920f;
    
    fontMedium = TTF_OpenFont(fontPath.toStringz(), 70);
    assert(fontMedium);

    fontLarge = TTF_OpenFont(fontPath.toStringz(), 100);
    assert(fontLarge);

    fontSmall = TTF_OpenFont(fontPath.toStringz(), 40);
    assert(fontSmall);

    version(Windows)
    {
        auto icon = SDL_LoadBMP("img/icon.bmp");
        assert(icon);
        SDL_SetWindowIcon(window, icon);
    }

    SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1");
    SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
    
    SDL_ShowCursor(SDL_DISABLE);
    
    
    menu.setup();
    game.setup();
    highscore.setup();
    entername.setup();

    soundsystem.setup();

    SDL_Event event;
    ticks = SDL_GetTicks();

    immutable int FRAME_TIME = cast(uint)(1e3 / FPS);
    immutable float FRAME_TIME_SEC = FRAME_TIME / 1e3f;
    
    while(running)
    {
        while(SDL_PollEvent(&event))
        {
            switch(event.type)
            {
                case SDL_WINDOWEVENT:
                {
                    if(event.window.event == SDL_WINDOWEVENT_FOCUS_GAINED)
                    {
                        windowVisible = true;
                        writeln("visible");
                    }
                    else if(event.window.event == SDL_WINDOWEVENT_FOCUS_LOST)
                    {
                        windowVisible = false;
                        writeln("invisible");
                    }
                    break;
                }                     


                case SDL_QUIT:
                {
                    running = false;
                    break;
                }

                case SDL_MOUSEBUTTONDOWN:
                {
                    if(state == AppState.GAME)
                    {
                        if(event.button.button == SDL_BUTTON_LEFT)
                        {
                            primaryfire.primaryFire = !primaryfire.primaryFire;
                            if(!primaryfire.primaryFire)
                            {
                                primaryfire.fireCooldown = 0;
                                primaryfire.sequencePlaying = false;
                            } 
                        }
                        
                        else if(event.button.button == SDL_BUTTON_MIDDLE)
                        {
                            if(secondaryFire) {
                                secondaryFire = false;
                            }
                            else {
                                // Only allow activating secondaryFire if fuel is full.
                                if(secondaryfire.fuel >= secondaryfire.maxFuel) {
                                    secondaryFire = true;
                                }
                            }
                            //secondaryfire.secondaryFire = !secondaryfire.secondaryFire;
                        }

                        else if(event.button.button == SDL_BUTTON_RIGHT)
                        {
                            tertiaryfire.detonate();
                        }

                    }
                    break;
                }

                case SDL_KEYUP:
                {
                    if(event.key.keysym.sym == SDLK_1)
                    {
                        screenshot();
                        break;
                    }

                    switch(state) with (AppState)
                    {
                        case MENU:
                        {
                            menu.handleInput(event);
                            break;
                        }

                        case GAME:
                        {
                            game.handleInput(event);
                            break;
                        }

                        case HIGHSCORE:
                        {
                            highscore.handleInput(event);
                            break;
                        }

                        case CREDITS:
                        {
                            credits.handleInput(event);
                            break;
                        }
                        
                        case ENTER_NAME:
                        {
                            entername.handleInput(event);
                            break;
                        }

                        default:
                        break;
                    }
                    break;
                }

                case SDL_MOUSEWHEEL:
                {
                    primaryfire.angleOffset += 0.05;
                    if(primaryfire.angleOffset > 1.3) primaryfire.angleOffset = 0.05;
                    break;
                }
                
                default: 
                {
                    break;

                }
            }
        }

        ticks = SDL_GetTicks();

        world.updateAndDraw();

        switch(state) with (AppState)
        {
            case MENU:
            {
                menu.updateAndDraw();      
                break;
            }

            case HIGHSCORE:
            {
                highscore.updateAndDraw();
                break;
            }

            case CREDITS:
            {
                credits.updateAndDraw();
                break;
            }

            case GAME:
            {
                game.updateAndDraw();
                break;
            }

            case ENTER_NAME:
            {
                entername.updateAndDraw();
                break;
            }

            default:
            {
                writeln("Something bad happened, state switch called default.");
                running = false;
                break;
            }
        }

        SDL_RenderPresent(renderer); 

        int sleepTime = FRAME_TIME - (SDL_GetTicks() - ticks);
        if (sleepTime > 0) SDL_Delay(sleepTime);
    }
}

bool initSDL()
{
    writeln("Initializing SDL ...");

    DerelictSDL2.load();
    if (SDL_Init(SDL_INIT_EVERYTHING))
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL!\n\t", SDL_GetError().fromStringz());
        return false;
    }

    writeln("Initializing SDL image ...");

    DerelictSDL2Image.load();
    if ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) != IMG_INIT_PNG)
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL image!\n\t", IMG_GetError().fromStringz());
        return false;
    }

    writeln("Initializing SDL Mixer ...");
    
    DerelictSDL2Mixer.load();
    if(Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 1024))
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL Mixer!\n\t", Mix_GetError().fromStringz());
        return false;
    }

    writeln("Initializing SDL TTF ...");
    
    DerelictSDL2ttf.load();
    if(TTF_Init())
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL TTF!\n\t", TTF_GetError().fromStringz());
        return false;
    }

    return true;
}

void cleanupSDL()
{
    writeln("Cleaning up..");
    
    TTF_Quit();
    IMG_Quit();
    Mix_CloseAudio();
    SDL_Quit();

    DerelictSDL2ttf.unload();
    DerelictSDL2Image.unload();
    DerelictSDL2Mixer.unload();
    DerelictSDL2.unload();
}
