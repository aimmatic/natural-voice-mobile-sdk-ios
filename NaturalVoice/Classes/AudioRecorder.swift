//
//  AudioRecorder.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import AVFoundation

public typealias AudioRecordStart = ((AudioMeta?) -> Void)
public typealias AudioRecordEnd = ((AudioEndState?) -> Void)
public typealias AudioRecordError = ((Error?) -> Void)
public typealias AudioRecordSent = ((AudioResponse?) -> Void)

open class AudioRecorder: NSObject {
    
    fileprivate static let instance = AudioRecorder()
    fileprivate var start: AudioRecordStart?
    fileprivate var end: AudioRecordEnd?
    fileprivate var failed: AudioRecordError?
    fileprivate var sent: AudioRecordSent?
    fileprivate var endState: AudioEndState?
    fileprivate var audioMeta: AudioMeta?
    fileprivate var counter = AudioCounter.shared
    fileprivate var locationService = AudioLocationManager.shared
    var recorder: AVAudioRecorder!
    var audioFile: AudioFile!
    
    open static var shared: AudioRecorder {
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
    
    open func stopRecording(state: AudioEndState) {
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
        self.audioMeta = AudioMeta(sampleRate: AudioContext.sampleRate,
                                   channels: AudioContext.channel,
                                   bitRate: AudioContext.bitRate)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            AVEncoderBitRateKey: self.audioMeta!.bitRate,
            AVNumberOfChannelsKey: self.audioMeta!.channels,
            AVSampleRateKey: self.audioMeta!.sampleRate
        ]
        do {
            self.audioFile = AudioFile(audioType: .audioWave)
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
        let sender = AudioSender()
        sender.sendVoice(file: self.audioFile, loc: location, meta: self.audioMeta!, sent: self.sent)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recorder = nil
        self.end?(self.endState)
        self.sendVoice()
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.failed?(error)
    }
}
