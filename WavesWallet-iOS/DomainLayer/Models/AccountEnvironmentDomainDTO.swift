//
//  AccountEnvironmentDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct AccountEnvironment: Equatable, Mutating {
        var nodeUrl: String?
        var dataUrl: String?
        var spamUrl: String?
        var matcherUrl: String?
    }
}
