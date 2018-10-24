//
//  BlockNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {
        
    struct Blocks {
        enum Kind {
            /**
             Response:
             - Node.DTO.Block
             */
            case height
        }

        let environment: Environment
        let kind: Kind
    }
}

extension Node.Service.Blocks: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let blocks = "blocks"
        static let height = "height"
    }

    var path: String {
        switch kind {
        case .height:
            return Constants.blocks + "/" + Constants.height
        }
    }

    var method: Moya.Method {
        switch kind {
        case .height:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .height:
            return .requestPlain
        }
    }
}
