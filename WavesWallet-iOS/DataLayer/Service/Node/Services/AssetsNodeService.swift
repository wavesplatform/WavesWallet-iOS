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
             - [Node.Model.AccountAssetsBalance]
             */
            case getAssetsBalances(walletAddress: String)

            /**
             Response:
             - [Node.Model.AccountAssetsBalance]
             */
            case getAssetsBalance(address: String, assetId: String)

            /**
             Response:
             - Node.DTO.AssetDetail
             */
            case details(assetId: String)
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
        static let details = "details"
    }

    var path: String {
        switch kind {
        case .getAssetsBalances(let id):
            return Constants.assets + "/" + Constants.balance + "/" + "\(id)".urlEscaped

        case .getAssetsBalance(let address,
                               let assetId):
            return Constants.assets + "/" + Constants.balance + "/" + "\(address)".urlEscaped + "/" + "\(assetId)".urlEscaped

        case .details(let id):
            return Constants.assets + "/" + Constants.details + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAssetsBalances, .getAssetsBalance, .details:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getAssetsBalances, .getAssetsBalance, .details:
            return .requestPlain
        }
    }
}
