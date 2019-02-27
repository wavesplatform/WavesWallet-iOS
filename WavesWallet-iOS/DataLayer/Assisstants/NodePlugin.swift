//
//  NodePlugin.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Result
import Moya

private struct NodeHeaders: Encodable, Decodable, TSUD {
    
    var cflb: String?
    var awsalb: String?
    
    private static let key: String = "com.waves.plugin.node"
    
    static var defaultValue: NodeHeaders {
        return NodeHeaders(cflb: nil, awsalb: nil)
    }
    
    static var stringKey: String {
        return NodeHeaders.key
    }
}

private enum Constants {
    static let cflbKey = "__cflb"
    static let awsalbKey = "AWSALB"
    static let nameQueue = "NodePlugin.lockQueue"
}

struct NodePlugin: PluginType {
    
    private let lockQueue = DispatchQueue(label: Constants.nameQueue)
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest { return request }
    
    func willSend(_ request: RequestType, target: TargetType) {}
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        guard let response = result.value?.response else { return }
        
        guard let allHeaderFields = response.allHeaderFields as? [String : String] else { return }
        guard let url = response.url else { return }
        
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
        var cflb: String? = nil
        var awsalb: String? = nil
        
        for cookie in cookies {
            if cookie.name == Constants.cflbKey {
                cflb = cookie.value
            }
            
            if cookie.name == Constants.awsalbKey {
                awsalb = cookie.value
            }
        }
        
        let newHeaders = NodeHeaders(cflb: cflb, awsalb: awsalb)
        
        lockQueue.sync {
            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
            NodeHeaders.set(newHeaders)
        }
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        return result
    }
}
