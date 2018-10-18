//
//  APIType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {
    var environment: Environment { get }
 }

//extension BaseTargetType {
//    var environment: Environment {
//        return Environments.Mainnet
//    }
//}

enum ContentType {
    case applicationJson
    case applicationCsv
}

extension ContentType {
    var headers: [String: String] {
        switch self {
        case .applicationCsv:
            return ["Content-type": "application/csv"]
        case .applicationJson:
            return ["Content-type": "application/json"]
        }
    }
}


extension BaseTargetType {

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
}
