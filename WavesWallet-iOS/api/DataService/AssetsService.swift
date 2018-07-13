//
//  AssetsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Alamofire
import Foundation
import MBProgressHUD
import Moya
import RxDataSources
import RxRealm
import RxSwift

extension DataService {
    enum Assets {
        case getAssets(ids: [String])
        case getAsset(id: String)
    }
}

extension DataService.Assets: ApiType {
    private enum Constants {
        static let assets = "asset"
    }

    var apiVersion: String {
        return "v0"
    }

    var apiUrl: String {
        return Environments.current.servers.dataUrl.relativeString
    }

    var path: String {
        switch self {
        case .getAsset(let id):
            return Constants.assets + "/\(id)".urlEscaped
        case .getAssets(let ids):
            let params = ids.reduce("") { $0 + "=" + $1 }
            return Constants.assets + "/\(params)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAssets, .getAsset:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getAssets, .getAsset:
            return .requestPlain
        }
    }
}
