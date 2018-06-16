//
//  VoiceRecordStrategy.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public struct VoiceRecordStrategy {
    public static var apiKey: String = ""
    public static var maxRecordDuration: TimeInterval = VoiceResource.maxDuration
    public static var maxRecordDurationPolicy = VoicePolicy.sendImmediately
    public static var language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
}


