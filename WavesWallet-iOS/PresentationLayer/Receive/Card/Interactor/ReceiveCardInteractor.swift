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
    
    private func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance> {
    
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances(isNeedUpdate: true)
            .flatMap({ balances -> Observable<DomainLayer.DTO.AssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset?.wavesId == GlobalConstants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
        })
    }
    
    private func getAddress() -> Observable<String> {
        let authAccount = FactoryInteractors.instance.authorization
        return authAccount.authorizedWallet().flatMap { signedWallet -> Observable<String> in
            return Observable.just(signedWallet.wallet.address)
        }
    }
    
    private func getAmountInfo(fiat: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<ReceiveCard.DTO.AmountInfo>> {
       
        
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }

            let authAccount = FactoryInteractors.instance.authorization
            authAccount.authorizedWallet().subscribe(onNext: { signedWallet in
 
                let params = ["crypto" : GlobalConstants.wavesAssetId,
                              "address" : signedWallet.wallet.address,
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
}
