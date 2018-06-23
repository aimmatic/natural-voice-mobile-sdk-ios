//
//  VoiceRecordEndState.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

public enum VoiceEndState: Int {
    case endByMax = 1
    case endByUser = 2
    case endByInterruption = 3
    case endByIdle = 4
}
