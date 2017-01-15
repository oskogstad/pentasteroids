import std.stdio;
import core.stdc.stdlib;
import core.stdc.string : memset;
static import std.file;
import std.regex;

import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;
import derelict.vorbis.enc;

import waved.utils;

AudioFramework *audio;

struct AudioFramework
{
    int deviceBufferSize;
    int deviceBufferCount;

    ALCdevice *device;
    ALCcontext *context;

    ALuint[] buffers;
    int[string] bufferMap;

    float listenerX, listenerY, listenerZ;

    bool create(int numBuffers, int bufferSize)
    {
        deviceBufferSize = bufferSize;
        deviceBufferCount = numBuffers;

        device = alcOpenDevice(null);
        if(!device)
        {
            writeln("Failed to open audio device!");
            return false;
        }

        context = alcCreateContext(device, null);
        if(!context)
        {
            writeln("Failed to create audio context");
            alcCloseDevice(device);
            return false;
        }

        if(!alcMakeContextCurrent(context))
        {
            writeln("Failed to make audio context current!");
            return false;
        }

        alGetError(); // Reset the OpenAL error stack

        listenerX = listenerY = listenerZ = 0;

        return true;
    }

    /// The file specific functions are responsible for calling createBuffer, to
    /// actually create the OpenAL buffer.
    bool load(string filename)
    {
        bool fileIsValid = std.file.exists(filename) && std.file.isFile(filename);
        if (!fileIsValid)
        {
            writeln(filename ~ " is not a valid file!");
            return false;
        }

        if (matchFirst(filename, ".*\\.ogg$"))
        {
            if(loadOggFile(&this, filename))
            {
                bufferMap[filename] = buffers[$-1];
                return true;
            }
            else return false;
        }
        else if (matchFirst(filename, ".*\\.wav$"))
        {
            byte[] fileData = cast(byte[])std.file.read(filename);
            if (decodeWAV(&this, fileData))
            {
                bufferMap[filename] = buffers[$-1];
                return true;
            }
            else return false;
        }
        else
        {
            writeln(filename, " has an unrecognized file ending.");
            return false;
        }
    }

    bool createBuffer(T)(ALenum alFormat, T[] pcm, int sampleRate)
    {
        ALuint bufferID;
        alGenBuffers(1, &bufferID);
        if (bufferID < 0)
        {
            writeln("Failed to generate OpenAL buffer!");
            return false;
        }

        alBufferData(
                bufferID,
                alFormat,
                cast(ALvoid*)pcm.ptr,
                cast(ALsizei)(pcm.length * T.sizeof),
                cast(ALsizei)sampleRate
                );

        buffers ~= bufferID;

        return true;
    }


    void setListenerPos(float x, float y, float z)
    {
        alListener3f(AL_POSITION, x, y, z);
    }

    void dispose()
    {
        alDeleteBuffers(cast(ALint)buffers.length, buffers.ptr);

        alcDestroyContext(context);
        alcCloseDevice(device);
    }

}

struct AudioSource
{
    ALuint sourceID;

    float volume = 1;
    float pitch = 1;
    float x=0, y=0, z=0;

    bool create(ALuint bufferID)
    {
        alGenSources(1, &sourceID);

        alSourcei(sourceID, AL_BUFFER, bufferID);

        return true;
    }

    void play()
    {
        alSourcePlay(sourceID);
    }

    void stop()
    {
        alSourceStop(sourceID);
    }

    void setVolume(float vol)
    {
        volume = vol;
        alSourcef(sourceID, AL_GAIN, vol);
    }

    void setPitch(float p)
    {
        pitch = p;
        alSourcef(sourceID, AL_PITCH, p);
    }

    void setPosition(float x, float y, float z)
    {
        alSource3f(sourceID, AL_POSITION, x, y, z);
    }

    void dispose()
    {
        alDeleteSources(1, &sourceID);
    }
}

bool setupAudio(int simultaneousSources)
{
    DerelictAL.load();
    DerelictVorbis.load();
    DerelictVorbisEnc.load();
    DerelictVorbisFile.load();

    audio = cast(AudioFramework*)malloc(AudioFramework.sizeof);
    memset(audio, 0, AudioFramework.sizeof);
    return audio.create(9, 512);
}

void disposeAudio()
{
    audio.dispose();
    free(audio);
}

static bool decodeWAV(AudioFramework *audio, byte[] input)
{
    // check RIFF header
    {
        uint chunkId, chunkSize;
        getRIFFChunkHeader(input, chunkId, chunkSize);
        if (chunkId != RIFFChunkId!"RIFF")
        {
            writeln("Expected RIFF chunk.");
            return false;
        }

        if (chunkSize < 4)
        {
            writeln("RIFF chunk is too small to contain a format.");
            return false;
        }

        if (popBE!uint(input) !=  RIFFChunkId!"WAVE")
        {
            writeln("Expected WAVE format.");
            return false;
        }
    }

    bool foundFmt = false;
    bool foundData = false;

    int audioFormat;
    int numChannels;
    int sampleRate;
    int byteRate;
    int blockAlign;
    int bitsPerSample;

    double[] pcmData;

    immutable int LinearPCM = 0x0001;
    immutable int FloatingPointIEEE = 0x0003;
    immutable int WAVE_FORMAT_EXTENSIBLE = 0xFFFE;

    // while chunk is not
    while (input.length != 0)
    {
        if (input.length == 1 && input[0] == 0)
        {
            break;
        }

        uint chunkId, chunkSize;
        getRIFFChunkHeader(input, chunkId, chunkSize);
        if (chunkId == RIFFChunkId!"fmt ")
        {
            writeln("fmt chunk");
            if (foundFmt)
            {
                writeln("Found several 'fmt ' chunks in RIFF file.");
                return false;
            }

            foundFmt = true;

            if (chunkSize < 16)
            {
                writeln("Expected at least 16 bytes in 'fmt ' chunk.");
                return false;
            }

            audioFormat = popLE!ushort(input);
            if (audioFormat == WAVE_FORMAT_EXTENSIBLE)
            {
                writeln("No support for format WAVE_FORMAT_EXTENSIBLE yet.");
                return false;
            }

            if (audioFormat != LinearPCM && audioFormat != FloatingPointIEEE)
            {
                writeln(
                        "Unsupported audio format %s, only PCM and IEEE float are supported.",
                        audioFormat);
                return false;
            }

            numChannels = popLE!ushort(input);

            sampleRate = popLE!uint(input);
            if (sampleRate <= 0)
            {
                writeln("Unsupported sample-rate %s.", cast(uint)sampleRate);
                return false;
            }

            uint bytesPerSec = popLE!uint(input);
            int bytesPerFrame = popLE!ushort(input);
            bitsPerSample = popLE!ushort(input);

            if (
                    bitsPerSample != 8 &&
                    bitsPerSample != 16 &&
                    bitsPerSample != 24 &&
                    bitsPerSample != 32)
            {
                writeln("Unsupported bitdepth %s.", cast(uint)bitsPerSample);
                return false;
            }

            if (bytesPerFrame != (bitsPerSample / 8) * numChannels)
            {
                writeln("Invalid bytes-per-second, data might be corrupted.");
                return false;
            }

            skipBytes(input, chunkSize - 16);
        }
        else if (chunkId == RIFFChunkId!"data")
        {
            writeln("Data chunk");
            if (foundData)
            {
                writeln("Found several 'data' chunks in RIFF file.");
                return false;
            }

            if (!foundFmt)
            {
                writeln("'fmt ' chunk expected before the 'data' chunk.");
                return false;
            }

            int bytePerSample = bitsPerSample / 8;
            uint frameSize = numChannels * bytePerSample;
            if (chunkSize % frameSize != 0)
            {
                writeln("Remaining bytes in 'data' chunk, inconsistent with audio data type.");
                return false;
            }

            uint numFrames = chunkSize / frameSize;
            uint numSamples = numFrames * numChannels;

            pcmData.length = numSamples;

            if (audioFormat == FloatingPointIEEE)
            {
                if (bytePerSample == 4)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        pcmData[i] = popFloatLE(input);
                    }
                }
                else if (bytePerSample == 8)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        pcmData[i] = popDoubleLE(input);
                    }
                }
                else
                {
                    writeln("Unsupported bit-depth for floating point data, should be 32 or 64.");
                    return false;
                }
            }
            else if (audioFormat == LinearPCM)
            {
                if (bytePerSample == 1)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        ubyte b = popUbyte(input);
                        pcmData[i] = (b - 128) / 127.0;
                    }
                }
                else if (bytePerSample == 2)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        int s = popLE!short(input);
                        pcmData[i] = s / 32767.0;
                    }
                }
                else if (bytePerSample == 3)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        int s = pop24bitsLE!(byte[])(input);
                        pcmData[i] = s / 8388607.0;
                    }
                }
                else if (bytePerSample == 4)
                {
                    for (uint i = 0; i < numSamples; ++i)
                    {
                        int s = popLE!int(input);
                        pcmData[i] = s / 2147483648.0;
                    }
                }
                else
                {
                    writeln("Unsupported bit-depth for integer PCM data, should be 8, 16, 24 or 32 bits.");
                    return false;
                }
            }
            else
                assert(false); // should have been handled earlier, crash

            foundData = true;
        }
        else
        {
            writeln("Ignored chunk!");
            // ignore unrecognized chunks
            skipBytes(input, chunkSize);
        }
    }

    if (!foundFmt)
    {
        writeln("'fmt' chunk not found.");
        return false;
    }

    if (!foundData)
    {
        writeln("'data' chunk not found.");
        return false;
    }

    ALenum alFormat;
    bool success = false;

    if(bitsPerSample == 8) // 8 unsigned in OpenAL
    {
        alFormat = numChannels > 1 ? AL_FORMAT_STEREO8 : AL_FORMAT_MONO8;

        ubyte[] pcmBytes;
        pcmBytes.length = pcmData.length;
        foreach(int i, d; pcmData)
        {
            pcmBytes[i] = cast(ubyte)(((1+d)/2) * ubyte.max);
        }

        success = audio.createBuffer(alFormat, pcmBytes, sampleRate);
    }
    else // 16-bit signed
    {
        alFormat = numChannels > 1 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;

        short[] pcmBytes;
        pcmBytes.length = pcmData.length;
        foreach(int i, d; pcmData)
        {
            pcmBytes[i] = cast(short)(d * short.max);
        }

        success = audio.createBuffer(alFormat, pcmBytes, sampleRate);
    }

    return success;
}

static bool loadOggFile(AudioFramework *audio, string filename)
{
    auto file = File(filename);
    OggVorbis_File vf;
    if(ov_open(file.getFP(), &vf, null, 0)<0)
    {
        writeln("Failed to load OGG file "~filename);
        return false;
    }

    auto info = ov_info(&vf, -1);
    short[] data;

    int currSection;
    byte[4096] pcmout;
    bool eof = false;
    while(!eof)
    {
        long bytesRead = ov_read(&vf, pcmout.ptr, cast(uint)(pcmout.sizeof), 0, 2, 1, &currSection);
        if(bytesRead == 0) eof = true;

        data ~= cast(short[])pcmout[0 .. cast(int)bytesRead]; // ask hallgeir about this cast to int --------------------------------------------------------
    }

    ALenum format = info.channels == 1? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

    return audio.createBuffer(format, data, info.rate);
}