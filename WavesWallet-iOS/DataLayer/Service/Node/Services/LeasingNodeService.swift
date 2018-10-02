//
//  LeasingNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {
    enum Leasing {
        /**
         Response:
         - [Node.Model.LeasingTransaction].self
         */
        case getActive(accountAddress: String)
    }
}

extension Node.Service.Leasing: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let leasing = "leasing"
        static let active = "active"
        static let address = "address"
    }

    var path: String {
        switch self {
        case .getActive(let accountAddress):
            return Constants.leasing + "/" + Constants.active + "/" + "\(accountAddress)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getActive:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getActive:
            return .requestPlain
        }
    }
}
