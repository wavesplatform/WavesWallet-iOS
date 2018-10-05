//
//  AssetListInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AssetListInteractorProtocol {
    
    func assets(filters: [AssetList.DTO.Filter]) -> Observable<[DomainLayer.DTO.AssetBalance]>
    func searchAssets(searchText: String)

}
