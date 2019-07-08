//
//  LeasingNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtension
import WavesSDKCrypto

extension Node.Service {

    struct Leasing {
        enum Kind {
            /**
             Response:
             - [Node.Model.LeasingTransaction].self
             */
            case getActive(accountAddress: String)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Node.Service.Leasing: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let leasing = "leasing"
        static let active = "active"
        static let address = "address"
    }

    var path: String {
        switch kind {
        case .getActive(let accountAddress):
            return Constants.leasing + "/" + Constants.active + "/" + "\(accountAddress)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getActive:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getActive:
            return .requestPlain
        }
    }
}
