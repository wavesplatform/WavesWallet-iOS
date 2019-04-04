//
//  ReceiveCardInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


final class ReceiveCardInteractor: ReceiveCardInteractorProtocol {
 
    private let auth = FactoryInteractors.instance.authorization
    private let coinomatRepository = FactoryRepositories.instance.coinomatRepository
    private let accountBalance = FactoryInteractors.instance.accountBalance

    func getInfo(fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<ReceiveCard.DTO.Info>> {
    
        let amount = getAmountInfo(fiat: fiatType)
        
        return Observable.zip(getWavesBalance(), amount, getMyAddress())
            .flatMap({ (assetBalance, amountInfo, address) -> Observable<ResponseType<ReceiveCard.DTO.Info>> in
                
                let info = ReceiveCard.DTO.Info(asset: assetBalance, amountInfo: amountInfo, address: address)
                return Observable.just(ResponseType(output: info, error: nil))
            })
            .catchError({ (error) -> Observable<ResponseType<ReceiveCard.DTO.Info>> in
                if let networkError = error as? NetworkError {
                    return Observable.just(ResponseType(output: nil, error: networkError))
                }
                
                return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
            })
    }
    
    
    func getWavesAmount(fiatAmount: Money, fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<Money>> {
        
        let authAccount = FactoryInteractors.instance.authorization
        return authAccount
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<ResponseType<Money>> in
                guard let self = self else { return Observable.empty() }
                return self.coinomatRepository.getPrice(address: wallet.address, amount: fiatAmount, type: fiatType.id)
                    .map({ (money) -> ResponseType<Money> in
                        return ResponseType(output: money, error: nil)
                    })
                    .catchError({ (error) -> Observable<ResponseType<Money>> in
                        if let error = error as? NetworkError {
                            return Observable.just(ResponseType(output: nil, error: error))
                        }
                        return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                    })
        })
    }
}

private extension ReceiveCardInteractor {
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        
        //TODO: need optimize 
        return accountBalance.balances().flatMap({ balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in
            guard let wavesAsset = balances.first(where: {$0.asset.wavesId == GlobalConstants.wavesAssetId}) else {
                return Observable.empty()
            }
            return Observable.just(wavesAsset)
        })
    }
    
    func getMyAddress() -> Observable<String> {
        return auth.authorizedWallet().flatMap { signedWallet -> Observable<String> in
            return Observable.just(signedWallet.address)
        }
    }
    
    func getAmountInfo(fiat: ReceiveCard.DTO.FiatType) -> Observable<ReceiveCard.DTO.AmountInfo> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ReceiveCard.DTO.AmountInfo> in
            
            guard let self = self else { return Observable.empty() }
            return self.coinomatRepository.cardLimits(address: wallet.address, fiat: fiat.id)
                .flatMap({ (limit) ->  Observable<ReceiveCard.DTO.AmountInfo> in
                    
                    let amountInfo = ReceiveCard.DTO.AmountInfo(type: fiat,
                                                                minAmount: limit.min,
                                                                maxAmount: limit.max)
                    return Observable.just(amountInfo)
                })
        })
    }
}
