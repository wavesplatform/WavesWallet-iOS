//
//  WEOAuthService.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

enum WEOAuth {
    enum Service {
        case token(baseURL: URL, token: WEOAuth.Query.Token)
    }
    
    enum Query {}
}

extension WEOAuth.Query {
   
    struct Token: Codable {
//        let token: String
        let username: String
        let password: String
        let grantType: String
        let scope: String
        
        private enum CodingKeys: String, CodingKey {
            case username
            case password
            case grantType = "grant_type"
            case scope
        }
    }
}

extension WEOAuth.Service: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        
        switch self {
        case .token(let baseURL, _):
            return baseURL
        }
    }
    
    var path: String {
        switch self {
        case .token:
            return "v1/oauth2/token"
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = .init()
        
//        switch self {
//        case .token(_, let token):
////            headers["Authorization"] = token.token
//        }
        
        return headers
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .token(_, let token):
            return .requestParameters(parameters: token.dictionary, encoding: URLEncoding.default)
        }
    }
}
