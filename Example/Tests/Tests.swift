import Quick
import Nimble
import NaturalVoice

class Tests: QuickSpec {
    
    override func spec() {
        context("Strategy") {
            beforeEach {
                VoiceRecordStrategy.apiKey = "Your Api Key"
                VoiceRecordStrategy.language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
                VoiceRecordStrategy.maxRecordDuration = 30
                VoiceRecordStrategy.maxRecordDurationPolicy = .sendImmediately
            }
            it("ApiKey") {
                expect(VoiceRecordStrategy.apiKey) != ""
            }
            it("Language") {
                expect(VoiceRecordStrategy.language).toNot(beNil())
            }
            it("MaxRecordDuration") {
                expect(VoiceRecordStrategy.maxRecordDuration) <= 60
            }
        }
        
        context("Language") {
            
            var languages: [VoiceLanguage] = []
            var language: VoiceLanguage?
            
            beforeEach {
                languages = VoiceLanguageManager.shared.supportLanguages
                language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
            }
            
            it("Count") {
                expect(languages.count).toNot(equal(0))
            }
            
            it("Language") {
                expect(language).toNot(beNil())
            }
        }
    }
}
