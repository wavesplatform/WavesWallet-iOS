//
//  ReceiveAddressTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

enum ReceiveAddress {
    enum DTO {
        struct Info {
            let assetName: String
            let address: String
            let displayName: String
            let icon: AssetLogo.Icon
            let qrCode: String            
            let isSponsored: Bool
            let hasScript: Bool
        }
    }
}
