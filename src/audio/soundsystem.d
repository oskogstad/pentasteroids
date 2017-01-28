import everything;

Mix_Chunk* music01;

void setup()
{
	// load all chunks
	music01 = Mix_LoadWAV("sfx/music/menu_pad01_arp.wav");
	assert(music01);
	Mix_PlayChannel(-1, music01, -1);
}

void updateAndPlay()
{
	// for every music in activeMusic

	// check if playing, return if true

	// check all for deletion

	// play all sounds
}

void stopSound(int channel)
{
	// remove channel from activeMusic
}

void startSound(int channel)
{
	// add channel to activeMusic
}