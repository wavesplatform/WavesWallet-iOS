//
//  WalletSortInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletSortInteractorProtocol {

    func move(asset: WalletSort.DTO.Asset, underAsset: WalletSort.DTO.Asset)
    func move(asset: WalletSort.DTO.Asset, overAsset: WalletSort.DTO.Asset)

    func setFavorite(assetId: String, isFavorite: Bool)
    func setHidden(assetId: String, isHidden: Bool)
}
