//
//  VoiceResource.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/10/18.
//

struct VoiceResource {
    static let callbackInterval: TimeInterval = 0.01
    static let maxDuration: TimeInterval = 60
    static let speechTimeout: TimeInterval = 2
    static let host: String = "http://api.aimmatic.info"
    static let apiVersion: String = "/v1"
    static let naturalVoice: String = "/insights/UploadAudio"
    static let naturalVoiceLanguage: String = "/insights/langs"
}
