//
//  AssetsRepository.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum AssetsRepositoryError: Error {
    case fail
    case notFound
}

protocol AssetsRepositoryProtocol  {

    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]>
    
    func saveAssets(_ assets:[DomainLayer.DTO.Asset], by accountAddress: String) -> Observable<Bool>
    func saveAsset(_ asset: DomainLayer.DTO.Asset, by accountAddress: String) -> Observable<Bool>

    func isSmartAsset(_ assetId: String, by accountAddress: String) -> Observable<Bool>
}
