//
//  NewWalletSortInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

protocol WalletSortInteractorProtocol {
    func updateAssetSettings(assets: [WalletSort.DTO.Asset])
}
