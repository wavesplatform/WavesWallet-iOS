//
//  AssetsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya

extension WidgetDataService.Target {

    struct Assets {
        enum Kind {
            case getAssets(ids: [String])
        }

        let kind: Kind
        let dataUrl: URL
    }
}

extension WidgetDataService.Target.Assets: WidgetDataTargetType {
    fileprivate enum Constants {
        static let assets = "assets"
        static let ids = "ids"
    }

    var path: String {
        switch kind {
        case .getAssets:
            return Constants.assets
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAssets:
            return .post
        }
    }

    var task: Task {
        switch kind {
        case .getAssets(let ids):
            return Task.requestParameters(parameters: [Constants.ids: ids],
                                          encoding: JSONEncoding.default)
        }
    }
}
