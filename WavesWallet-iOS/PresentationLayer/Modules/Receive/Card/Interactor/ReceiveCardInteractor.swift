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
 
    private let disposeBag = DisposeBag()
    
    private func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {
    
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances()
            .flatMap({ balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset.wavesId == GlobalConstants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
        })
    }
    
    private func getAddress() -> Observable<String> {
        let authAccount = FactoryInteractors.instance.authorization
        return authAccount.authorizedWallet().flatMap { signedWallet -> Observable<String> in
            return Observable.just(signedWallet.address)
        }
    }
    
    private func getAmountInfo(fiat: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<ReceiveCard.DTO.AmountInfo>> {
       
        
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }

            let authAccount = FactoryInteractors.instance.authorization
            authAccount.authorizedWallet().subscribe(onNext: { signedWallet in
 
                let params = ["crypto" : GlobalConstants.wavesAssetId,
                              "address" : signedWallet.address,
                              "fiat" : fiat.id]
                
                //TODO: need change to Observer network
                NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getLimits, parameters: params, complete: { (info, error) in

                    if let json = info {
                        
                        let minMoney = Money(value: Decimal(json["min"].intValue), ReceiveCard.DTO.fiatDecimals)
                        let maxMoney = Money(value: Decimal(json["max"].intValue), ReceiveCard.DTO.fiatDecimals)
                        let minString = json["min"].stringValue
                        let maxString = json["max"].stringValue
                        
                        let amountInfo = ReceiveCard.DTO.AmountInfo(type: fiat, minAmount: minMoney, maxAmount: maxMoney, minAmountString: minString, maxAmountString: maxString)
                        subscribe.onNext(ResponseType(output: amountInfo, error: nil))
                        subscribe.onCompleted()
                    }
                    else if let error = error {
                        subscribe.onNext(ResponseType(output: nil, error: error))
                        subscribe.onCompleted()
                    }
                })
            }).disposed(by: strongSelf.disposeBag)
            
            return Disposables.create()
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
