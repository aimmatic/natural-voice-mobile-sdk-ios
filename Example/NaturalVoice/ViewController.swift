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

    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRecordStrategy.apiKey = "FKwmNOD4Q304NBXLKfWXYA0J5q1R/w"
        VoiceRecordStrategy.language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
        VoiceRecordStrategy.maxRecordDuration = 10
        VoiceRecordStrategy.maxRecordDurationPolicy = .userChoice
    }
    
    @IBAction func recordTapped(sender: UIButton) {
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
            }
            switch response!.policy {
            case .userChoice:
                print("with userchoice policy")
                let controller = UIAlertController(title: "Send or abort", message: nil, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Send", style: .default, handler: { a in
                    response!.send()
                }))
                controller.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: { a in
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

