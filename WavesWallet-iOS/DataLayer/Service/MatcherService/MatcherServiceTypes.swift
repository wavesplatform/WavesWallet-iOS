//
//  MatcherServiceTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


enum Matcher {}

extension Matcher {
    enum DTO {}
    enum Service {}
}

protocol MatcherTargetType: BaseTargetType {}

extension MatcherTargetType {
    var baseURL: URL { return Environments.current.servers.matcherUrl }
}
