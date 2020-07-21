//
//  AssetsRepositoryMock.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RxSwift

final class AssetsRepositoryMock: AssetsRepositoryProtocol {
    func assets(ids _: [String],
                accountAddress _: String) -> Observable<[Asset?]> {
        return Observable.never()
    }

    func isSmartAsset(assetId _: String,
                      accountAddress _: String) -> Observable<Bool> {
        return Observable.never()
    }

    func searchAssets(search _: String,
                      accountAddress _: String) -> Observable<[Asset]> {
        return Observable.never()
    }
}

extension Asset {
    static func mockWaves() -> Asset {
        return .init(id: "WAVES",
                     gatewayId: nil,
                     wavesId: "WAVES",
                     name: "Waves",
                     precision: 8,
                     description: "Waves Exchange",
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
                     gatewayType: nil,
                     isStablecoin: false,
                     isQualified: false,
                     isExistInExternalSource: false)
    }

    static func mockBTC() -> Asset {
        return .init(id: "BTC",
                     gatewayId: nil,
                     wavesId: "BTC",
                     name: "Bitcoin",
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
                     gatewayType: nil,
                     isStablecoin: false,
                     isQualified: false,
                     isExistInExternalSource: false)
    }
}
