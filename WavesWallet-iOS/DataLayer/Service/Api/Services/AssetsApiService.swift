//
//  AssetsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension API.Service {

    struct Assets {
        enum Kind {
            /**
             Response:
             - API.Response<[API.Response<API.Model.Asset>]>.self
             */
            case getAssets(ids: [String])
            /**
             Response:
             - API.Response<API.Model.Asset>.self
             */
            case getAsset(id: String)
        }

        let kind: Kind
        let environment: Environment
    }
}

extension API.Service.Assets: ApiTargetType {
    fileprivate enum Constants {
        static let assets = "assets"
        static let ids = "ids"
    }

    var path: String {
        switch kind {
        case .getAsset(let id):
            return Constants.assets + "/" + "\(id)".urlEscaped
        case .getAssets:
            return Constants.assets
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAsset:
            return .get
        case .getAssets:
            return .post
        }
    }

    var task: Task {
        switch kind {
        case .getAssets(let ids):
            return Task.requestParameters(parameters: [Constants.ids: ids],
                                          encoding: JSONEncoding.default)
        case .getAsset:
            return .requestPlain
        }
    }
}
