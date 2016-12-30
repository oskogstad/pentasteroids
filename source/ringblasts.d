module ringblasts;
import app;

enum BlastSize
{
	SMALL,
	MEDIUM,
	LARGE
}

struct Blast 
{
	SDL_Texture* texture;
	BlastSize size;
	bool del;
	int 
		x, 
		y,
		w,
		h,
		animationFrame;
}

Blast[] activeBlasts;
SDL_Texture*[] blastTextures;
SDL_Rect* blastSRect, blastDRect;

const int SMALL_BLAST_FRAMES = 49;
const int MEDIUM_BLAST_FRAMES = 20;
const int BIG_BLAST_FRAMES = 30;

void setup(SDL_Renderer *renderer)
{
	app.loadGFXFromDisk("img/blasts/", renderer, blastTextures);
	foreach(texture; blastTextures) assert(texture);
	
	blastSRect = new SDL_Rect();
	blastSRect.y = 0;
	blastDRect = new SDL_Rect();
}

void updateAndDraw(SDL_Renderer *renderer)
{
	activeBlasts = remove!(blast => blast.del)(activeBlasts);
	foreach(ref blast; activeBlasts)
	{
		blastSRect.w = blast.w;
		blastSRect.h = blast.h;
		blastSRect.x = blast.animationFrame-- * blast.w;
		if(blast.animationFrame == 0)
		{
			blast.del = true;
		}
		blastDRect.x = blast.x - blast.w/2;
		blastDRect.y = blast.y - blast.h/2;
		blastDRect.w = blast.w;
		blastDRect.h = blast.h;
	
		SDL_RenderCopy(renderer, blast.texture, blastSRect, blastDRect);
	}
}

void createBlast(int x, int y, BlastSize bs)
{
	Blast b;
	b.x = x;
	b.y = y;

	if(bs == BlastSize.SMALL)
	{
		b.texture = blastTextures[0];
		b.w = 256;
		b.h = 256;
		b.animationFrame = SMALL_BLAST_FRAMES - 1;

	} 
	else if(bs == BlastSize.MEDIUM)
	{
		b.texture = blastTextures[1];
		b.w = 512;
		b.h = 512;
	} 
	else
	{
		b.texture = blastTextures[2];
		b.w = 1024;
		b.h = 1024;
	} 
	b.size = bs;

	activeBlasts ~= b;
}