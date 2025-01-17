//
//  VoiceMediaType.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

enum VoiceMediaType {

    case audioWave
    case audioFlac
    
    var mediaType: String {
        switch self {
        case .audioWave: return "audio/wav"
        case .audioFlac: return "audio/flac"
        }
    }
    
    var extensionString: String {
        switch self {
        case .audioWave: return "wav"
        case .audioFlac: return "flac"
        }
    }
}
