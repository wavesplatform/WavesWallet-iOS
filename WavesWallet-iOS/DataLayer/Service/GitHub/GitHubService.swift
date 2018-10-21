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
}

private enum Constants {
    static let urlEnvironmentMainNet: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/master/environment_mainnet.json")!
    static let urlEnvironmentTestNet: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-client-config/master/environment_testnet.json")!
}

extension GitHub.Service {

        enum Environment {
            /**
             Response:
             - Environment
             */
            case get(isTestNet: Bool)
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
