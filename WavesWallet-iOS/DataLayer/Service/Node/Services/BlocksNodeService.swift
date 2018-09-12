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
    enum Blocks {
        /**
         Response:
         - Node.DTO.Block
         */
        case height
    }
}

extension Node.Service.Blocks: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    private enum Constants {
        static let blocks = "blocks"
        static let height = "height"
    }

    var path: String {
        switch self {
        case .height:
            return Constants.blocks + "/" + Constants.height
        }
    }

    var method: Moya.Method {
        switch self {
        case .height:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .height:
            return .requestPlain
        }
    }
}
