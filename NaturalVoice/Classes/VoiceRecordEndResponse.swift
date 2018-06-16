//
//  VoiceRecordEndResponse.swift
//  NaturalVoice
//
//  Created by Lay Channara on 6/16/18.
//



public struct VoiceRecordEndResponse {
    public var state: VoiceEndState
    public var policy: VoicePolicy
    public func send() { self.onSend?() }
    public func abort() { self.onAbort?() }
    var onSend: (() -> Void)?
    var onAbort: (() -> Void)?
}
