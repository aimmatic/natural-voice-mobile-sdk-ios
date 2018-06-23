//
//  VoiceCounter.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

class VoiceCounter {
    
    fileprivate static let instance = VoiceCounter()
    fileprivate var timer: Timer?
    var callbackTimer: (() -> Void)?
    
    static var shared: VoiceCounter {
        return self.instance
    }
    
    func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ticker(timer:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        self.timer?.invalidate()
    }
    
    @objc func ticker(timer: Timer) {
        self.callbackTimer?()
    }
}
