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
    enum Assets {
        /**
         Response:
         - [Node.Model.AccountAssetsBalance].self
         */
        case getAssetsBalance(walletAddress: String)
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
        switch self {
        case .getAssetsBalance(let id):
            return Constants.assets + "/" + Constants.balance + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAssetsBalance:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getAssetsBalance:
            return .requestPlain
        }
    }
}
