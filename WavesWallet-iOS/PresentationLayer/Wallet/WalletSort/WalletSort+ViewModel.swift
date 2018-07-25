//
//  WalletSortTypes+ViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletSort.DTO {

    struct Asset: Hashable {
        let id: String
        let name: String
        let isLock: Bool
        let isMyAsset: Bool
        let isFavorite: Bool
        let isFiat: Bool
        let sortLevel: Float
    }
}
