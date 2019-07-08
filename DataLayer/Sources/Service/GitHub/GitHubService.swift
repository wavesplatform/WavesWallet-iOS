//
//  EnvironmentService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

enum GitHub {}

extension GitHub {
    enum Service {}
    enum DTO {}
}

private enum Constants {

    
    static let urlEnvironmentMainNet: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/mobile/v2.5/environment_mainnet.json")!
    
    static let urlEnvironmentTestNet: URL = URL(string:
        "https://raw.githubusercontent.com/wavesplatform/waves-client-config/mobile/v2.5/environment_testnet.json")!
    
    static let urlTransactionFee: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/master/fee.json")!
    
    static let urlApplicationNews: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/mobile/v2.5/notifications_ios.json")!
    
    static let urlVersionIos: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/master/version_ios.json")!
        
    static let urlEnvironmentMainNetProxy: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.5/environment_mainnet.json")!
    
    static let urlEnvironmentTestNetProxy: URL = URL(string:
        "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.5/environment_testnet.json")!
    
    static let urlTransactionFeeProxy: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/master/fee.json")!
    
    static let urlApplicationNewsProxy: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.5/notifications_ios.json")!
    
    static let urlVersionIosProxy: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/master/version_ios.json")!

    static let urlApplicationNewsDebug: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/mobile/v2.5/notifications_test_ios.json")!
}

extension GitHub.Service {

    enum Environment {
        /**
         Response:
         - Environment
         */
        case get(isTestNet: Bool, hasProxy: Bool)
    }

    enum TransactionRules {
        /**
         Response:
         - ?
         */
        case get(hasProxy: Bool)
    }

    enum ApplicationNews {
        /**
         Response:
         - ?
         */
        case get(isDebug: Bool, hasProxy: Bool)
    }
    
    enum ApplicationVersion {
        /**
         Response:
         - ?
         */
        case get(hasProxy: Bool)
    }
}

extension GitHub.Service.Environment: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let isTestNet, let hasProxy):
            if isTestNet {
                if hasProxy {
                    return Constants.urlEnvironmentTestNetProxy
                } else {
                    return Constants.urlEnvironmentTestNet
                }
            } else {
                if hasProxy {
                    return Constants.urlEnvironmentMainNetProxy
                } else {
                    return Constants.urlEnvironmentMainNet
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
        case .get(let hasProxy):
            if hasProxy {
                return Constants.urlTransactionFeeProxy
            } else {
                return Constants.urlTransactionFee
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

extension GitHub.Service.ApplicationNews: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let isDebug, let hasProxy):
            
            if isDebug {
                return Constants.urlApplicationNewsDebug
            } else {
                if hasProxy {
                    return Constants.urlApplicationNewsProxy
                } else {
                    return Constants.urlApplicationNews
                }
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
        case .get:
            return Constants.urlVersionIos
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
