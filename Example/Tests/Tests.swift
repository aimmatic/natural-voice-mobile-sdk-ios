import Quick
import Nimble
import NaturalVoice

class Tests: QuickSpec {
    
    override func spec() {
        
        var language: VoiceLanguage?
        
        context("Strategy") {
            
            beforeEach {
                language = VoiceLanguageManager.shared.getLanguage(bcp47Code: "en-US")
            }
            
            it("Language") {
                expect(language).toNot(beNil())
            }
        }
    }
}
