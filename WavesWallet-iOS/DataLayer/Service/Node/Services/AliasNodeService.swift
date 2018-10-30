//
//  AliasNodeService.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {

    struct Alias {
        enum Kind {
            /**
             Response:
             - Node.DTO.Block
             */
            case list(accountAddress: String)
            /**
             Response:
             - String
             */
            case alias(name: String)
        }

        let environment: Environment
        let kind: Kind
    }
}

extension Node.Service.Alias: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let alias = "alias"
        static let by_address = "by-address"
        static let by_alias = "by-alias"
    }

    var path: String {
        switch kind {
        case .list(let accountAddress):
            return Constants.alias + "/" + Constants.by_address + "/" + "\(accountAddress)"

        case .alias(let name):
            return Constants.alias + "/" + Constants.by_alias + "/" + "\(name)"
        }
    }

    var method: Moya.Method {
        switch kind {
        case .list, .alias:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .list, .alias:
            return .requestPlain
        }
    }
}
