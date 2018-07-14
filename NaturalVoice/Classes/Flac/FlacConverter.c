//
//  FlacConverter.c
//  NaturalVoice
//
//  Created by Lay Channara on 7/14/18.
//

#include "FlacConverter.h"
#include <FLACiOS/metadata.h>
#include <FLACiOS/stream_encoder.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define READSIZE 1020
/* can use a 32-bit number due to WAVE size limitations */
static unsigned totalSamples = 0;
/* we read the WAVE data into here */
static FLAC__byte buffer[READSIZE/*samples*/ * 2/*bytes_per_sample*/ * 2/*channels*/];

static FLAC__int32 pcm[READSIZE/*samples*/ * 2/*channels*/];

static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

int convertWaveToFlac(const char *wavfile, const char *flacfile)
{
    FLAC__bool ok = true;
    FLAC__StreamEncoder *encoder = 0;
    FLAC__StreamEncoderInitStatus initStatus;
    FILE *fin;
    unsigned sampleRate = 0;
    unsigned channels = 0;
    unsigned bps = 0;
    
    if((fin = fopen(wavfile, "rb")) == NULL)
    {
        fprintf(stderr, "ERROR: opening %s for output\n", wavfile);
        return 1;
    }
    
    /* read wav header and validate it */
    if (fread(buffer, 1, 44, fin) != 44 || memcmp(buffer, "RIFF", 4) || memcmp(buffer + 8, "WAVEfmt \020\000\000\000\001\000\001\000", 16) ||memcmp(buffer + 32, "\002\000\020\000data", 8))
    {
        fprintf(stderr, "ERROR: invalid/unsupported WAVE file, only 16bps stereo WAVE in canonical form allowed\n");
        fclose(fin);
        return 1;
    }
    sampleRate = ((((((unsigned)buffer[27] << 8) | buffer[26]) << 8) | buffer[25]) << 8) | buffer[24];
    channels = 1;
    bps = 16;
    totalSamples = (((((((unsigned)buffer[43] << 8) | buffer[42]) << 8) | buffer[41]) << 8) | buffer[40]) / 2;
    
    /* allocate the encoder */
    if((encoder = FLAC__stream_encoder_new()) == NULL)
    {
        fprintf(stderr, "ERROR: allocating encoder\n");
        fclose(fin);
        return 1;
    }
    
    ok &= FLAC__stream_encoder_set_verify(encoder, true);
    ok &= FLAC__stream_encoder_set_compression_level(encoder, 5);
    ok &= FLAC__stream_encoder_set_channels(encoder, channels);
    ok &= FLAC__stream_encoder_set_bits_per_sample(encoder, bps);
    ok &= FLAC__stream_encoder_set_sample_rate(encoder, sampleRate);
    ok &= FLAC__stream_encoder_set_total_samples_estimate(encoder, totalSamples);
    
    /* initialize encoder */
    if(ok)
    {
        initStatus = FLAC__stream_encoder_init_file(encoder, flacfile, progress_callback, NULL);
        if(initStatus != FLAC__STREAM_ENCODER_INIT_STATUS_OK)
        {
            fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[initStatus]);
            ok = false;
        }
    }
    
    /* read blocks of samples from WAVE file and feed to encoder */
    if(ok)
    {
        fprintf(stdout, "Encoding: ");
        size_t left = (size_t)totalSamples;
        while(ok && left)
        {
            size_t need = (left>READSIZE ? (size_t)READSIZE : (size_t)left);
            if (fread(buffer, channels * (bps / 8), need, fin) != need)
            {
                fprintf(stderr, "ERROR: reading from WAVE file\n");
                ok = false;
            }
            else
            {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
                size_t i;
                for(i = 0; i < need*channels; i++)
                {
                    /* inefficient but simple and works on big- or little-endian machines */
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)buffer[2 * i + 1] << 8) | (FLAC__int16)buffer[2 * i]);
                }
                /* feed samples to encoder */
                ok = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
            }
            left -= need;
        }
    }
    
    ok &= FLAC__stream_encoder_finish(encoder);
    
    fprintf(stdout, "%s\n", ok ? "Succeeded" : "FAILED");
    if (!ok) fprintf(stderr, "   State: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);
    
    FLAC__stream_encoder_delete(encoder);
    fclose(fin);
    
    return 0;
}

void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data)
{
    (void)encoder, (void)client_data;
    fprintf(stderr, "Wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, totalSamples, frames_written, total_frames_estimate);
}
