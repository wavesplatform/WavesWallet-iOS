//
//  ReceiveCryptocurrencyInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveCryptocurrencyInteractor: ReceiveCryptocurrencyInteractorProtocol {
    
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let coinomatRepository = FactoryRepositories.instance.coinomatRepository
    
    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        guard let currencyFrom = asset.gatewayId,
            let currencyTo = asset.wavesId else { return Observable.empty() }

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in
          
            guard let owner = self else { return Observable.empty() }
            
            let tunnel = owner.coinomatRepository.tunnelInfo(asset: asset,
                                                             currencyFrom: currencyFrom,
                                                             currencyTo: currencyTo,
                                                             walletTo: wallet.address,
                                                             moneroPaymentID: nil)
            let rate = owner.coinomatRepository.getRate(asset: asset)
            return Observable.zip(tunnel, rate)
                .flatMap({ (tunnel, rate) ->  Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in
                
                    let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(address: tunnel.address,
                                                                            assetName: asset.displayName,
                                                                            assetShort: currencyFrom,
                                                                            minAmount: tunnel.min,
                                                                            icon: asset.iconLogo)
                    return Observable.just(ResponseType(output: displayInfo, error: nil))
            })
        })
        .catchError({ (error) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in
            if let networkError = error as? NetworkError {
                return Observable.just(ResponseType(output: nil, error: networkError))
            }
            
            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        })
    }
}
