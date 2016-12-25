module orb;
import app;

struct Orb
{
    SDL_Texture* texture;

    int 
        x, 
        y,
        radius,
        size,
        dx,
        dy,
        moveSpeed,
        hitPoints,
        hitSFXindex;
    
    bool 
        hasBeenOnScreen, 
        del, 
        isShaking;
    
    float 
        angle, 
        spinningSpeed, 
        shakeTimer;
}