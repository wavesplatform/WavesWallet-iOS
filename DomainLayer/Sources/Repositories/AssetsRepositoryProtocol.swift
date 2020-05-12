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
                accountAddress: String) -> Observable<[Asset]>
    
    func isSmartAsset(serverEnvironment: ServerEnvironment,
                      assetId: String,
                      accountAddress: String) -> Observable<Bool>
   
    func searchAssets(serverEnvironment: ServerEnvironment,
                      search: String,
                      accountAddress: String) -> Observable<[Asset]>
    
    func saveAssets(_ assets:[Asset],
                    by accountAddress: String) -> Observable<Bool>
    func saveAsset(_ asset: Asset,
                   by accountAddress: String) -> Observable<Bool>
}
