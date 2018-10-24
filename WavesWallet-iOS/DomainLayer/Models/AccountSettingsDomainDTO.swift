//
//  AccountEnvironmentDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct AccountSettings: Equatable, Mutating {
        var isEnabledSpam: Bool
    }
}
