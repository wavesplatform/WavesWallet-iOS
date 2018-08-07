//
//  NodeTargetType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Node {}

extension Node {
    enum DTO {}
    enum Service {}
}

protocol NodeTargetType: BaseTargetType {}

extension NodeTargetType {
    var baseURL: URL { return Environments.current.servers.nodeUrl }
}
