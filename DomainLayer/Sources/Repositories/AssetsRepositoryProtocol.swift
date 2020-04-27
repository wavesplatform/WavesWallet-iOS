//
//  AssetsRepository.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public enum AssetsRepositoryError: Error {
    case fail
    case notFound
}

public protocol AssetsRepositoryProtocol  {

    func assets(serverEnvironment: ServerEnvironment,
                ids: [String],
                accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]>
    
    func isSmartAsset(serverEnvironment: ServerEnvironment,
                      assetId: String,
                      accountAddress: String) -> Observable<Bool>
   
    func searchAssets(serverEnvironment: ServerEnvironment,
                      search: String,
                      accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]>
    
    func saveAssets(_ assets:[DomainLayer.DTO.Asset],
                    by accountAddress: String) -> Observable<Bool>
    func saveAsset(_ asset: DomainLayer.DTO.Asset,
                   by accountAddress: String) -> Observable<Bool>
}
