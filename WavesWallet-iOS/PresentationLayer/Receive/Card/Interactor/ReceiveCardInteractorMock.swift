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

private enum Constants {
    static let baseUrl = "https://coinomat.com/"
    static let apiPath = "api/v2/indacoin/"
    static let fiatDecimals = 2
}

final class ReceiveCardInteractorMock: ReceiveCardInteractorProtocol {
 
    private let disposeBag = DisposeBag()
    
    private func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance> {
    
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances(isNeedUpdate: true)
            .flatMap({ balances -> Observable<DomainLayer.DTO.AssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset?.wavesId == Environments.Constants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
        })
    }
    
    
    private func getAmountInfo(fiat: ReceiveCard.DTO.FiatType) -> Observable<Responce<ReceiveCard.DTO.AmountInfo>> {
       
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }

            let authAccount = FactoryInteractors.instance.authorization
            authAccount.authorizedWallet().subscribe(onNext: { signedWallet in
                
                let url = Constants.baseUrl + Constants.apiPath + "limits.php"
                
                let params = ["crypto" : Environments.Constants.wavesAssetId,
                              "address" : signedWallet.wallet.address,
                              "fiat" : fiat.id]
                
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                    
                    if let info = info {
                        let json = JSON(info)
                        
                        let minMoney = Money(value: Decimal(json["min"].intValue), Constants.fiatDecimals)
                        let maxMoney = Money(value: Decimal(json["max"].intValue), Constants.fiatDecimals)
                        let minString = json["min"].stringValue
                        let maxString = json["max"].stringValue
                        
                        let amountInfo = ReceiveCard.DTO.AmountInfo(type: fiat, minAmount: minMoney, maxAmount: maxMoney, minAmountString: minString, maxAmountString: maxString)
                        subscribe.onNext(Responce(output: amountInfo, error: nil))
                        subscribe.onCompleted()
                    }
                    else if let errorMessage = errorMessage {
                        subscribe.onNext(Responce(output: nil, error: NSError(domain: errorMessage, code: 0, userInfo: nil)))
                        subscribe.onCompleted()
                    }
                })
            }).disposed(by: strongSelf.disposeBag)
            
            return Disposables.create()
        })
    }
    
    func getInfo(fiatType: ReceiveCard.DTO.FiatType) -> Observable<Responce<ReceiveCard.DTO.Info>> {
    
        let amount = getAmountInfo(fiat: fiatType)
        
        return Observable.zip(getWavesBalance().take(1), amount).flatMap({ (assetBalance, amountInfo) ->  Observable<Responce<ReceiveCard.DTO.Info>> in
            
            switch amountInfo.result {
            case .success(let info):
                let info = ReceiveCard.DTO.Info(asset: assetBalance, amountInfo: info)
                return Observable.just(Responce(output: info, error: nil))
            
            case .error(let error):
                return Observable.just(Responce(output: nil, error: NSError(domain: error.localizedDescription, code: 0, userInfo: nil)))
            }
        })
        
    }
}
