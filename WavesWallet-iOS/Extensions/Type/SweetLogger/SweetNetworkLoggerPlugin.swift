//
//  SweetNetworki.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Result
import Moya

public final class SweetNetworkLoggerPlugin: PluginType {

    public func willSend(_ request: RequestType, target: TargetType) {}

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        var message: String? = nil
        
        switch result {
        case .failure(let error):
            if case .underlying(let error, _) = error,
                (error as NSError).code == NSURLErrorCancelled {
                return
            }
            
            message = error.message
        case .success(let value):
            message = value.message
        }
        
        guard let unwrapMessage = message else { return }
    
        let event = SentryManager.Event(level: .error)
        event.tags = ["test": "value"]
        event.message = unwrapMessage
        SentryManager.send(event: event)
    }
}

private extension Moya.Response {
    
    var message: String? {
        
        var message: String = ""
        
        guard let response = self.response else { return nil }
        guard let request = self.request else { return nil }
        guard let url = self.request?.url?.path else { return nil }
        
        message += "Url: \(url)\n"
        message += "Code: \(response.statusCode)\n"
        
        if let data = request.httpBody,
            let response = String(data: data, encoding: .utf8) {
            message += "Message: \(response)\n"
        }
                
        message += "Code: \(response.statusCode)\n"
        
        return message
    }
}

private extension MoyaError {
    
    var message: String? {
        
        var message: String = ""
   
        if let errorDescription = self.errorDescription {
            message += "Error: \(errorDescription)\n"
        }
        
        if let response = self.response,
            let request = response.request,
            let url = request.url {
            
            message += "Url: \(url.path)\n"
            message += "Code: \(response.statusCode)\n"
            
            if let response = try? response.mapString() {
                message += "Message: \(response)\n"
            }
        } else if case .underlying(let error, _) = self {
            let code = (error as NSError).code
            message += "Code: \(code)\n"
        }
        
        return message
    }
}
