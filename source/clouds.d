module clouds;
import app;
import game;
import player;

SDL_Texture *cloud;
int cloudWidth, cloudHeight;
public SDL_Rect *cloudRect;


// --------------------------------------------------- move all this to world, as background
void setup(SDL_Renderer *renderer)
{
	auto cloudPath = "img/clouds/cloud01_40.png";
	cloud = IMG_LoadTexture(renderer, cloudPath.ptr);
	assert(cloud);
	SDL_QueryTexture(cloud, null, null, &cloudWidth, &cloudHeight);
	cloudRect = new SDL_Rect();
	cloudRect.w = cloudWidth, cloudRect.h = cloudHeight;
	cloudRect.x = (app.currentDisplay.w / 2) - (cloudWidth / 2), cloudRect.y = (app.currentDisplay.h / 2) - (cloudHeight / 2);
}

void updateAndDraw(SDL_Renderer *renderer)
{
	if(game.angleMode)
	{
		SDL_RenderCopyEx(renderer, cloud, null, cloudRect, -game.angle, null, 0);
	}
	else
	{
		cloudRect.x = cast(int)(player.spaceShipRect.x * 0.04) - 400; cloudRect.y = cast(int) (player.spaceShipRect.y * 0.04) - 300;
		SDL_RenderCopy(renderer, cloud, null, cloudRect);
	}
}