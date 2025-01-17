//
//  VoiceRecorder.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import AVFoundation

public typealias VoiceRecordStarted = ((VoiceFileMeta?) -> Void)
public typealias VoiceRecordEnded = ((VoiceRecordEndResponse?) -> Void)
public typealias VoiceRecordFailed = ((Error?) -> Void)
public typealias VoiceRecordSent = ((VoiceRecordSendResponse?) -> Void)

open class VoiceRecorder: NSObject {
    
    fileprivate static let instance = VoiceRecorder()
    fileprivate var locationService = VoiceLocationManager.shared
    fileprivate var recordStarted: VoiceRecordStarted?
    fileprivate var recordEnded: VoiceRecordEnded?
    fileprivate var recordFailed: VoiceRecordFailed?
    fileprivate var recordSent: VoiceRecordSent?
    fileprivate var audioMeta: VoiceFileMeta!
    fileprivate var recordSettings: [String: Any]!
    fileprivate var recorder: AVAudioRecorder!
    fileprivate var audioFile: VoiceFile!
    fileprivate var currentEndState = VoiceEndState.endByMax
    fileprivate var currentPolicy = VoiceRecordStrategy.maxRecordDurationPolicy
    fileprivate var counter = VoiceCounter.shared
    fileprivate var lowPassResults: Float = 0.0
    fileprivate var speechTimeout: TimeInterval = 0.0
    
    deinit {
        let notificationName = NSNotification.Name.AVAudioSessionInterruption
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
    open static var shared: VoiceRecorder {
        return self.instance
    }
    
    public override init() {
        super.init()
        
        self.counter.callbackTimer = { self.micLevelChecker() }
        self.audioMeta = VoiceFileMeta()
        self.audioMeta.bitRate = VoiceMeta.bitRate
        self.audioMeta.sampleRate = VoiceMeta.sampleRate
        self.audioMeta.channels = VoiceMeta.channel
        self.recordSettings = [AVFormatIDKey: kAudioFormatLinearPCM,
                               AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                               AVEncoderBitRateKey: self.audioMeta.bitRate,
                               AVNumberOfChannelsKey: self.audioMeta.channels,
                               AVSampleRateKey: self.audioMeta.sampleRate]
        
        let selector = #selector(handleInterruption(object:))
        let notificationName = NSNotification.Name.AVAudioSessionInterruption
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    open func startRecording(recordStarted: VoiceRecordStarted?, recordEnded: VoiceRecordEnded?, recordSent: VoiceRecordSent?, recordFailed: VoiceRecordFailed?) {
        
        guard let apiKey = VoiceResource.apiKey, apiKey != "" else {
            let description = VoiceResource.apiKeyDescription
            let message = "ApiKey is invalid, please add key \(description) with valid apikey value in Info.plist."
            preconditionFailure(message)
        }
        
        guard VoiceResource.maxDuration >= VoiceRecordStrategy.maxRecordDuration else {
            let description = VoiceResource.maxDuration
            let message = "Max record duration must not be longer than \(description)."
            preconditionFailure(message)
        }
        
        guard nil != VoiceRecordStrategy.language else {
            let message = "Speech language has not been set."
            preconditionFailure(message)
        }
        
        self.recordStarted = recordStarted
        self.recordEnded = recordEnded
        self.recordSent = recordSent
        self.recordFailed = recordFailed
        self.currentEndState = .endByMax
        self.currentPolicy = VoiceRecordStrategy.maxRecordDurationPolicy
        if nil == self.recorder {
            self.recordPermission { granted in
                if granted {
                    self.setupRecordSession()
                    self.setupRecorder()
                }
            }
        }
    }
    
    open func stopRecording(policy: VoicePolicy) {
        self.forceStop(state: .endByUser, policy: policy)
    }
    
    //MARK: - Permission
    
    func recordPermission(result: ((Bool) -> Void)?) {
        let permission = AVAudioSession.sharedInstance().recordPermission()
        switch permission {
        case .granted:
            result?(true)
            break
        case .denied:
            result?(false)
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                result?(granted)
            }
            break
        }
    }
    
    //MARK: - Recording
    
    fileprivate func setupRecordSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            self.recordFailed?(error)
        }
    }
    
    fileprivate func setupRecorder() {
        self.speechTimeout = 0
        self.audioFile = VoiceFile(audioType: .audioWave)
        do {
            self.recorder = try AVAudioRecorder(url: self.audioFile.fileUrl, settings: self.recordSettings)
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            self.recorder.prepareToRecord()
            self.recorder.record(forDuration: VoiceRecordStrategy.maxRecordDuration)
            self.counter.start()
            self.recordStarted?(self.audioMeta)
        } catch {
            self.recorder = nil
            self.recordFailed?(error)
        }
    }
    
    fileprivate func forceStop(state: VoiceEndState, policy: VoicePolicy) {
        guard let recorder = self.recorder else { return }
        guard true == recorder.isRecording else { return }
        self.currentEndState = state
        self.currentPolicy = policy
        self.recorder.stop()
        do { try AVAudioSession.sharedInstance().setActive(false) } catch { }
    }

    fileprivate func sendFile() {
        let encoder = VoiceRecordStrategy.encoder
        switch encoder {
        case .wave:
            self.sendWave()
            break
        case .flac:
            self.sendFlac()
            break
        }
    }
    
    fileprivate func sendWave() {
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
    
    fileprivate func sendFlac() {
        if let pcmData = try? Data(contentsOf: self.audioFile.fileUrl), let wavData = WaveHeader.pcm(toWav: pcmData, totalLength: Int32(pcmData.count)) {
            do {
                try wavData.write(to: self.audioFile.fileUrl, options: Data.WritingOptions.atomic)
                let wave_file_in = NSString(string: self.audioFile.fileUrl.path).utf8String
                let flacFile = VoiceFile(audioType: .audioFlac)
                let flac_file_out = NSString(string: flacFile.fileUrl.path).utf8String
                let status = convertWaveToFlac(wave_file_in, flac_file_out)
                if 0 == status {
                    let location = self.locationService.location
                    let sender = VoiceSender()
                    sender.sendFile(file: flacFile, loc: location, meta: self.audioMeta) { data, error in
                        if let error = error {
                            self.removeFile(url: self.audioFile.fileUrl)
                            self.removeFile(url: flacFile.fileUrl)
                            let result = VoiceRecordSendResult(message: error.localizedDescription, data: nil)
                            let status = VoiceRecordSendStatus.failure
                            let response = VoiceRecordSendResponse(result: result, status: status, error: error)
                            self.recordSent?(response)
                        } else {
                            self.removeFile(url: self.audioFile.fileUrl)
                            self.removeFile(url: flacFile.fileUrl)
                            let result = VoiceRecordSendResult(message: "Success", data: data)
                            let status = VoiceRecordSendStatus.success
                            let response = VoiceRecordSendResponse(result: result, status: status, error: nil)
                            self.recordSent?(response)
                        }
                    }
                } else {
                    self.removeFile(url: self.audioFile.fileUrl)
                    let error = NSError(domain: "Error coverting flac.", code: 0, userInfo: nil)
                    let result = VoiceRecordSendResult(message: error.localizedDescription, data: nil)
                    let status = VoiceRecordSendStatus.failure
                    let response = VoiceRecordSendResponse(result: result, status: status, error: error)
                    self.recordSent?(response)
                }
            } catch {
                self.removeFile(url: self.audioFile.fileUrl)
                let error = NSError(domain: "Error coverting flac.", code: 0, userInfo: nil)
                let result = VoiceRecordSendResult(message: error.localizedDescription, data: nil)
                let status = VoiceRecordSendStatus.failure
                let response = VoiceRecordSendResponse(result: result, status: status, error: error)
                self.recordSent?(response)
            }
        } else {
            self.removeFile(url: self.audioFile.fileUrl)
            let error = NSError(domain: "Error coverting flac.", code: 0, userInfo: nil)
            let result = VoiceRecordSendResult(message: error.localizedDescription, data: nil)
            let status = VoiceRecordSendStatus.failure
            let response = VoiceRecordSendResponse(result: result, status: status, error: error)
            self.recordSent?(response)
        }
    }
    
    fileprivate func removeFile(url: URL) {
        if true == FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch { }
        }
    }
    
    fileprivate func micLevelChecker() {
        self.recorder.updateMeters()
        let threshold: Float = 0.099
        let alpha: Float = 0.05
        let decibels = self.recorder.peakPower(forChannel: 0)
        let peakPower = Float(pow(10, (alpha * decibels)))
        self.lowPassResults = alpha * peakPower + (1.0 - alpha) * self.lowPassResults
        if self.lowPassResults > threshold {
            self.speechTimeout = 0
        } else {
            let configuredTimeout = VoiceRecordStrategy.speechTimeout
            if configuredTimeout > 0 {
                let interval = VoiceResource.callbackInterval
                self.speechTimeout = self.speechTimeout + interval
                if self.speechTimeout >= configuredTimeout {
                    self.forceStop(state: .endByIdle, policy: VoiceRecordStrategy.speechTimeoutPolicy)
                }
            }
        }
    }
    
    @objc func handleInterruption(object: NSNotification) {
        guard let userInfo = object.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else { return }
        switch type.uintValue {
        case AVAudioSessionInterruptionType.began.rawValue:
            self.forceStop(state: .endByInterruption, policy: VoiceRecordStrategy.maxRecordDurationPolicy)
            break
        default:
            break
        }
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recorder = nil
        self.counter.stop()
        let response = VoiceRecordEndResponse(state: self.currentEndState, policy: self.currentPolicy, onSend: {
            self.sendFile()
        }, onAbort: {
            self.removeFile(url: self.audioFile.fileUrl)
        })
        self.recordEnded?(response)
        switch self.currentPolicy {
        case .userChoice:
            break
        case .sendImmediately:
            self.sendFile()
            break
        case .cancel:
            self.removeFile(url: self.audioFile.fileUrl)
            break
        }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.recordFailed?(error)
    }
}
