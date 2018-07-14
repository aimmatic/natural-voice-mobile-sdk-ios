//
//  WaveHeader.h
//  NaturalVoice
//
//  Created by Lay Channara on 7/14/18.
//

#import <Foundation/Foundation.h>

@interface WaveHeader : NSObject

+ (NSData *)pcmToWav:(NSData *)pcmData totalLength:(int)totalLength;

@end
