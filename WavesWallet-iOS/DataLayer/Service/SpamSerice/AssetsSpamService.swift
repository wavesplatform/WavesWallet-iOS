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
         - Node.Model.AccountBalance.self
         */
        case getSpamList
    }
}

extension Spam.Service.Assets: SpamTargetType {

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch self {
        case .getSpamList:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getSpamList:
            return .requestPlain
        }
    }
}
