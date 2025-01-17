//
//  VoiceRecordStrategy.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public struct VoiceRecordStrategy {
    public static var encoder: VoiceEncoder = VoiceEncoder.wave
    public static var maxRecordDuration: TimeInterval = VoiceResource.maxDuration
    public static var speechTimeout: TimeInterval =  VoiceResource.speechTimeout
    public static var maxRecordDurationPolicy = VoicePolicy.sendImmediately
    public static var speechTimeoutPolicy = VoicePolicy.sendImmediately
    public static var language: VoiceLanguage?
}


