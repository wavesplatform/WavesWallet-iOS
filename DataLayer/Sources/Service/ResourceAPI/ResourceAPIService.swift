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
import DomainLayer

// TODO: Rename
enum ResourceAPI {}

extension ResourceAPI {
    enum Service {}
    enum DTO {}
}

private enum Constants {
    static let root = "https://configs.waves.exchange/"

//    static let urlEnvironmentStageNetTest: URL = URL(string: "\(root)/mobile/v2/environment/test/stagenet.json")!
//
//    static let urlEnvironmentMainNetTest: URL = URL(string: "\(root)/mobile/v2/environment/test/mainnet.json")!
//
//    static let urlEnvironmentTestNetTest: URL = URL(string: "\(root)/mobile/v2/environment/test/testnet.json")!
//
//    static let urlEnvironmentStageNet: URL = URL(string: "\(root)/mobile/v2/environment/prod/stagenet.json")!
//
//    static let urlEnvironmentMainNet: URL = URL(string: "\(root)/mobile/v2/environment/prod/mainnet.json")!
//
//    static let urlEnvironmentTestNet: URL = URL(string: "\(root)/mobile/v2/environment/prod/testnet.json")!

    static let urlTransactionFee: URL = URL(string: "\(root)/fee.json")!

    static let urlApplicationNews: URL = URL(string: "\(root)/mobile/v2/ios/prod/notifications.json")!

    static let urlApplicationNewsDebug: URL = URL(string: "\(root)/mobile/v2/ios/test/notifications.json")!

    static let urlVersion: URL = URL(string: "\(root)/mobile/v2/ios/prod/version.json")!

    static let urlVersionTest: URL = URL(string: "\(root)/mobile/v2/ios/test/version.json")!
    
    

    static let urlDevelopmentConfigs: URL = URL(string: "\(root)/mobile/ios/prod/development_configs.json")!

    static let urlDevelopmentConfigsTest: URL = URL(string: "\(root)/mobile/ios/test/development_configs.json")!
    
    

    static let urlTradeCategoriesConfig: URL = URL(string: "\(root)/mobile/ios/prod/trade_categories_config.json")!

    static let urlTradeCategoriesConfigTest: URL = URL(string: "\(root)/mobile/ios/test/trade_categories_config.json")!
}

private extension URL {
    static func configURL(isTest: Bool,
                          enviromentScheme: String,
                          configName: String) -> URL {
        var path = "\(Constants.root)"
        path += "mobile/v2/"
        path += "\(configName)/"
        if isTest {
            path += "test/"
        } else {
            path += "prod/"
        }
        
        path += "\(enviromentScheme).json"
                        
        return URL(string: path)!
    }
}

extension WalletEnvironment.Kind {
    
    var enviromentScheme: String {
        switch self {
        case .mainnet:
            return "mainnet"
        case .stagenet:
            return "stagenet"
        case .testnet:
            return "testnet"
        }
    }
}

extension ResourceAPI.Service {

    enum Environment {

        /**
         Response:
         - Environment
         */
        case get(kind: WalletEnvironment.Kind, isTest: Bool)
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
        
        case get(isTest: Bool, kind: WalletEnvironment.Kind)
    }
}

extension ResourceAPI.Service.Environment: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(kind, isTest):
            
            return URL.configURL(isTest: isTest,
                                 enviromentScheme: kind.enviromentScheme,
                                 configName: "environment")
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

extension ResourceAPI.Service.ApplicationNews: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(isDebug):
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

extension ResourceAPI.Service.DevelopmentConfigs: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(isDebug):
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

extension ResourceAPI.Service.ApplicationVersion: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(isDebug):
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

extension ResourceAPI.Service.TradeCategoriesConfig: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(isTest, kind):
            
            return URL.configURL(isTest: isTest,
                                 enviromentScheme: kind.enviromentScheme,
                                 configName: "trade_categories_config")
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

// MARK: CachePolicyTarget

extension ResourceAPI.Service.Environment: CachePolicyTarget {
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
}
