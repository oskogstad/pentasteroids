import everything;

final class GameState : AppState
{
    double angle;
    bool angleMode = false;
    bool gameInProgress = false;

    enum TO_DEG = 180/PI;
    enum TO_RAD = PI/180;

    override void setup()
    {
        gameover.setup();
        world.setup();
        orbs.setup();
        player.setup();
        primaryfire.setup();
        secondaryfire.setup();
        sparks.setup();
        score.setup();
    }

    override void updateAndDraw()
    {
        if(angleMode)
        {
            angle = atan2(
                cast(float)(app.middleY) - player.yPos,
                cast(float)(app.middleX) - player.xPos
                );
        }
        else
        {
            angle = atan2(
                cast(float) mouseY - player.yPos,
                cast(float) mouseX - player.xPos
                );
        }
        
        primaryfire.updateAndDraw();
        orbs.updateAndDraw();
        secondaryfire.updateAndDraw();
        ringblasts.updateAndDraw();
        sparks.updateAndDraw();

        if(!player.dead)
        {
            score.updateAndDraw();
            player.updateAndDraw();
        }
        else
        {
            gameover.updateAndDraw();
        }
    }

    void resetGame()
    {
        gotoAppState(menuState);
        gameInProgress = false;
        player.dead = false;
        player.damageTaken = 0;
        orbs.activeOrbs.length = 0;
        orbs.resetTimers();
        ringblasts.activeBlasts.length = 0;
        primaryfire.bullets.length = 0;
        gameover.continueAlpha = 0;
        gameover.fadeScreenAlpha = 0;
        gameover.playedSFX = false;
        score.currentScore = 0;
        primaryfire.primaryFire = false;
        primaryfire.sequencePlaying = false;
    }

    override void handleInput(ref SDL_Event event)
    {
        if(player.dead)
        {
            if(!(gameover.continueAlpha == 250)) return;
            resetGame();
            return;
        }

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

                case SDLK_k:
                {
                    angleMode = !angleMode;
                    break;
                }
                
                debug case SDLK_o:
                {
                    // orbs.orbSpawnTimer = -1;
                    break;	
                }

                case SDLK_c:
                {
                    orbs.activeOrbs.length = 0;
                    break;	
                }

                default:
                break;           
            }
        }
        else if(event.type == SDL_MOUSEWHEEL)
        {
            primaryfire.angleOffset += 0.05;
            if(primaryfire.angleOffset > 1.3)
            {
                primaryfire.angleOffset = 0.05;
            }
        }
        else if(event.type == SDL_MOUSEBUTTONDOWN)
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
                if(secondaryFire)
                {
                    secondaryFire = false;
                }
                else
                {
                    // Only allow activating secondaryFire if fuel is full.
                    if(secondaryfire.fuel >= secondaryfire.maxFuel)
                    {
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
    }
}

