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
    enum Addresses {
        /**
         Response:
         - Node.Model.AccountBalance.self
         */
        case getAccountBalance(id: String)
    }
}

extension Node.Service.Addresses: NodeTargetType {
    fileprivate enum Constants {
        static let addresses = "addresses"
        static let balance = "balance"
    }

    var path: String {
        switch self {
        case .getAccountBalance(let id):
            return Constants.addresses + "/" + Constants.balance + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAccountBalance:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getAccountBalance:
            return .requestPlain
        }
    }
}
