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
    }

    var path: String {
        switch kind {
        case .list(let accountAddress):
            return Constants.alias + "/" + Constants.by_address + "/" + "\(accountAddress)"
        }
    }

    var method: Moya.Method {
        switch kind {
        case .list:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .list:
            return .requestPlain
        }
    }
}
