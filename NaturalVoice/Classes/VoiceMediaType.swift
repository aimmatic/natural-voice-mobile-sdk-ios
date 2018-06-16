//
//  VoiceMediaType.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

enum VoiceMediaType {
    
    case audioWave
    
    var mediaType: String {
        switch self {
        case .audioWave:
            return "audio/wav"
        }
    }
    
    var extString: String {
        switch self {
        case .audioWave:
            return "wav"
        }
    }
}
