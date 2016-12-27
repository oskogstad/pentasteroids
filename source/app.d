module app;

import game;
import world;
import menu;

public import std.string;
public import std.stdio;
public import std.conv;
public import std.math;
public import std.algorithm;
public import std.random;
public import std.datetime;
public import std.file;

public import derelict.sdl2.sdl;
public import derelict.sdl2.image;
public import derelict.sdl2.mixer;

enum AppState
{
    MENU,
    HIGHSCORE,
    CREDITS,
    GAME
}

int state = AppState.MENU;
bool running = true;
SDL_DisplayMode currentDisplay;

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
    
    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    assert(renderer);

    scope(exit)
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
    }

    auto icon = SDL_LoadBMP("img/icon.bmp");
    assert(icon);

    SDL_SetWindowIcon(window, icon);

    SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
    
    SDL_ShowCursor(SDL_DISABLE);
    
    Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 4096 );

    menu.setup(renderer);
    game.setup(renderer);

    SDL_Event event;
    auto before = SDL_GetTicks();

    immutable int FRAME_TIME = cast(uint)(1e3 / 60); // 60 FPS
    immutable float FRAME_TIME_SEC = FRAME_TIME / 1e3f;
    
    while(running)
    {
        while(SDL_PollEvent(&event))
        {
            switch(event.type)
            {
                case SDL_QUIT:
                {
                    running = false;
                    break;
                }

                case SDL_KEYUP:
                {
                    if(state == AppState.MENU)
                    {
                        menu.handleInput(event);
                    }
                    else
                    {
                        game.handleInput(event);
                    }  
                    break;
                }

                default: 
                {
                    break;

                }
            }
        }

        before = SDL_GetTicks();

        world.updateAndDraw(renderer);

        switch(state)
        {
            case AppState.MENU:
            {
                menu.updateAndDraw(renderer);      
                break;
            }

            case AppState.HIGHSCORE:
            {
                break;
            }

            case AppState.CREDITS:
            {
                break;
            }

            case AppState.GAME:
            {
                game.updateAndDraw(renderer);
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

        int sleepTime = FRAME_TIME - (SDL_GetTicks() - before);
        if (sleepTime > 0) SDL_Delay(sleepTime);
    }
}

void loadGFXFromDisk(string folderPath, SDL_Renderer* renderer, ref SDL_Texture*[] tArray)
{
    foreach(filePath; dirEntries(folderPath, SpanMode.depth))
    {
        tArray ~= IMG_LoadTexture(renderer, filePath.toStringz());
    }
}

void loadSFXFromDisk(string folderPath, SDL_Renderer* renderer, ref Mix_Chunk*[] mArray)
{
    foreach(filePath; dirEntries(folderPath, SpanMode.depth))
    {
        mArray ~= Mix_LoadWAV(filePath.toStringz());
    }
}

bool initSDL()
{
    writeln("Initializing SDL...");

    DerelictSDL2.load();
    if (SDL_Init(SDL_INIT_EVERYTHING))
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL!\n\t", SDL_GetError().fromStringz());
        return false;
    }

    writeln("Initializing SDL image...");

    DerelictSDL2Image.load();
    if ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) != IMG_INIT_PNG)
    {
        writeln("PANIC");
        writeln("Failed to initialize SDL image!\n\t", IMG_GetError().fromStringz());
        return false;
    }

    DerelictSDL2Mixer.load();
    // ----------------------------------------------------------------------------------- add test stuff here
    return true;
}

void cleanupSDL()
{
    writeln("Cleaning up..");
    Mix_CloseAudio();
    IMG_Quit();
    SDL_Quit();
}