//
//  EnvironmentService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

//TODO: Rename
enum GitHub {}

extension GitHub {
    enum Service {}
    enum DTO {}
}

private enum Constants {

    
    static let root = "https://configs-waves-exchange.s3.eu-central-1.amazonaws.com"
    
    static let urlEnvironmentStageNetTest: URL = URL(string: "\(root)/mobile/environment/test/stagenet.json")!
    
    static let urlEnvironmentMainNetTest: URL = URL(string: "\(root)/mobile/environment/test/mainnet.json")!
    
    static let urlEnvironmentTestNetTest: URL = URL(string:"\(root)/mobile/environment/test/testnet.json")!
        
    static let urlEnvironmentStageNet: URL = URL(string: "\(root)/mobile/environment/prod/testnet.json")!
    
    static let urlEnvironmentMainNet: URL = URL(string: "\(root)/mobile/environment/prod/mainnet.json")!
    
    static let urlEnvironmentTestNet: URL = URL(string:"\(root)/mobile/environment/prod/testnet.json")!
        
    static let urlTransactionFee: URL = URL(string: "\(root)/fee.json")!
        
    static let urlApplicationNews: URL = URL(string: "\(root)/mobile/ios/prod/notifications.json")!
    
    static let urlApplicationNewsDebug: URL = URL(string:"\(root)/mobile/ios/test/notifications.json")!
    
    static let urlVersionIos: URL = URL(string: "\(root)/mobile/ios/prod/version.json")!
        
    static let urlVersionIosTest: URL = URL(string: "\(root)/mobile/ios/test/version.json")!
}

extension GitHub.Service {

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
}

extension GitHub.Service.Environment: TargetType {
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

extension GitHub.Service.TransactionRules: TargetType {
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

extension GitHub.Service.ApplicationNews: TargetType {
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

extension GitHub.Service.ApplicationVersion: TargetType {
    var sampleData: Data {
        return Data()
    }
    
    var baseURL: URL {
        switch self {
        case .get(let isDebug):
            if isDebug {
                return Constants.urlVersionIosTest
            } else {
                return Constants.urlVersionIos
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
