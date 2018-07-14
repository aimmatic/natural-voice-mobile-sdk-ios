//
//  WaveHeader.m
//  NaturalVoice
//
//  Created by Lay Channara on 7/14/18.
//

#import "WaveHeader.h"

@implementation WaveHeader

typedef struct
{
    char chChunkID[4];
    int nChunkSize;
} XCHUNKHEADER; //8

typedef struct
{
    short nFormatTag;
    short nChannels;
    int nSamplesPerSec;
    int nAvgBytesPerSec;
    short nBlockAlign;
    short nBitsPerSample;
} WAVEFORMATX; //16

typedef struct
{
    char chRiffID[4];
    int nRiffSize;
    char chRiffFormat[4];
} RIFFHEADER; //12

void WriteWAVEHeader(NSMutableData* fpwave, int pcmLength)
{
    char tag[10] = "";
    
    // 1. RIFF
    RIFFHEADER riff;
    strcpy(tag, "RIFF");
    memcpy(riff.chRiffID, tag, 4);
    riff.nRiffSize = pcmLength + 44 - 8;
    strcpy(tag, "WAVE");
    memcpy(riff.chRiffFormat, tag, 4);
    [fpwave appendBytes:&riff length:sizeof(RIFFHEADER)];
    
    // 2. FMT
    XCHUNKHEADER chunk;
    WAVEFORMATX wfx;
    strcpy(tag, "fmt ");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = sizeof(WAVEFORMATX);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
    memset(&wfx, 0, sizeof(WAVEFORMATX));
    wfx.nFormatTag = 1;
    wfx.nChannels = 1;
    wfx.nSamplesPerSec = 16000;
    wfx.nBitsPerSample = 16; // 16bps
    wfx.nBlockAlign = wfx.nChannels * wfx.nBitsPerSample / 8;
    wfx.nAvgBytesPerSec = wfx.nBlockAlign * wfx.nSamplesPerSec;
    [fpwave appendBytes:&wfx length:sizeof(WAVEFORMATX)];
    
    // 3. data
    strcpy(tag, "data");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = pcmLength;
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
}

+ (NSData *)pcmToWav:(NSData *)pcmData totalLength:(int)totalLength
{
    NSMutableData *wavData = [NSMutableData new];
    WriteWAVEHeader(wavData, (int)totalLength);
    [wavData appendData:pcmData];
    return wavData;
}

@end
