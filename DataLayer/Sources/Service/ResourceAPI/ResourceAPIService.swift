//
//  EnvironmentService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

//TODO: Rename
enum ResourceAPI {}

extension ResourceAPI {
    enum Service {}
    enum DTO {}
}

private enum Constants {
    
    static let root = "https://configs.waves.exchange/"
    
    static let urlEnvironmentStageNetTest: URL = URL(string: "\(root)/mobile/environment/test/stagenet.json")!
    
    static let urlEnvironmentMainNetTest: URL = URL(string: "\(root)/mobile/environment/test/mainnet.json")!
    
    static let urlEnvironmentTestNetTest: URL = URL(string:"\(root)/mobile/environment/test/testnet.json")!
        
    static let urlEnvironmentStageNet: URL = URL(string: "\(root)/mobile/environment/prod/stagenet.json")!
    
    static let urlEnvironmentMainNet: URL = URL(string: "\(root)/mobile/environment/prod/mainnet.json")!
    
    static let urlEnvironmentTestNet: URL = URL(string:"\(root)/mobile/environment/prod/testnet.json")!
        
    static let urlTransactionFee: URL = URL(string: "\(root)/fee.json")!
        
    static let urlApplicationNews: URL = URL(string: "\(root)/mobile/ios/prod/notifications.json")!
    
    static let urlApplicationNewsDebug: URL = URL(string:"\(root)/mobile/ios/test/notifications.json")!
    
    static let urlVersion: URL = URL(string: "\(root)/mobile/ios/prod/version.json")!
        
    static let urlVersionTest: URL = URL(string: "\(root)/mobile/ios/test/version.json")!
    
    static let urlDevelopmentConfigs: URL = URL(string: "\(root)/mobile/ios/prod/development_configs.json")!
        
    static let urlDevelopmentConfigsTest: URL = URL(string: "\(root)/mobile/ios/test/development_configs.json")!

    static let urlTradeCategoriesConfig: URL = URL(string: "\(root)/mobile/ios/prod/trade_categories_config.json")!
    
    static let urlTradeCategoriesConfigTest: URL = URL(string: "\(root)/mobile/ios/test/trade_categories_config.json")!
}

extension ResourceAPI.Service {

    enum Environment {
        
        enum Kind {
            case mainnet
            case testnet
            case stagenet
        }
        /**
         Response:
         - Environment
         */
        case get(kind: Kind, isDebug: Bool)
    }

    enum TransactionRules {
        /**
         Response:
         - ?
         */
        case get
    }

    enum ApplicationNews {
        /**
         Response:
         - ?
         */
        case get(isDebug: Bool)
    }
    
    enum ApplicationVersion {
        /**
         Response:
         - ?
         */
        case get(isDebug: Bool)
    }
    
    enum DevelopmentConfigs {
        /**
         Response:
         - ?
         */
        case get(isDebug: Bool)
    }
    

    enum TradeCategoriesConfig {
    
        case get(isDebug: Bool)
    }
}

extension ResourceAPI.Service.Environment: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let kind, let isDebug):
            
            switch kind {
            case .mainnet:
                if isDebug {
                    return Constants.urlEnvironmentMainNetTest
                } else {
                    return Constants.urlEnvironmentMainNet
                }
            case .testnet:
                if isDebug {
                    return Constants.urlEnvironmentTestNetTest
                } else {
                    return Constants.urlEnvironmentTestNet
                }
                
            case .stagenet:
                if isDebug {
                    return Constants.urlEnvironmentStageNetTest
                } else {
                    return Constants.urlEnvironmentStageNet
                }
            }
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
}

extension ResourceAPI.Service.TransactionRules: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get:
            return Constants.urlTransactionFee
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return  ["Content-type": "application/json"]
    }

    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }

}

extension ResourceAPI.Service.ApplicationNews: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let isDebug):
            if isDebug {
                return Constants.urlApplicationNewsDebug
            } else {
                return Constants.urlApplicationNews
            }
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return  ["Content-type": "application/json"]
    }

    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
}

extension ResourceAPI.Service.DevelopmentConfigs: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let isDebug):
            if isDebug {
                return Constants.urlDevelopmentConfigsTest
            } else {
                return Constants.urlDevelopmentConfigs
            }
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return  ["Content-type": "application/json"]
    }

    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
}

extension ResourceAPI.Service.ApplicationVersion: TargetType {
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        switch self {
        case .get(let isDebug):
            if isDebug {
                return Constants.urlVersionTest
            } else {
                return Constants.urlVersion
            }
        }
    }
    
    var path: String {
        return ""
    }
    
    var headers: [String: String]? {
        return  ["Content-type": "application/json"]
    }
    
    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
    
}


extension ResourceAPI.Service.TradeCategoriesConfig: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        switch self {
        case .get(let isDebug):
            if isDebug {
                return Constants.urlTradeCategoriesConfigTest
            }
            
            return Constants.urlTradeCategoriesConfig
        }
    }
    
    var path: String {
        return ""
    }
    
    var headers: [String: String]? {
        return  ["Content-type": "application/json"]
    }
   
    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }
   
    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
}

// MARK: CachePolicyTarget

extension ResourceAPI.Service.Environment: CachePolicyTarget {
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
}
