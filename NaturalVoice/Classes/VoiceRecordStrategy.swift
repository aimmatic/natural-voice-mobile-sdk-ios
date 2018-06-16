//
//  VoiceRecordStrategy.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public struct VoiceRecordStrategy {
    public static var apiKey: String = ""
    public static var maxRecordDuration: TimeInterval = 60
    public static var maxRecordDurationPolicy = VoiceRecordPolicy.sendImmediately
    public static var language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
}

//onSpeechTimeOut: 3 below
//onMaxRecordDuration: 3 below

//stop 3 below


