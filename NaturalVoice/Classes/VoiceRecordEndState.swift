//
//  VoiceRecordEndState.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public enum VoiceRecordEndState: Int {
    
    case endByMax = 1
    case endByUser = 2
    case endByIdle = 3
    case endByInterrupted = 4
}
