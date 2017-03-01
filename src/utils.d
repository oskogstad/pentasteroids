import everything;

void loadGFXFromDisk(string folderPath, SDL_Renderer* renderer, ref SDL_Texture*[] tArray)
{
    foreach(filePath; dirEntries(folderPath, SpanMode.depth))
    {
        tArray ~= IMG_LoadTexture(renderer, filePath.toStringz());
    }
}

void loadSFXFromDisk(string folderPath, ref Mix_Chunk*[] mArray)
{
    foreach(filePath; dirEntries(folderPath, SpanMode.depth))
    {
        mArray ~= Mix_LoadWAV(filePath.toStringz());
    }
}

void screenshot()
{
    SDL_Surface *surf = SDL_CreateRGBSurface(0, currentDisplay.w, currentDisplay.h, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    SDL_RenderReadPixels(renderer, null, SDL_PIXELFORMAT_ARGB8888, surf.pixels, surf.pitch);
    string filename = "screenshots/screenshot";
    auto test = dirEntries("screenshots/", SpanMode.shallow);
    filename ~= to!string(count(test) + 1) ~ ".png";
    IMG_SavePNG(surf, filename.toStringz());
    SDL_FreeSurface(surf);
}

void createTexture(SDL_Renderer* renderer, ref int width, ref int height, string text,
    TTF_Font* font, SDL_Texture **texture, SDL_Color textColor) 
{
    SDL_Surface *surface;
    surface = TTF_RenderText_Solid(font, text.toStringz(), textColor);
    assert(surface);
    
    if(*texture) SDL_DestroyTexture(*texture);
    *texture = SDL_CreateTextureFromSurface(renderer, surface);
    assert(texture);
    
    width = surface.w;
    height = surface.h;
    SDL_FreeSurface(surface);
}

// From the Arduino docs. Maps a number t that falls in the range minFrom to maxFrom, to another number in
// the range between minTo and maxTo
import std.traits : isNumeric;
T mapToRange(T)(T t, T minFrom, T maxFrom, T minTo, T maxTo) if(isNumeric!T)
{
    return (t - minFrom) * (maxTo - minTo) / (maxFrom - minFrom) + minTo;
}

