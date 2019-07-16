//
//  AccountEnvironmentDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {

    struct AccountEnvironment: Equatable, Mutating {
        public var nodeUrl: String?
        public var dataUrl: String?
        public var spamUrl: String?
        public var matcherUrl: String?

        public init(nodeUrl: String?, dataUrl: String?, spamUrl: String?, matcherUrl: String?) {
            self.nodeUrl = nodeUrl
            self.dataUrl = dataUrl
            self.spamUrl = spamUrl
            self.matcherUrl = matcherUrl
        }
    }
}
