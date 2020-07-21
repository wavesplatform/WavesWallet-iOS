//
//  AssetsRepository.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
    
public protocol AssetsRepositoryProtocol  {

    func assets(ids: [String],
                accountAddress: String) -> Observable<[Asset?]>
    
    func isSmartAsset(assetId: String,
                      accountAddress: String) -> Observable<Bool>
   
    func searchAssets(search: String,
                      accountAddress: String) -> Observable<[Asset]>        
}
