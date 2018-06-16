//
//  VoiceCounter.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

class VoiceCounter {
    
    fileprivate static let instance = VoiceCounter()
    fileprivate let interval: TimeInterval = VoiceRecordStrategy.maxRecordDuration
    fileprivate var timer: Timer?
    var completedCount: (() -> Void)?
    
    static var shared: VoiceCounter {
        return self.instance
    }
    
    func start() {
        self.stop()
        self.timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector: #selector(self.count(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func count(timer: Timer) {
        self.stop()
        self.completedCount?()
    }
    
    func stop() {
        self.timer?.invalidate()
    }
}
