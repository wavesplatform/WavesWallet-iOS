//
//  AssetsSpamService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Spam.Service {
    enum Assets {
        /**
         Response:
         - CSV
         */
        case getSpamListByUrl(url: URL)
    }
}

extension Spam.Service.Assets: TargetType {

    var baseURL: URL {

        switch self {
        case .getSpamListByUrl(let url):
            return url
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/csv"]
    }

    var sampleData: Data {
        return Data()
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }
}
