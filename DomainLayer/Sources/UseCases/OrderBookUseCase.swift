//
//  OrderBookUseCase.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 08.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class OrderBookUseCase: OrderBookUseCaseProtocol {
    
    private let orderBookRepository: DexOrderBookRepositoryProtocol
    private let assetsInteractor: AssetsUseCaseProtocol
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    
    init(orderBookRepository: DexOrderBookRepositoryProtocol,
         assetsInteractor: AssetsUseCaseProtocol,
         authorizationInteractor: AuthorizationUseCaseProtocol) {
        self.orderBookRepository = orderBookRepository
        self.assetsInteractor = assetsInteractor
        self.authorizationInteractor = authorizationInteractor
    }
    
    func orderSettingsFee() -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> {
       
        return authorizationInteractor.authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> in
                guard let self = self else { return Observable.empty() }
                
                return self.orderBookRepository.orderSettingsFee()
                    .flatMap({ [weak self] (baseSettings) -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> in
                        guard let self = self else { return Observable.empty() }
                       
                        return self.assetsInteractor.assets(by: baseSettings.feeAssets.map{$0.assetId},
                                                            accountAddress: wallet.address)
                            .map({ (assets) -> DomainLayer.DTO.Dex.SmartSettingsOrderFee in
                                
                                let feeAssets = assets.map({ (asset) -> DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset in
                                    
                                    let dexAsset = DomainLayer.DTO.Dex.Asset.init(id: asset.id,
                                                                                 name: asset.displayName,
                                                                                 shortName: asset.ticker ?? asset.displayName,
                                                                                 decimals: asset.precision)
                                    
                                    let rate = baseSettings.feeAssets.first(where: {$0.assetId == asset.id})?.rate ?? 0
                                    return DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset(rate: rate, asset: dexAsset)
                                })
                                
                                
                                return DomainLayer.DTO.Dex.SmartSettingsOrderFee(baseFee: baseSettings.baseFee, feeAssets: feeAssets)
                            })
                    })
            })
    }
}
