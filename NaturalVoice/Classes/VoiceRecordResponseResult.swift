//
//  VoiceRecordResponseResult.swift
//  NaturalVoice
//
//  Created by Lay Channara on 6/16/18.
//

let messageInvalidApiKey: String = "Invalid api key"
let messageInvalidLanguage: String = "Invalid language"

public struct VoiceRecordResponseResult {
    public var message: String
    public var data: Data?
}
