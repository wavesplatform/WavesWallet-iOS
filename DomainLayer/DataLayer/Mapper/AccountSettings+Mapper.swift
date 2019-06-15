//
//  AccountSettings+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

extension AccountSettings {

    convenience init(_ settings: DomainLayer.DTO.AccountSettings) {
        self.init()
        self.isEnabledSpam = settings.isEnabledSpam
    }
}

extension DomainLayer.DTO.AccountSettings {

    init(_ settings: AccountSettings) {
        self.isEnabledSpam = settings.isEnabledSpam
    }
}
