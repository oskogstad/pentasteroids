module app;

import orb;
import primaryGFX;
import player;
import game;
import star;
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
bool gameInProgress = false;
bool running = true;


void main()
{
    if (!initSDL()) return;
    scope(exit)
    {
        cleanupSDL();
    }

    SDL_DisplayMode current;
    SDL_GetCurrentDisplayMode(0, &current);
    
    auto window = SDL_CreateWindow("Pentasteroids", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, current.w, current.h, 0);
    assert(window);
    
    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    assert(renderer);
       
    scope(exit)
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
    }

    SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
    
    SDL_ShowCursor(SDL_DISABLE);
    
    Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 4096 );

    // game setup

    // clouds
    auto cloudPath = "img/clouds/cloud01_40.png";
    SDL_Texture *cloud = IMG_LoadTexture(renderer, cloudPath.ptr);
    assert(cloud);
    int cloudWidth, cloudHeight;
    SDL_QueryTexture(cloud, null, null, &cloudWidth, &cloudHeight);
    auto cloudRect = new SDL_Rect();
    cloudRect.w = cloudWidth, cloudRect.h = cloudHeight;
    cloudRect.x = (current.w / 2) - (cloudWidth / 2), cloudRect.y = (current.h / 2) - (cloudHeight / 2);
    // clouds end
    

    // stars
    Star[] stars;
    for(int i = 0; i < 100; i++)
    {
        Star s;
        s.x = uniform(0, current.w);
        s.y = uniform(0, current.h);
        s.pulseSpeed = uniform(1,3);
        s.currentOpacity = cast(ubyte)uniform(20, 200);
        s.rising = uniform(0,2) == 1 ? true : false;

        stars ~= s;
    }
    // stars end

    Menu menu = new Menu(renderer, current);

    // primary fire sfx
    Mix_Chunk*[] orbHitSFX;
    Mix_Chunk*[] primaryFireSFX;

    foreach(path; dirEntries("sfx/orbHitScale/", SpanMode.depth))
    {
        orbHitSFX ~= Mix_LoadWAV(path.toStringz());
    }

    foreach(a; orbHitSFX){assert(a);}

    foreach(path; dirEntries("sfx/primaryScale/", SpanMode.depth))
    {
        primaryFireSFX ~= Mix_LoadWAV(path.toStringz());
    }

    foreach(a; primaryFireSFX){assert(a);}
    
    bool sequencePlaying = false;
    int sequenceIndex = 0;


    const float TO_DEG = 180/PI;
    const float TO_RAD = PI/180;

    //primaryWep bullet array
    PrimaryGFX[] bullets;

    // player start
    auto spaceShipPath = "img/spaceship.png";
    
    int spaceShipHeight, spaceShipWidth;

    auto spaceShip = IMG_LoadTexture(renderer, spaceShipPath.ptr);
    assert(spaceShip);

    SDL_QueryTexture(spaceShip, null, null, &spaceShipWidth, &spaceShipHeight);

    auto spaceShipRect = new SDL_Rect();
    spaceShipRect.w = spaceShipWidth, spaceShipRect.h = spaceShipHeight;
    spaceShipRect.x = (current.w / 2) - (spaceShipRect.w / 2);
    spaceShipRect.y = (current.h / 2) - (spaceShipRect.h / 2);

    // shrink /2 for offset when drawing in main loop
    spaceShipWidth /= 2; spaceShipHeight /= 2;

    int moveLength = 10;
    float thrustX = 0;    
    float thrustY = 0;
    float thrustDecay = 0.015;
    float thrustGain = 0.08;

    // player center pos
    int spaceShipX, spaceShipY;
    // player end
   
    // primary weapon start
    auto primaryWeaponPath = "img/single_green_beam.png";
    auto primaryWeapon = IMG_LoadTexture(renderer, primaryWeaponPath.ptr);
    int primaryWeaponHeight, primaryWeaponWidth;
    SDL_QueryTexture(primaryWeapon, null, null, &primaryWeaponWidth, &primaryWeaponHeight);
    assert(primaryWeapon);
    auto primaryWeaponRect = new SDL_Rect();
    int bulletMoveLength = 2 * moveLength;
    float fireCooldown = -1;

    // shrink prob
    primaryWeaponRect.w = primaryWeaponWidth, primaryWeaponRect.h = primaryWeaponHeight;
    
    // set start pos relative to spaceship
    int lWepXOffset = 4, lWepYOffset = 14, rWepXOffset = 4, rWepYOffset = 136;
    primaryWeaponRect.x = spaceShipRect.x; primaryWeaponRect.y = spaceShipRect.y;
    bool primaryFire, leftFire;

    // primary weapon end
   

    // aim cursor start
    int mouseX, mouseY;
    auto crossHairPath = "img/crosshair.png";
    int crossHairHeight, crossHairWidth;
    auto crossHair = IMG_LoadTexture(renderer, crossHairPath.ptr);
    assert(crossHair);
    SDL_QueryTexture(crossHair, null, null, &crossHairWidth, &crossHairHeight);
    auto crossHairRect = new SDL_Rect();
    
    //shrink /5
    crossHairWidth /= 5; crossHairHeight /= 5;
    crossHairRect.w = (crossHairWidth), crossHairRect.h = (crossHairHeight);
    
    // further /2 for offset when drawing in main loop
    crossHairWidth /= 2; crossHairHeight /= 2;
    
    // aim cursor end

    // orbs

    auto orbRect = new SDL_Rect();
    orbRect.w = 128; orbRect.h = 128;
    SDL_Texture*[] orbTextures;
    foreach(path; dirEntries("img/orbs/", SpanMode.depth))
    {
        orbTextures ~= IMG_LoadTexture(renderer, path.toStringz());
    }
    foreach(texture; orbTextures){assert(texture);}

    auto orbTimerDecay = .03;
    auto orbSpawnTimer = 2.1;
    Orb[] activeOrbs;
    // orbs end

    int worldWidth = 3, worldHeight = 3;
    ubyte currentRed = 0, currentGreen = 67 , currentBlue = 67;


    // world grid ------------------------------------------------------------------------ "cant be read at compile time"
    WorldCell[3][3] worldGrid;
    for(int i = 0; i < worldHeight; ++i)
    {
        for(int j = 0; j < worldWidth; ++j)
        {
            // random bgColor for now --------------------------------------------------------------------------------------
            WorldCell wc;
            wc.red = cast(ubyte) uniform(20, 90);
            wc.green = cast(ubyte) uniform(20, 90);
            wc.blue = cast(ubyte) uniform(20, 90);
            worldGrid[i][j] = wc;
        }
    }

    int cellIndexX = 1;
    int cellIndexY = 1;
    WorldCell currentCell = worldGrid[cellIndexX][cellIndexY];
    // world grid end
    
    // set this to true with key K, cloud BG will spinn with angle-var
    bool angleMode = false;

    SDL_Event event;
    auto before = SDL_GetTicks();

    immutable int FRAME_TIME = cast(uint)(1e3 / 60); // 60 FPS
    immutable float FRAME_TIME_SEC = FRAME_TIME / 1e3f;
    double angle;
    while(running)
    {
        while(SDL_PollEvent(&event))
        {
           switch(event.type)
           {
                case SDL_QUIT:
                    running = false;
                    break;

                case SDL_KEYUP:
                    if(state == AppState.MENU) 
                    {
                        menu.handleInput(event);
                    }
                    else
                    {
                        switch(event.key.keysym.sym)
                        {
                            case SDLK_ESCAPE:
                                state = AppState.MENU;
                                menu.selectedIndex = MenuItem.START; 
                                break;

                            case SDLK_k:
                                angleMode = !angleMode;
                                break;

                            default:
                                break;           
                        }
                  
                    }
                    break;

                default: 
                    break;
           }
        }
        
        before = SDL_GetTicks();

        // bg color
        // create targetBGColor, add change on teleport ---------------------------------------------------------------------------
        // if(newTargetColor) {calc diff to target and find slowest way / 2 perhaps?}
        // SDL_SetRenderDrawColor(renderer, 0x00, 0x43, 0x43, 0xFF); // want this one maybe ------------------------------------------------------------------
        // SDL_SetRenderDrawColor(renderer, 0x00, 0x73, 0xA3, 0xFF); // sky blue mby
        // no greens prob

        currentCell = worldGrid[cellIndexX][cellIndexY];

        if(currentRed != currentCell.red)
        {
            // handle red
            if(currentRed < currentCell.red)
            {
                currentRed++;
            }
            else
            {
                currentRed--;
            }
        }
        if(currentGreen != currentCell.green)
        {
            // handle green
            if(currentGreen < currentCell.green)
            {
                currentGreen++;
            }
            else
            {
                currentGreen--;
            }
        }
        if(currentBlue != currentCell.blue)
        {
            // handle blue
            if(currentBlue < currentCell.blue)
            {
                currentBlue++;
            }
            else
            {
                currentBlue--;
            }
        }

        SDL_SetRenderDrawColor(renderer, currentRed, currentGreen, currentBlue, 0xFF);
        SDL_RenderClear(renderer);
            
        switch(state)
        {
            case AppState.MENU:
            {
                menu.updateAndDraw(renderer);      
                break;
            }

            case AppState.HIGHSCORE:
                break;

            case AppState.CREDITS:
                break;

            case AppState.GAME:
            {
                // draw stars
                SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_ADD);
                foreach(ref star; stars)
                {
                    SDL_SetRenderDrawColor(renderer, 0xEE, 0xEE, 0xEE, star.currentOpacity);
                    SDL_RenderDrawPoint(renderer, star.x, star.y);
                    SDL_RenderDrawPoint(renderer, star.x, star.y - 1);
                    SDL_RenderDrawPoint(renderer, star.x - 1, star.y);
                    SDL_RenderDrawPoint(renderer, star.x + 1, star.y);
                    SDL_RenderDrawPoint(renderer, star.x, star.y + 1);
                    
                    // something is bugged out here ------------------------------------------------------------------------------------------------------------
                    if(star.rising)
                    {
                        star.currentOpacity += star.pulseSpeed;
                        if(star.currentOpacity >= 0xFF)
                        {
                            star.rising = false;
                            star.currentOpacity = 0xFF;
                        }
                    }
                    else
                    {
                        star.currentOpacity -= star.pulseSpeed;
                        if(star.currentOpacity <= 0x01)
                        {
                            star.rising = true;
                            star.currentOpacity = 0x21;
                        }
                    }
                }

                // draw clouds
                // --------------------------------------------------------- toggle angleMode on teleport, also change background patterns?
                if(angleMode)
                {
                    SDL_RenderCopyEx(renderer, cloud, null, cloudRect, -angle, null, 0);
                }
                else
                {
                    cloudRect.x = cast(int)(spaceShipRect.x * 0.04) - 400; cloudRect.y = cast(int) (spaceShipRect.y * 0.04) - 300;
                    SDL_RenderCopy(renderer, cloud, null, cloudRect);
                }

                // move player
                auto keyBoardState = SDL_GetKeyboardState(null);

                // up or w AND down or s, should result in decay/stopping. Prevent going steady half speed
                if((keyBoardState[SDL_SCANCODE_UP] || keyBoardState[SDL_SCANCODE_W]) && (keyBoardState[SDL_SCANCODE_DOWN] || keyBoardState[SDL_SCANCODE_S]))
                {
                    // make a function for this
                    if(abs(thrustY) < thrustDecay)
                    {
                        thrustY = 0;
                    }
                    else if(thrustY > 0)
                    {
                        thrustY -= thrustDecay;
                    }
                    else 
                    {
                        thrustY += thrustDecay;
                    }
                }

                else if((keyBoardState[SDL_SCANCODE_UP] || keyBoardState[SDL_SCANCODE_W]))
                {
                    // cap if it goes under -1
                    if((thrustY -= thrustGain) < -1) thrustY = -1;
                }
                else if((keyBoardState[SDL_SCANCODE_DOWN] || keyBoardState[SDL_SCANCODE_S]))
                {
                    // cap if it goes over 1
                    if((thrustY += thrustGain) > 1) thrustY= 1;
                }
                else
                {
                    // make a function for this
                    if(abs(thrustY) < thrustDecay)
                    {
                        thrustY = 0;
                    }
                    else if(thrustY > 0)
                    {
                        thrustY -= thrustDecay;
                    }
                    else 
                    {
                        thrustY += thrustDecay;
                    } 
                }

                //  left or a AND right or d, should result in decay/stopping. Prevent going steady half speed
                if((keyBoardState[SDL_SCANCODE_LEFT] || keyBoardState[SDL_SCANCODE_A]) && (keyBoardState[SDL_SCANCODE_RIGHT] || keyBoardState[SDL_SCANCODE_D]))
                {
                    if(abs(thrustX) < thrustDecay)
                    {
                        thrustX = 0;
                    }
                    else if(thrustX > 0)
                    {
                        thrustX -= thrustDecay;
                    }
                    else 
                    {
                        thrustX += thrustDecay;
                    }
                }

                else if((keyBoardState[SDL_SCANCODE_LEFT] || keyBoardState[SDL_SCANCODE_A]))
                {
                    // cap if it goes under -1
                    if((thrustX -= thrustGain) < -1) thrustX = -1;
                }
                else if((keyBoardState[SDL_SCANCODE_RIGHT] || keyBoardState[SDL_SCANCODE_D]))
                {
                    // cap if it goes over 1
                    if((thrustX += thrustGain) > 1) thrustX= 1;
                }
                else
                {
                    if(abs(thrustX) < thrustDecay)
                    {
                        thrustX = 0;
                    }
                    else if(thrustX > 0)
                    {
                        thrustX -= thrustDecay;
                    }
                    else 
                    {
                        thrustX += thrustDecay;
                    }
                }

                // move movelength * thrust
                spaceShipRect.y += cast(int) ceil(thrustY * moveLength);
                spaceShipRect.x += cast(int) ceil(thrustX * moveLength);

                // player center pos
                spaceShipX = (spaceShipRect.x + (spaceShipWidth));
                spaceShipY = (spaceShipRect.y + (spaceShipHeight));

                // teleport edge detect!
                if(spaceShipY < 0)
                {
                    // teleport to current.h + difference
                    spaceShipRect.y = (current.h + spaceShipRect.y);
                    cellIndexY = abs(++cellIndexY % worldHeight);
                }
                else if(spaceShipY > current.h)
                {
                    // teleport to 0 + difference
                    spaceShipRect.y = 0 + (spaceShipRect.y - current.h);
                    cellIndexY = abs(--cellIndexY % worldHeight);
                }

                if(spaceShipX < 0)
                {
                    // teleport to current.w + difference
                    spaceShipRect.x = (current.w + spaceShipRect.x);
                    cellIndexX = abs(--cellIndexX % worldWidth);

                }
                else if(spaceShipX > current.w)
                {
                    // teleport to current.w + difference
                    spaceShipRect.x = 0 + (spaceShipRect.x - current.w);
                    cellIndexX = abs(++cellIndexX % worldWidth);

                }

                auto mouseState = SDL_GetMouseState(&mouseX, &mouseY);
                crossHairRect.y = mouseY - crossHairHeight, crossHairRect.x = mouseX - crossHairWidth;
                if (mouseState & SDL_BUTTON(SDL_BUTTON_LEFT)) 
                {
                    primaryFire = true;
                }
                else 
                {
                    primaryFire = false;
                    sequencePlaying = false;
                    //fireCooldown = 0.5;
                }
                if (mouseState & SDL_BUTTON(SDL_BUTTON_RIGHT)) {writeln("RIGHT FIRE");}
                if (mouseState & SDL_BUTTON(SDL_BUTTON_MIDDLE)) {writeln("MID FIRE");}

                // rotation angle, spaceship look toward mouse
                // or towards middle if angleMode
                if(angleMode)
                {
                    angle = atan2(cast(float)(current.h/2) - spaceShipY, cast(float)(current.w/2) - spaceShipX);
                }
                else
                {
                    angle = atan2(cast(float) mouseY - spaceShipY, cast(float) mouseX - spaceShipX);
                }
                
                
                // lasers, offset, all to go in if(fire), sets angle and animation
                float s = sin(angle);
                float c = cos(angle);
                int newLWepXOffset = cast(int) ceil((lWepXOffset * c) - (lWepYOffset * s));
                int newLWepYOffset = cast(int) ceil((lWepXOffset * s) + (lWepYOffset * c));
                int newRWepXOffset = cast(int) ceil((rWepXOffset * c) - (rWepYOffset * s));
                int newRWepYOffset = cast(int) ceil((rWepXOffset * s) + (rWepYOffset * c));
                angle = angle * TO_DEG;
                angle += 90f;
                primaryWeaponRect.x = spaceShipRect.x + newLWepXOffset;
                primaryWeaponRect.y = spaceShipRect.y + newLWepYOffset;
                SDL_Point wepRotPoint = { (spaceShipRect.w/2), (spaceShipRect.h/2) };

                // Render stuff to screen
                SDL_RenderCopyEx(renderer, spaceShip, null, spaceShipRect, angle, null, 0);
                // move and draw player done


                // create/draw lasers
                if(primaryFire)
                {
                    if(fireCooldown > 0) 
                    {
                        fireCooldown -= 0.1;
                    } 
                    else 
                    {
                        // play random scale 
                        if(sequencePlaying)
                        {
                            // somethingsomething rythm ... or perhaps change array to muted sounds now and then
                            // also maybe semi force melody -------------------------------------------------------------------------------------------
                            // and mix this down in volume, along with orb hit. And add subtle shoot sound to primarywep
                            //if((uniform(1,1001) % 3) != 0)
                            {
                                if(++sequenceIndex == primaryFireSFX.length) sequenceIndex = 0;
                                Mix_PlayChannel(-1, primaryFireSFX[sequenceIndex], 0);
                            }
                            
                        }
                        else
                        {
                            sequenceIndex = 0;
                            partialShuffle(primaryFireSFX, 3);
                            Mix_PlayChannel(-1, primaryFireSFX[sequenceIndex], 0);
                            sequencePlaying = true;
                        }

                        // left wep
                        //SDL_RenderCopyEx(renderer, primaryWeapon, null, primaryWeaponRect, angle, &wepRotPoint, 0);
                        PrimaryGFX left;
                        left.x = primaryWeaponRect.x, left.y = primaryWeaponRect.y;
                        left.angle = angle - 90;
                        left.dx = cast(int) (bulletMoveLength * cos(left.angle * TO_RAD));
                        left.dy = cast(int) (bulletMoveLength * sin(left.angle * TO_RAD));
                        bullets ~= left;

                        // right wep
                        primaryWeaponRect.x = spaceShipRect.x + newRWepXOffset;
                        primaryWeaponRect.y = spaceShipRect.y + newRWepYOffset;
                        //SDL_RenderCopyEx(renderer, primaryWeapon, null, primaryWeaponRect, angle, &wepRotPoint, 0);  
                        PrimaryGFX right;
                        right.x = primaryWeaponRect.x, right.y = primaryWeaponRect.y;
                        right.angle = angle - 90;
                        right.dx = cast(int) (bulletMoveLength * cos(right.angle * TO_RAD));
                        right.dy = cast(int) (bulletMoveLength * sin(right.angle * TO_RAD));
                        bullets ~= right;

                        fireCooldown = 2.1; 
                    }
                }

                // move and draw bullets array
                foreach(ref bullet; bullets)
                {
                    bullet.x += bullet.dx;
                    bullet.y += bullet.dy;

                    // edge detect and destroy
                    if((bullet.x < -50) || (bullet.x > (current.w + 50)) || (bullet.y < - 50) || (bullet.y > (current.h + 50)))
                    {
                        bullet.del = true;
                    }

                    primaryWeaponRect.x = bullet.x;
                    primaryWeaponRect.y = bullet.y;
                    SDL_RenderDrawPoint(renderer, bullet.x + bullet.dx, bullet.y + bullet.dy);
                    SDL_RenderCopyEx(renderer, primaryWeapon, null, primaryWeaponRect, bullet.angle + 90, &wepRotPoint, 0);
                }

                // crash check wif orbs
                foreach(ref bullet; bullets)
                {
                    foreach(ref orb; activeOrbs)
                    {
                        float dist = distanceSquared(orb.x, orb.y, bullet.x, bullet.y);
                        if(dist < orb.radius * orb.radius)
                        {
                            if(--orb.hitPoints == 0) orb.del = true;
                            orb.isShaking = true;
                            Mix_PlayChannel(-1, orbHitSFX[uniform(0, orbHitSFX.length - 1)], 0);
                            bullet.del = true;
                        }
                    }
                }

                bullets = remove!(bullet => bullet.del)(bullets);
                activeOrbs = remove!(orb => orb.del)(activeOrbs);
                
                // orbs
                // spawn new
                if(orbSpawnTimer < 0)
                {
                    Orb o;
                    o.x = uniform(0, current.w);
                    o.hitPoints = 3;
                    o.hitSFXindex = 4;
                    o.shakeTimer = 6;
                    o.y = uniform(0, current.h);
                    o.moveSpeed = uniform(3,6);
                    o.angle = uniform(0,359);
                    o.radius = 128;
                    o.dx = cast(int) (o.moveSpeed * cos(o.angle * TO_RAD));
                    o.dy = cast(int) (o.moveSpeed * sin(o.angle * TO_RAD));
                    int orbIndex = uniform(0, orbTextures.length - 1);
                    o.texture = orbTextures[orbIndex];
                    o.spinningSpeed = uniform(-0.5f, 0.5f);
                    activeOrbs ~= o;
                    orbSpawnTimer = uniform(2,4);
                }

                else
                {
                    orbSpawnTimer -= orbTimerDecay;
                }

                // update and draw orbs
                foreach(ref orb; activeOrbs)
                {
                    orb.x += orb.dx;
                    orb.y += orb.dy;
                    // teleport check / destruction check
                    // teleport edge detect!
                    if(orb.y < 0)
                    {
                        // teleport to current.h + difference
                        orb.y = (current.h + orb.y);
                    }
                    else if(orb.y > current.h)
                    {
                        // teleport to 0 + difference
                        orb.y = 0 + (orb.y - current.h);
                    }

                    if(orb.x < 0)
                    {
                        // teleport to current.w + difference
                        orb.x = (current.w + orb.x);
                    }
                    else if(orb.x > current.w)
                    {
                        // teleport to current.w + difference
                        orb.x = 0 + (orb.x - current.w);
                    }

                    orb.angle += orb.spinningSpeed;

                    if(orb.isShaking)
                    {
                        orbRect.x = orb.x - 64 + uniform(-7, 7);
                        orbRect.y = orb.y - 64 + uniform(-7, 7);
                        orb.shakeTimer -= 0.1;
                        if(orb.shakeTimer < 0)
                        {
                            orb.isShaking = false;
                            orb.shakeTimer = 4;
                        }
                    }
                    else
                    {
                        orbRect.x = orb.x - 64;
                        orbRect.y = orb.y - 64;                    
                    }

                    SDL_RenderCopyEx(renderer, orb.texture, null, orbRect, orb.angle, null, 0);
                }
                
                // draw mousecursor, or not
                if(!angleMode)
                {
                    SDL_RenderCopy(renderer, crossHair, null, crossHairRect);
                }
                
                //SDL_RenderPresent(renderer); 
                break;
            }

            default:
                break;
        }
 
        SDL_RenderPresent(renderer); 

        int sleepTime = FRAME_TIME - (SDL_GetTicks() - before);
        if (sleepTime > 0) SDL_Delay(sleepTime);
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

    return true;
}

void cleanupSDL()
{
    writeln("Cleaning up..");
    Mix_CloseAudio();
    IMG_Quit();
    SDL_Quit();
}