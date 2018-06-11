//
//  AudioFile.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

struct AudioFile {
    
    var audioUrl: URL!
    var audioType: AudioType!
    
    init(audioType: AudioType) {
        self.audioType = audioType
        let fileName = UUID().uuidString + "." + self.audioType.extString
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0]
        self.audioUrl = path.appendingPathComponent(fileName)
    }
}
