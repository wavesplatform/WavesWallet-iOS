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
         - [Node.Model.AssetBalance].self
         */
        case getBalanceForAssets(accountId: String)
    }
}

extension Node.Service.Assets: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    private enum Constants {
        static let assets = "assets"
        static let balance = "balance"
    }

    var path: String {
        switch self {
        case .getBalanceForAssets(let id):
            return Constants.assets + "/" + Constants.balance + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBalanceForAssets:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getBalanceForAssets:
            return .requestPlain
        }
    }
}
