//
//  AssetBalance+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO.AssetBalance {
    var avaliableBalance: Int64 {
        return balance - leasedBalance - inOrderBalance
    }
}
