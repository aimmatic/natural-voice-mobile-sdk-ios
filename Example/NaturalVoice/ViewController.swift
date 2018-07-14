//
//  ViewController.swift
//  NaturalVoice
//
//  Created by LayChannara on 06/17/2018.
//  Copyright (c) 2018 LayChannara. All rights reserved.
//

import UIKit
import NaturalVoice

class ViewController: UIViewController {

    var languages: [VoiceLanguage] = []
    var pickerTitles: [String] = []
    var pickerView: UIPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRecordStrategy.encoder = VoiceEncoder.flac
        VoiceRecordStrategy.maxRecordDuration = 50
        VoiceRecordStrategy.maxRecordDurationPolicy = .sendImmediately
        VoiceRecordStrategy.speechTimeout = 4.0
        VoiceRecordStrategy.speechTimeoutPolicy = .sendImmediately
        
        VoiceLanguageManager.shared.getSupportLanguages { languages in
            var pickerTitles = ["Choose Language"]
            pickerTitles.append(contentsOf: languages.map { $0.displayLang })
            self.pickerTitles = pickerTitles
            self.languages = languages
            self.pickerView = UIPickerView(frame: .zero)
            self.pickerView?.dataSource = self
            self.pickerView?.delegate = self
            self.view.addSubview(self.pickerView!)
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.pickerView?.frame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 165)
    }
    
    @IBAction func recordTapped(sender: UIButton) {
        
        guard nil != VoiceRecordStrategy.language else {
            let controller = UIAlertController(title: nil, message: "Please select language", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: {})
            return
        }
        
        VoiceRecorder.shared.startRecording(recordStarted: { meta in
            print("sampleRate: \(meta!.sampleRate)\nchannels: \(meta!.channels)\nbitRate: \(meta!.bitRate)")
        }, recordEnded: { response in
            switch response!.state {
            case .endByMax:
                print("end by max")
                break
            case .endByUser:
                print("end by user")
                break
            case .endByInterruption:
                print("end by interruption")
                break
            case .endByIdle:
                print("end by idle")
                break
            }
            switch response!.policy {
            case .userChoice:
                print("with userchoice policy")
                let controller = UIAlertController(title: "Send or abort", message: nil, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Send", style: .default, handler: { a in
                    print("user chooses send")
                    response!.send()
                }))
                controller.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: { a in
                    print("user chooses abort")
                    response!.abort()
                }))
                self.present(controller, animated: true, completion: {})
                break
            case .sendImmediately:
                print("with sendimmediately policy")
                break
            case .cancel:
                print("with cancel policy")
                break
            }
        }, recordSent: { response in
            print("Record sent")
            switch response!.status {
            case .failure:
                print(response!.error!.localizedDescription)
                break
            case .success:
                let string = String(data: response!.result.data!, encoding: String.Encoding.utf8)
                print(string!)
                break
            }
        }, recordFailed: { error in
            print(error!.localizedDescription)
        })
    }
    
    @IBAction func stopAndChooseTapped(sender: UIButton) {
        VoiceRecorder.shared.stopRecording(policy: .userChoice)
    }
    
    @IBAction func stopAndSendTapped(sender: UIButton) {
        VoiceRecorder.shared.stopRecording(policy: .sendImmediately)
    }
    
    @IBAction func stopAndCancelTapped(sender: UIButton) {
        VoiceRecorder.shared.stopRecording(policy: .cancel)
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            VoiceRecordStrategy.language = self.languages[row - 1]
        } else {
            VoiceRecordStrategy.language = nil
        }
    }
}

