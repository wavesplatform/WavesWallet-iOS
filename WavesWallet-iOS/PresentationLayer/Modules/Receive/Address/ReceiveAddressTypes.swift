//
//  ReceiveAddressTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveAddress {
    enum DTO {
        struct Info {
            let assetName: String
            let address: String
            let icon: String
            let qrCode: String
            let invoiceLink: String?
        }
    }
}
