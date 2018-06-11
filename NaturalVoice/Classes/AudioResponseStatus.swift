//
//  AudioResponseStatus.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

let messageInvalidApiKey: String = "Invalid api key"
let messageInvalidLanguage: String = "Invalid language"

public struct AudioResponseResult {
    public var message: String
    public var data: Data?
}

public enum AudioResponseStatus {
    case success
    case failure
}
