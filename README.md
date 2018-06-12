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

Get supported languages

```languages
let supportedLanguages = AudioLanguageManager.shared.supportLanguages
```

Configuration

```configuration
AudioConfiguraiton.apiKey = ""
AudioConfiguraiton.language = language
AudioConfiguraiton.recordMaxSecond = 60
```

Start recording

```startrecording
AudioRecorder.shared.startRecording(start: { meta in

}, end: { state in
        
}, sent: { response in
        
}, failed: { error in

})
```

Stop recording

```stoprecording
AudioRecorder.shared.stopRecording(state: .endByUser)
```

