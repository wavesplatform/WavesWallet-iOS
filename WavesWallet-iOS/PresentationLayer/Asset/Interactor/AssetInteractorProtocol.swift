//
//  AssetViewInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AssetInteractorProtocol {

    func assets(by ids: [String]) -> Observable<[AssetTypes.DTO.Asset]>
    func transactions(by assetId: String) -> Observable<[AssetTypes.DTO.Transaction]>
    func refreshAssets(by ids: [String])
}
