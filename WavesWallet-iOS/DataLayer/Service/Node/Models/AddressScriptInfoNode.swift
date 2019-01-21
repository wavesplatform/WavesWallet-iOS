//
//  AddressScriptInfo.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct AddressScriptInfo {
        let address: String
        let complexity: Int64
        let extraFee: Int64
    }
}
