//
//  NodeAddressesService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {

    struct Addresses {
        enum Kind {
            /**
             Response:
             - Node.Model.AccountBalance.self
             */
            case getAccountBalance(id: String)

            /**
             Response:
             - DomainLayer.DTO.AddressScriptInfo
             */
            case scriptInfo(id: String)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Node.Service.Addresses: NodeTargetType {
    fileprivate enum Constants {
        static let addresses = "addresses"
        static let balance = "balance"
        static let scriptInfo = "scriptInfo"
    }

    var path: String {
        switch kind {
        case .getAccountBalance(let id):
            return Constants.addresses + "/" + Constants.balance + "/" + "\(id)".urlEscaped

        case .scriptInfo(let id):
            return Constants.addresses + "/" + Constants.scriptInfo + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAccountBalance, .scriptInfo:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getAccountBalance, .scriptInfo:
            return .requestPlain
        }
    }
}
