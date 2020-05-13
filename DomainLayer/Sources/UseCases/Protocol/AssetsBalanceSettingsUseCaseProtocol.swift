//
//  AssetsBalanceSettingsUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions

public protocol AssetsBalanceSettingsUseCaseProtocol {
    
    func settings(by accountAddress: String, assets: [Asset]) -> Observable<[AssetBalanceSettings]>
    func setFavorite(by accountAddress: String, assetId: String, isFavorite: Bool) -> Observable<Bool>
    func updateAssetsSettings(by accountAddress: String, settings: [AssetBalanceSettings]) -> Observable<Bool>
}
