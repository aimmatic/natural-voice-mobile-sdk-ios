//
//  VoiceLanguageManager.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/10/18.
//

import Alamofire

open class VoiceLanguageManager {
    
    fileprivate static let instance = VoiceLanguageManager()
    fileprivate var embededLanguages: [VoiceLanguage] = []
    fileprivate var languages: [VoiceLanguage] = []
    
    open static var shared: VoiceLanguageManager {
        return self.instance
    }
    
    init() {
        let allLangs = "Deutsch (Deutschland),German (Germany),de-DE,de\n" +
            "English (United States),English (United States),en-US,en\n" +
            "English (Philippines),English (Philippines),en-PH,en\n" +
            "English (Australia),English (Australia),en-AU,en\n" +
            "English (Canada),English (Canada),en-CA,en\n" +
            "English (Ghana),English (Ghana),en-GH,en\n" +
            "English (Great Britain),English (United Kingdom),en-GB,en\n" +
            "English (India),English (India),en-IN,en\n" +
            "English (Ireland),English (Ireland),en-IE,en\n" +
            "English (Kenya),English (Kenya),en-KE,en\n" +
            "English (New Zealand),English (New Zealand),en-NZ,en\n" +
            "English (Nigeria),English (Nigeria),en-NG,en\n" +
            "English (South Africa),English (South Africa),en-ZA,en\n" +
            "English (Tanzania),English (Tanzania),en-TZ,en\n" +
            "Español (Argentina),Spanish (Argentina),es-AR,es\n" +
            "Español (Bolivia),Spanish (Bolivia),es-BO,es\n" +
            "Español (Chile),Spanish (Chile),es-CL,es\n" +
            "Español (Colombia),Spanish (Colombia),es-CO,es\n" +
            "Español (Costa Rica),Spanish (Costa Rica),es-CR,es\n" +
            "Español (Ecuador),Spanish (Ecuador),es-EC,es\n" +
            "Español (El Salvador),Spanish (El Salvador),es-SV,es\n" +
            "Español (España),Spanish (Spain),es-ES,es\n" +
            "Español (Estados Unidos),Spanish (United States),es-US,es\n" +
            "Español (Guatemala),Spanish (Guatemala),es-GT,es\n" +
            "Español (Honduras),Spanish (Honduras),es-HN,es\n" +
            "Español (México),Spanish (Mexico),es-MX,es\n" +
            "Español (Nicaragua),Spanish (Nicaragua),es-NI,es\n" +
            "Español (Panamá),Spanish (Panama),es-PA,es\n" +
            "Español (Paraguay),Spanish (Paraguay),es-PY,es\n" +
            "Español (Perú),Spanish (Peru),es-PE,es\n" +
            "Español (Puerto Rico),Spanish (Puerto Rico),es-PR,es\n" +
            "Español (República Dominicana),Spanish (Dominican Republic),es-DO,es\n" +
            "Español (Uruguay),Spanish (Uruguay),es-UY,es\n" +
            "Español (Venezuela),Spanish (Venezuela),es-VE,es\n" +
            "Français (France),French (France),fr-FR,fr\n" +
            "Français (Canada),French (Canada),fr-CA,fr\n" +
            "Italiano (Italia),Italian (Italy),it-IT,it\n" +
            "日本語（日本）,Japanese (Japan),ja-JP,ja\n" +
            "한국어 (대한민국),Korean (South Korea),ko-KR,ko\n" +
            "Português (Brasil),Portuguese (Brazil),pt-BR,pt\n" +
            "Português (Portugal),Portuguese (Portugal),pt-PT,pt\n" +
            "普通話 (香港),\"Chinese, Mandarin (Simplified Hong Kong)\",cmn-Hans-HK,zh\n" +
            "普通话 (中国大陆),\"Chinese, Mandarin (Simplified China)\",cmn-Hans-CN,zh\n" +
            "廣東話 (香港),\"Chinese, Cantonese (Traditional Hong Kong)\",yue-Hant-HK,zh-Hant\n" +
            "國語 (台灣),\"Chinese, Mandarin (Traditional Taiwan)\",cmn-Hant-TW,zh-Hant";
        let eachLines = allLangs.components(separatedBy: "\n")
        eachLines.forEach {
            let columns = $0.components(separatedBy: ",")
            let language = VoiceLanguage(displayLang: columns[0],
                                         langEn: columns[1],
                                         bcp47Code: columns[2],
                                         langCode: columns[3])
            self.embededLanguages.append(language)
        }
        self.languages = self.embededLanguages
    }
    
    open func getLanguage(bcp47Code: String) -> VoiceLanguage? {
        let languages = self.languages.filter {
            $0.bcp47Code.lowercased() == bcp47Code.lowercased() ||
            $0.langCode.lowercased() == bcp47Code.lowercased()
        }
        return languages.first
    }
    
    open func getSupportLanguages(completion: (([VoiceLanguage]) -> Void)?) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .allDomainsMask)
        let url = urls[0].appendingPathComponent("languages.json")
        if false == fileManager.fileExists(atPath: url.path) {
            do {
                let dictionary = ["lang": []]
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        self.getRemoteLanguages(fileUrl: url, completion: completion)
    }
    
    func getRemoteLanguages(fileUrl: URL, completion: (([VoiceLanguage]) -> Void)?) {
        
        guard let apiKey = VoiceResource.apiKey, apiKey != "" else {
            let description = VoiceResource.apiKeyDescription
            let message = "ApiKey is invalid, please add key \(description) with valid apikey value in Info.plist."
            preconditionFailure(message)
        }
        
        let urlString = VoiceResource.host + VoiceResource.apiVersion + VoiceResource.naturalVoiceLanguage
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.addValue("AimMatic \(apiKey)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .useProtocolCachePolicy
            request.timeoutInterval = 60
            Alamofire.request(request).responseJSON { response in
                if let data = response.data,
                    let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                    let lang = dictionary,
                    let dictionaries = lang["lang"] as? [NSDictionary] {
                    let languages = self.saveLanguages(fileUrl: fileUrl, dictionaries: dictionaries)
                    if 0 != languages.count {
                        self.languages = languages
                    }
                    completion?(self.languages)
                } else {
                    completion?(self.languages)
                }
            }
        } else {
            completion?(self.languages)
        }
    }
    
    func saveLanguages(fileUrl: URL, dictionaries: [NSDictionary]) -> [VoiceLanguage] {
        let dictionary = ["lang": dictionaries]
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            try data.write(to: fileUrl, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        return self.mappingLanguage(dictionaries: dictionaries)
    }
    
    func mappingLanguage(dictionaries: [NSDictionary]) -> [VoiceLanguage] {
        let languages = dictionaries.reduce([]) { ( result, object) -> [VoiceLanguage] in
            var result = result
            if let name = object["name"] as? String,
                let fullname = object["fullname"] as? String,
                let speechlang = object["speechlang"] as? String,
                let nlplang = object["nlplang"] as? String {
                let language = VoiceLanguage(displayLang: name, langEn: fullname, bcp47Code: speechlang, langCode: nlplang)
                result.append(language)
            }
            return result
        }
        return languages
    }
}
