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
    struct Assets {
        enum Kind {
            /**
             Response:
             - Node.Model.AccountBalance.self
             */
            case getSpamList
        }

        let kind: Kind
        let environment: Environment
    }
}

extension Spam.Service.Assets: SpamTargetType {

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch kind {
        case .getSpamList:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getSpamList:
            return .requestPlain
        }
    }
}
