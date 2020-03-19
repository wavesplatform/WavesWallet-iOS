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
    enum ViewModel {}
}
    
extension ReceiveAddress.ViewModel {
    
    struct DisplayData {
        let address: [ReceiveAddress.ViewModel.Address]
        let hasShowInfo: Bool
    }
    
    struct Address {
        let assetName: String
        let address: String
        let addressTypeName: String
        let icon: AssetLogo.Icon
    }
}
