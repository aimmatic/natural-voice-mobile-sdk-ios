//
//  VoiceRecorder.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import AVFoundation

public typealias VoiceRecordStart = ((VoiceFileMeta?) -> Void)
public typealias VoiceRecordEnd = ((VoiceRecordEndResponse?) -> Void)
public typealias VoiceRecordError = ((Error?) -> Void)
public typealias VoiceRecordSent = ((VoiceRecordSendResponse?) -> Void)

open class VoiceRecorder: NSObject {
    
    fileprivate static let instance = VoiceRecorder()
    fileprivate var counter = VoiceCounter.shared
    fileprivate var locationService = VoiceLocationManager.shared
    fileprivate var recordStarted: VoiceRecordStart?
    fileprivate var recordEnded: VoiceRecordEnd?
    fileprivate var recordFailed: VoiceRecordError?
    fileprivate var recordSent: VoiceRecordSent?
    fileprivate var audioMeta: VoiceFileMeta!
    fileprivate var recordSettings: [String: Any]!
    fileprivate var recorder: AVAudioRecorder!
    fileprivate var audioFile: VoiceFile!
    
    open static var shared: VoiceRecorder {
        return self.instance
    }
    
    public override init() {
        super.init()
        
        let messageDuration = "Record duration must not be longer than \(VoiceResource.maxDuration)"
        assert(VoiceRecordStrategy.maxRecordDuration <= VoiceResource.maxDuration , messageDuration)
        let messageApiKey = "Invalid api key"
        assert(VoiceRecordStrategy.apiKey != "", messageApiKey)
        let messageLanguage = "Language not set"
        assert(VoiceRecordStrategy.language != nil, messageLanguage)
        
        self.audioMeta = VoiceFileMeta()
        self.audioMeta.bitRate = VoiceMeta.bitRate
        self.audioMeta.sampleRate = VoiceMeta.sampleRate
        self.audioMeta.channels = VoiceMeta.channel
        self.recordSettings = [AVFormatIDKey: kAudioFormatLinearPCM,
                               AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                               AVEncoderBitRateKey: self.audioMeta.bitRate,
                               AVNumberOfChannelsKey: self.audioMeta.channels,
                               AVSampleRateKey: self.audioMeta.sampleRate]
    }
    
    open func startRecording(recordStarted: VoiceRecordStart?, recordEnded: VoiceRecordEnd?, recordSent: VoiceRecordSent?, recordFailed: VoiceRecordError?) {
        self.recordStarted = recordStarted
        self.recordEnded = recordEnded
        self.recordSent = recordSent
        self.recordFailed = recordFailed
        if nil == self.recorder {
            self.setupRecordSession()
            self.setupRecorder()
        }
    }
    
    open func stopRecording(policy: VoicePolicy) {
        self.eeennd(state: .endByUser, policy: policy)
    }
    
    fileprivate func setupRecordSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord)
            try session.setActive(true)
        } catch {
            self.recordFailed?(error)
        }
    }
    
    fileprivate func setupRecorder() {
        self.audioFile = VoiceFile(audioType: .audioWave)
        do {
            self.recorder = try AVAudioRecorder(url: self.audioFile.fileUrl, settings: self.recordSettings)
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = false
            self.recorder.prepareToRecord()
            self.recorder.record()
            self.start()
        } catch {
            self.recorder = nil
            self.recordFailed?(error)
        }
    }
    
    fileprivate func start() {
        self.recordStarted?(self.audioMeta)
        self.counter.completedCount = {
            self.eeennd(state: .endByMax, policy: VoiceRecordStrategy.maxRecordDurationPolicy)
        }
        self.counter.start()
    }
    
    fileprivate func eeennd(state: VoiceEndState, policy: VoicePolicy) {
        guard let recorder = self.recorder else { return }
        guard true == recorder.isRecording else { return }
        self.recorder.stop()
        self.counter.stop()
        let session = AVAudioSession.sharedInstance()
        do { try session.setActive(false) } catch { }
        let response = VoiceRecordEndResponse(state: state, policy: policy, onSend: {
            self.sendFile()
        }, onAbort: {
            self.removeFile(url: self.audioFile.fileUrl)
        })
        self.recordEnded?(response)
        switch policy {
        case .userChoice:
            //do nothing
            break
        case .sendImmediately:
            self.sendFile()
            break
        case .cancel:
            self.removeFile(url: self.audioFile.fileUrl)
            break
        }
    }

    fileprivate func sendFile() {
        let location = self.locationService.location
        let sender = VoiceSender()
        sender.sendFile(file: self.audioFile, loc: location, meta: self.audioMeta) { data, error in
            if let error = error {
                self.removeFile(url: self.audioFile.fileUrl)
                let result = VoiceRecordSendResult(message: error.localizedDescription, data: nil)
                let status = VoiceRecordSendStatus.failure
                let response = VoiceRecordSendResponse(result: result, status: status, error: error)
                self.recordSent?(response)
            } else {
                self.removeFile(url: self.audioFile.fileUrl)
                let result = VoiceRecordSendResult(message: "Success", data: data)
                let status = VoiceRecordSendStatus.success
                let response = VoiceRecordSendResponse(result: result, status: status, error: nil)
                self.recordSent?(response)
            }
        }
    }
    
    fileprivate func removeFile(url: URL) {
        if true == FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch { }
        }
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recorder = nil
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.recordFailed?(error)
    }
}
