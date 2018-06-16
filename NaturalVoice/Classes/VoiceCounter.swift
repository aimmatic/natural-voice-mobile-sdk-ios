//
//  VoiceCounter.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

class VoiceCounter {
    
    fileprivate static let instance = VoiceCounter()
    fileprivate let interval: TimeInterval = VoiceRecordStrategy.recordMaxSecond
    fileprivate var timer: Timer?
    var completedCount: (() -> Void)?
    
    static var shared: VoiceCounter {
        return self.instance
    }
    
    func startCounting() {
        self.stopCounting()
        self.timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector: #selector(self.counting(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func counting(timer: Timer) {
        self.stopCounting()
        if let completedCount = self.completedCount {
            completedCount()
        }
    }
    
    func stopCounting() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
}
