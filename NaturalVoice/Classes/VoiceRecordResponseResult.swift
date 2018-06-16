//
//  VoiceRecordResponseResult.swift
//  NaturalVoice
//
//  Created by Lay Channara on 6/16/18.
//

let reponseMessageInvalidLanguage: String = "ReponseMessageInvalidLanguage"
let reponseMessageInvalidApiKey: String = "ReponseMessageInvalidApiKey"

public struct VoiceRecordResponseResult {
    public var message: String
    public var data: Data?
}
