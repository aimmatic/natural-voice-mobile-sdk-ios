import Quick
import Nimble
import NaturalVoice

class Tests: QuickSpec {
    
    override func spec() {
        context("Strategy") {
            beforeEach {
                VoiceRecordStrategy.apiKey = ""
                VoiceRecordStrategy.language = nil
                VoiceRecordStrategy.maxRecordDuration = 65
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
    }
}
