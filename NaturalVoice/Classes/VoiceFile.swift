//
//  VoiceFile.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

struct VoiceFile {
    
    var fileUrl: URL!
    var fileType: VoiceMediaType!
    
    init(audioType: VoiceMediaType) {
        self.fileType = audioType
        let fileName = UUID().uuidString + "." + self.fileType.extensionString
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0]
        self.fileUrl = path.appendingPathComponent(fileName)
    }
}
