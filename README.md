# Natural Voice Mobile SDK For iOS #
This library allows you to add our voice reply functions into your iOS app.

## Read This First ##
Requires a plan and an API key.

## Free Plan ##
Sign up for the free plan [here](https://www.aimmatic.com/store/p1/free-plan.html), in less than 30 seconds you get an email order confirmation with a link to create your secure login to the Developer Console. Login to the developer console to create an app, create an API key, and access the API Reference.

# Usage #

## Requirements ##

• iOS 8.0+

• xCode 9

## Cocoapods ##

```bash
pod 'NaturalVoice'
```

## Install ##

```bash
pod install
```

## Info.plist ##

Natural Voice requires location service and microphone permission, you need to add these keys to Info.plist

```xml
<key>NSMicrophoneUsageDescription</key>
<string>YOUR_DESCRIPTION</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>YOUR_DESCRIPTION</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR_DESCRIPTION</string>
```

Add your ApiKey in Info.plist

```xml
<key>AimMaticNaturalVoiceApiKeyDescription</key>
<string>YOUR_API_KEY</string>
```



## Using Voice Service ##

### Get supported languages ###

```swift
VoiceLanguageManager.shared.getSupportLanguages { (languages: [VoiceLanguage]) in

}
```

### Configuration ###

```swift
VoiceRecordStrategy.language = language
VoiceRecordStrategy.maxRecordDuration = 30
VoiceRecordStrategy.maxRecordDurationPolicy = .sendImmediately
VoiceRecordStrategy.speechTimeout = 2
VoiceRecordStrategy.speechTimeoutPolicy = .sendImmediately
```

### Start recording ###

```swift
VoiceRecorder.shared.startRecording(recordStarted: { meta in

}, recordEnded: { response in

}, recordSent: { response in

}, recordFailed: { error in

})
```

### Block handle ###

When recording is started

```swift
let recordStared: VoiceRecordStarted = { (meta: VoiceFileMeta?) in

}
```

When recording is finished

```swift
let recordEnded: VoiceRecordEnded = { (response: VoiceRecordEndResponse?) in

}
```

When recording is sent

```swift
let recordSent: VoiceRecordSent = { (response: VoiceRecordSendResponse?) in

}
```

When recording is failed

```swift
let recordFailed: VoiceRecordFailed = { (error: Error?) in

}
```

Handle policy `.userChoice` when recording is finished

```swift
if response?.policy == .userChoice {
    let controller = UIAlertController(title: "Send or Abort?", message: nil, preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "Send", style: .default, handler: { action in
        /* Send recorded file */
        response?.send()
    }))
    controller.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: { action in
        /* Abort sending recorded file */
        response?.abort()
    }))
    self.present(controller, animated: true, completion: {})
}
```

### Stop recording ###

This will override policy that was set in

```swift
VoiceRecordStrategy.maxRecordDurationPolicy
```

Stop with decision

```swift
VoiceRecorder.shared.stopRecording(policy: .userChoice)
```

Stop and send immediately

```swift
VoiceRecorder.shared.stopRecording(policy: .sendImmediately)
```

Stop and cancel sending

```swift
VoiceRecorder.shared.stopRecording(policy: .cancel)
```
