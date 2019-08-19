//
//  AssetsRepositoryMock.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

final class AssetsRepositoryMock: AssetsRepositoryProtocol {
    
    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        
        return Observable.never()
    }
    
    func saveAssets(_ assets:[DomainLayer.DTO.Asset], by accountAddress: String) -> Observable<Bool> {
        return Observable.never()
    }
    
    func saveAsset(_ asset: DomainLayer.DTO.Asset, by accountAddress: String) -> Observable<Bool> {
        return Observable.never()
    }
    
    func isSmartAsset(_ assetId: String, by accountAddress: String) -> Observable<Bool> {
        return Observable.never()
    }
    
    func searchAssets(search: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return Observable.never()
    }
}


extension DomainLayer.DTO.Asset {
    
    static func mockWaves() -> DomainLayer.DTO.Asset {
        return .init(id: "WAVES",
                     gatewayId: nil,
                     wavesId: "WAVES",
                     displayName: "Waves",
                     precision: 8,
                     description: "Waves platform",
                     height: 0,
                     timestamp: Date(),
                     sender: "Waves",
                     quantity: 10,
                     ticker: "Waves",
                     isReusable: true,
                     isSpam: false,
                     isFiat: false,
                     isGeneral: true,
                     isMyWavesToken: false,
                     isWavesToken: false,
                     isGateway: false,
                     isWaves: true,
                     modified: Date(),
                     addressRegEx: "",
                     iconLogoUrl: "",
                     hasScript: false,
                     minSponsoredFee: 0,
                     gatewayType: nil)
    }
    
    static func mockBTC() -> DomainLayer.DTO.Asset {
        return .init(id: "BTC",
                     gatewayId: nil,
                     wavesId: "BTC",
                     displayName: "Bitcoin",
                     precision: 8,
                     description: "Bitcoin block",
                     height: 0,
                     timestamp: Date(),
                     sender: "BTC",
                     quantity: 10,
                     ticker: "BTC",
                     isReusable: true,
                     isSpam: false,
                     isFiat: false,
                     isGeneral: true,
                     isMyWavesToken: false,
                     isWavesToken: false,
                     isGateway: true,
                     isWaves: false,
                     modified: Date(),
                     addressRegEx: "",
                     iconLogoUrl: "",
                     hasScript: false,
                     minSponsoredFee: 0,
                     gatewayType: nil)
    }
}
