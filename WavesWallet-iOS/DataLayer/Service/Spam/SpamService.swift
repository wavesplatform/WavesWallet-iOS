//
//  SpamService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Spam {}

extension Spam {
    enum Service {}
}

protocol SpamTargetType: BaseTargetType {}

extension SpamTargetType {
    var baseURL: URL { return Environments.current.servers.spamUrl }

    var headers: [String: String]? {
        return ContentType.applicationCsv.headers
    }

    var environment: Environment {
        return Environments.current
    }
}
