//
//  ReceiveCardInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


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
            
            guard let owner = self else { return Observable.empty() }
            return owner.coinomatRepository.cardLimits(address: wallet.address, fiat: fiat.id)
                .flatMap({ (limit) ->  Observable<ReceiveCard.DTO.AmountInfo> in
                    
                    let minString = limit.min.displayText.replacingOccurrences(of: " ", with: "")
                    let maxString = limit.max.displayText.replacingOccurrences(of: " ", with: "")

                    let amountInfo = ReceiveCard.DTO.AmountInfo(type: fiat,
                                                                minAmount: limit.min,
                                                                maxAmount: limit.max,
                                                                minAmountString: minString,
                                                                maxAmountString: maxString)
                    return Observable.just(amountInfo)
                })
        })
    }
    
    func getInfo(fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<ReceiveCard.DTO.Info>> {
    
        let amount = getAmountInfo(fiat: fiatType)
        
        return Observable.zip(getWavesBalance().take(1), amount, getAddress()).flatMap({ (assetBalance, amountInfo, address) ->  Observable<ResponseType<ReceiveCard.DTO.Info>> in

            switch amountInfo.result {
            case .success(let info):
                let info = ReceiveCard.DTO.Info(asset: assetBalance, amountInfo: info, address: address)
                return Observable.just(ResponseType(output: info, error: nil))
            
            case .error(let error):
                return Observable.just(ResponseType(output: nil, error: error))
            }
        })
        .catchError({ (error) -> Observable<ResponseType<ReceiveCard.DTO.Info>> in
            if let error = error as? NetworkError {
                return Observable.just(ResponseType(output: nil, error: error))
            }
            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        })
    }
    
    func getWavesAmount(fiatAmount: Money, fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<Money>> {
        
        let authAccount = FactoryInteractors.instance.authorization
        return authAccount.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<Money>> in
            guard let owner = self else { return Observable.empty() }
            return owner.getWavesAmount(address: wallet.address, fiatAmount: fiatAmount, fiat: fiatType)
        })
    }
}

private extension ReceiveCardInteractor {
    func getWavesAmount(address: String, fiatAmount: Money, fiat: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<Money>> {
        return Observable.create({ (subscribe) -> Disposable in
            
            let params = ["crypto": GlobalConstants.wavesAssetId,
                          "fiat": fiat.id,
                          "address": address,
                          "amount": fiatAmount.doubleValue] as [String : Any]
            
            let req = NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getPrice, parameters: params, complete: { (info, error) in
                
                if let error = error {
                    subscribe.onNext(ResponseType(output: nil, error: error))
                    subscribe.onCompleted()
                }
                else if let info = info {
                    let amount = Money(value: Decimal(info.doubleValue), GlobalConstants.WavesDecimals)
                    subscribe.onNext(ResponseType(output: amount, error: error))
                    subscribe.onCompleted()
                }
            })
            return Disposables.create {
                req.cancel()
            }
        })
    }
}
