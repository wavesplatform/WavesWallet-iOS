//
//  ReceiveCryptocurrencyInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class ReceiveCryptocurrencyInteractor: ReceiveCryptocurrencyInteractorProtocol {
    
    private var disposeBag = DisposeBag()
    
    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }
            
            strongSelf.getAddress(asset: asset, complete: { (address, errorMessage) in

                if let address = address {
                    
                    strongSelf.getMinAmount(asset: asset, complete: { (minAmount, errorMessage) in

                        if let min = minAmount {
                            let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(address: address,
                                                                                    assetName: asset.displayName,
                                                                                    assetShort: asset.gatewayId ?? asset.displayName,
                                                                                    minAmount: min,
                                                                                    icon: asset.icon)
                            subscribe.onNext(ResponseType(output: displayInfo, error: nil))
                        }
                        else {
                            subscribe.onNext(ResponseType(output: nil, error: errorMessage))
                        }
                    })
                }
                else {
                    subscribe.onNext(ResponseType(output: nil, error: errorMessage))
                }
            })
            
            return Disposables.create()
        })
    }
    
    private func getMinAmount(asset: DomainLayer.DTO.Asset, complete:@escaping(_ minAmount: Money?, _ errorMessage: String?) -> Void) {
        
        let params = ["f" : asset.wavesId ?? "",
                      "t" : asset.gatewayId ?? ""]
        
        NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.getRate) { (info, errorMessage) in
            
            var min: Money?
            
            if let info = info {
                let json = JSON(info)
                min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
            }
            
            complete(min, errorMessage)
        }
    }
    
  
    private func getAddress(asset: DomainLayer.DTO.Asset, complete:@escaping(_ address: String?, _ errorMessage: String?) -> Void) {
    
        let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
        auth.authorizedWallet().subscribe(onNext: { signedWallet in

            let params = ["currency_from" : asset.wavesId ?? "",
                          "currency_to" : asset.gatewayId ?? "",
                          "wallet_to" : signedWallet.wallet.address]
            
            NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.createTunnel, complete: { (info, errorMessage) in
                
                guard let info = info else {
                    complete(nil, errorMessage)
                    return
                }
                
                let tunnel = JSON(info)
                
                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.getTunnel, complete: { (info, errorMessage) in
                    
                    guard let info = info else {
                        complete(nil, errorMessage)
                        return
                    }
                    
                    let json = JSON(info)["tunnel"]
                    complete(json["wallet_from"].stringValue, nil)
                })
            })
            
        }).disposed(by: disposeBag)
    }
    
}
