//
//  VoiceSender.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/9/18.
//

import UIKit
import Alamofire

class VoiceSender: NSObject {
    
    func sendVoice(file: VoiceFile, loc: VoiceLocation, meta: VoiceFileMeta, sent: VoiceRecordSent?) {
        if "" != VoiceRecordStrategy.apiKey {
            if let language = VoiceRecordStrategy.language {
                let headers = ["Authorization": "AimMatic \(VoiceRecordStrategy.apiKey)"]
                let threshold = SessionManager.multipartFormDataEncodingMemoryThreshold
                let url = VoiceResource.host + VoiceResource.apiVersion + VoiceResource.naturalVoice
                let language = language.bcp47Code
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
                            self.responseSussess(message: "Success", data: response.result.value, sent: sent)
                            self.remove(url: audioUrl!)
                        }
                        break
                    case .failure(let error):
                        self.responseFailed(message: error.localizedDescription, sent: sent)
                        self.remove(url: audioUrl!)
                        break
                    }
                })
            } else {
                self.responseFailed(message: reponseMessageInvalidLanguage, sent: sent)
                self.remove(url: file.fileUrl)
            }
        } else {
            self.responseFailed(message: reponseMessageInvalidApiKey, sent: sent)
            self.remove(url: file.fileUrl)
        }
    }
    
    fileprivate func responseFailed(message: String, sent: VoiceRecordSent?) {
        let result = VoiceRecordResponseResult(message: message, data: nil)
        let status = VoiceRecordResponseStatus.failure
        let error = NSError(domain: message, code: 0, userInfo: nil)
        let response = VoiceRecordResponse(result: result, status: status, error: error)
        sent?(response)
    }
    
    fileprivate func responseSussess(message: String, data: Data?, sent: VoiceRecordSent?) {
        let result = VoiceRecordResponseResult(message: message, data: data)
        let status = VoiceRecordResponseStatus.success
        let response = VoiceRecordResponse(result: result, status: status, error: nil)
        sent?(response)
    }
    
    fileprivate func encode(string: String) -> Data {
        return string.data(using: .utf8)!
    }
    
    fileprivate func remove(url: URL) {
        if true == FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch { }
        }
    }
}
