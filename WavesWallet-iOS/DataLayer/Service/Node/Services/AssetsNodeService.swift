//
//  NodeAssetsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {

    struct Assets {
        enum Kind {
            /**
             Response:
             - [Node.Model.AccountAssetsBalance].self
             */
            case getAssetsBalance(walletAddress: String)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Node.Service.Assets: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let assets = "assets"
        static let balance = "balance"
    }

    var path: String {
        switch kind {
        case .getAssetsBalance(let id):
            return Constants.assets + "/" + Constants.balance + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAssetsBalance:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getAssetsBalance:
            return .requestPlain
        }
    }
}
