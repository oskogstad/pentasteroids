import everything;

abstract class AppState
{
    void setup() {}                          // Called once at the beginning
    void init() {}                           // Called when the state becomes the current state
    void updateAndDraw() {}                  // Called once every frame when the state is the current
    void handleInput(ref SDL_Event event) {} // Called several times per frame when the state is current
    void finalize() {}                       // Called when the state is no longer current
    void teardown() {}                       // Called once at the end
}

MenuState menuState;
HighscoreState highscoreState;
CreditsState creditsState;
GameState gameState;
EnterNameState enterNameState;

private AppState currentAppState;
void gotoAppState(AppState state)
{
    if(currentAppState) currentAppState.finalize();
    currentAppState = state;
    currentAppState.init();
}

const int FPS = 60;
bool running = true;
bool windowVisible = false;

enum display_width = 1920, display_height = 1080;
SDL_Renderer* renderer;
uint ticks;
TTF_Font* fontSmall, fontMedium, fontLarge, fontYuge;
const string fontPath = "font/Cornerstone.ttf";
int middleX, middleY;

void main()
{
    if (!initSDL()) return;
    scope(exit)
    {
        cleanupSDL();
    }

    SDL_DisplayMode currentDisplay;
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
    
    middleX = display_width/2;
    middleY = display_height/2;
    
    SDL_RenderSetLogicalSize(renderer, display_width, display_height);
    
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

    menuState = new MenuState();
    gameState = new GameState();
    highscoreState = new HighscoreState();
    enterNameState = new EnterNameState();
	creditsState = new CreditsState();
    
    menuState.setup();
    gameState.setup();
    highscoreState.setup();
    enterNameState.setup();
	creditsState.setup();

    soundsystem.setup();

    gotoAppState(menuState);

    ticks = SDL_GetTicks();
    immutable int FRAME_TIME = cast(uint)(1e3 / FPS);
    immutable float FRAME_TIME_SEC = FRAME_TIME / 1e3f;
    
    while(running)
    {
        SDL_Event event;
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

                default:
                {
                    currentAppState.handleInput(event);
                    break;
                }
            }
        }

        ticks = SDL_GetTicks();

        world.updateAndDraw();

        currentAppState.updateAndDraw();

        SDL_RenderPresent(renderer); 

        int sleepTime = FRAME_TIME - (SDL_GetTicks() - ticks);
        if (sleepTime > 0) SDL_Delay(sleepTime);
    }

    menuState.teardown();
    gameState.teardown();
    highscoreState.teardown();
    enterNameState.teardown();
	creditsState.teardown();
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
