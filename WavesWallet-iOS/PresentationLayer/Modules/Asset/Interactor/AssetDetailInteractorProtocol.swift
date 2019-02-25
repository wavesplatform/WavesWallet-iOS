//
//  AssetViewInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AssetDetailInteractorProtocol {

    func assets(by ids: [String]) -> Observable<[AssetDetailTypes.DTO.Asset]>
    func transactions(by assetId: String) -> Observable<[DomainLayer.DTO.SmartTransaction]>
    func refreshAssets(by ids: [String])
    func toggleFavoriteFlagForAsset(by id: String, isFavorite: Bool)
}
