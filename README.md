# Natural Voice Mobile SDK For iOS #

This library allows you to integrate Natural Voice functions into your iOS app.

Requires API key. For a free API key you may contact our solution desk.

https://www.aimmatic.com/solution-desk.html

mailto:solution.desk@aimmatic.com

Please allow a few hours for a response.

# Feature #

Example:
- [Natural Voice Mobile](http://www.aimmatic.com/natural-voice.html)

# Usage #

## Cocoapods ##

```gradle
pod 'NaturalVoice'
```

## Install ##

```gradle
pod install
```

## Info.plist ##

Natural Voice requires location service and microphone permission, you need to add these keys to Info.plist

```info.plist
<key>NSMicrophoneUsageDescription</key>
<string></string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string></string>
<key>NSLocationWhenInUseUsageDescription</key>
<string></string>
```

## Using Voice Service ##

### Get supported languages ###

```languages
let supportedLanguages = AudioLanguageManager.shared.supportLanguages
```

### Configuration ###

```configuration
VoiceRecordStrategy.apiKey = "Your Api Key"
VoiceRecordStrategy.language = language
VoiceRecordStrategy.maxRecordDuration = 30
VoiceRecordStrategy.maxRecordDurationPolicy = .sendImmediately
```

### Start recording ###

```startrecording
VoiceRecorder.shared.startRecording(recordStarted: { meta in

}, recordEnded: { response in

}, recordSent: { response in

}, recordFailed: { error in

})
```

### Stop recording ###

Stop with decision

```stoprecording
VoiceRecorder.shared.stopRecording(policy: .userChoice)
```

Stop and send immediately

```stoprecording
VoiceRecorder.shared.stopRecording(policy: .sendImmediately)
```

Stop and cancel sending

```stoprecording
VoiceRecorder.shared.stopRecording(policy: .cancel)
```