//
//  VoiceSender.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import UIKit
import Alamofire

typealias VoiceSenderResult = ((Data?, Error?) -> Void)

class VoiceSender: NSObject {
    
    func sendFile(file: VoiceFile, loc: VoiceLocation, meta: VoiceFileMeta, result: VoiceSenderResult?) {
        let headers = ["Authorization": "AimMatic \(VoiceResource.apiKey!)"]
        let threshold = SessionManager.multipartFormDataEncodingMemoryThreshold
        let url = VoiceResource.host + VoiceResource.apiVersion + VoiceResource.naturalVoice
        let language = VoiceRecordStrategy.language!.bcp47Code
        let audioUrl = file.fileUrl
        let mimeType = file.fileType.mediaType
        let fileName = file.fileUrl.lastPathComponent
        Alamofire.upload(multipartFormData: { formData in
            formData.append(audioUrl!, withName: "uploadFile", fileName: fileName, mimeType: mimeType)
            formData.append(self.encode(string: language),
                            withName: "deviceLanguage")
            formData.append(self.encode(string: "\(meta.sampleRate)"),
                            withName: "sampleRate")
            if loc.lat != 0 && loc.lng != 0 {
                formData.append(self.encode(string: "\(loc.lat),\(loc.lng)"),
                                withName: "deviceLocation")
            }
        }, usingThreshold: threshold, to: url, method: .post, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData { response in
                    if let data = response.result.value {
                        result?(data, nil)
                    } else {
                        result?(nil, response.result.error)
                    }
                }
                break
            case .failure(let error):
                result?(nil, error)
                break
            }
        })
    }
    
    fileprivate func encode(string: String) -> Data {
        return string.data(using: .utf8)!
    }
}
