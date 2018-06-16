//
//  VoiceRecorder.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import AVFoundation

public typealias AudioRecordStart = ((VoiceRecordMeta?) -> Void)
public typealias AudioRecordEnd = ((VoiceRecordEndState?) -> Void)
public typealias AudioRecordError = ((Error?) -> Void)
public typealias AudioRecordSent = ((VoiceRecordResponse?) -> Void)

open class VoiceRecorder: NSObject {
    
    fileprivate static let instance = VoiceRecorder()
    fileprivate var start: AudioRecordStart?
    fileprivate var end: AudioRecordEnd?
    fileprivate var failed: AudioRecordError?
    fileprivate var sent: AudioRecordSent?
    fileprivate var endState: VoiceRecordEndState?
    fileprivate var audioMeta: VoiceRecordMeta?
    fileprivate var counter = VoiceCounter.shared
    fileprivate var locationService = VoiceLocationManager.shared
    var recorder: AVAudioRecorder!
    var audioFile: VoiceRecordFile!
    
    open static var shared: VoiceRecorder {
        return self.instance
    }
    
    open func startRecording(start: AudioRecordStart?, end: AudioRecordEnd?, sent: AudioRecordSent?, failed: AudioRecordError?) {
        self.start = start
        self.end = end
        self.sent = sent
        self.failed = failed
        if nil == self.recorder {
            self.setupRecordSession()
            self.setupRecorder()
        } else {
            if true == self.recorder.isRecording {
                self.stopRecording(state: .endByUser)
            }
        }
    }
    
    open func stopRecording(state: VoiceRecordEndState) {
        if nil != self.recorder && false != self.recorder.isRecording {
            self.endState = state
            self.recorder.stop()
            self.counter.stopCounting()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
            } catch { }
        }
    }
    
    fileprivate func setupRecordSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            self.failed?(error)
        }
        do {
            try session.setActive(true)
        } catch {
            self.failed?(error)
        }
    }
    
    fileprivate func setupRecorder() {
        self.audioMeta = VoiceRecordMeta(sampleRate: VoiceMeta.sampleRate,
                                   channels: VoiceMeta.channel,
                                   bitRate: VoiceMeta.bitRate)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            AVEncoderBitRateKey: self.audioMeta!.bitRate,
            AVNumberOfChannelsKey: self.audioMeta!.channels,
            AVSampleRateKey: self.audioMeta!.sampleRate
        ]
        do {
            self.audioFile = VoiceRecordFile(audioType: .audioWave)
            self.recorder = try AVAudioRecorder(url: self.audioFile.audioUrl, settings: settings)
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = false
            self.recorder.prepareToRecord()
            self.recorder.record()
            self.start?(self.audioMeta)
            self.counter.completedCount = {
                self.stopRecording(state: .endByMax)
            }
            self.counter.startCounting()
        } catch {
            self.recorder = nil
            self.failed?(error)
        }
    }
    
    fileprivate func sendVoice() {
        let location = self.locationService.location
        let sender = VoiceRecordSender()
        sender.sendVoice(file: self.audioFile, loc: location, meta: self.audioMeta!, sent: self.sent)
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recorder = nil
        self.end?(self.endState)
        self.sendVoice()
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.failed?(error)
    }
}
