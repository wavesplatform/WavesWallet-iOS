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
    static let urlEnvironmentMainNet: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.3/environment_mainnet.json")!
    static let urlEnvironmentTestNet: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.3/environment_testnet.json")!
    static let urlTransactionFee: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/master/fee.json")!
    static let urlApplicationNews: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-client-config/mobile/v2.2/notifications_ios.json")!
}

extension GitHub.Service {

    enum Environment {
        /**
         Response:
         - Environment
         */
        case get(isTestNet: Bool)
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
        case get
    }
}

extension GitHub.Service.Environment: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case .get(let isTestNet):
            if isTestNet {
                return Constants.urlEnvironmentTestNet
            } else {
                return Constants.urlEnvironmentMainNet
            }
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return ContentType.applicationJson.headers
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
        return ContentType.applicationJson.headers
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
        case .get:
            return Constants.urlApplicationNews
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return ContentType.applicationJson.headers
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
