//
//  AssetsSpamService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

private enum Constants {
    
    static let urlSpam: URL = URL(string:
        "https://raw.githubusercontent.com/wavesplatform/waves-community/master/Scam%20tokens%20according%20to%20the%20opinion%20of%20Waves%20Community.csv")!
    
    static let urlSpamProxy: URL = URL(string:
        "https://github-proxy.wvservices.com/wavesplatform/waves-community/master/Scam%20tokens%20according%20to%20the%20opinion%20of%20Waves%20Community.csv")!
}

    
extension Spam.Service {
    enum Assets {
        /**
         Response:
         - CSV
         */
        case getSpamList(hasProxy: Bool)
        case getSpamListByUrl(url: URL)
    }
}

extension Spam.Service.Assets: TargetType {

    var baseURL: URL {

        switch self {
        case .getSpamList(let hasProxy):
            if hasProxy {
                return Constants.urlSpamProxy
            } else {
                return Constants.urlSpam
            }
        case .getSpamListByUrl(let url):
            return url
        }
    }

    var headers: [String: String]? {
        return ContentType.applicationCsv.headers
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
