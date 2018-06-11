//
//  AudioMeta.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public struct AudioMeta {

    public var sampleRate: Int = AudioContext.sampleRate
    public var channels: Int = AudioContext.channel
    public var bitRate: Int = AudioContext.bitRate
}
