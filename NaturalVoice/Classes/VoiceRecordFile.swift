//
//  VoiceRecordFile.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

struct VoiceRecordFile {
    
    var audioUrl: URL!
    var audioType: VoiceMediaType!
    
    init(audioType: VoiceMediaType) {
        self.audioType = audioType
        let fileName = UUID().uuidString + "." + self.audioType.extString
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0]
        self.audioUrl = path.appendingPathComponent(fileName)
    }
}
