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
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }
            
            strongSelf.getAddress(asset: asset, complete: { (address, error) in

                if let address = address {
                    
                    strongSelf.getMinAmount(asset: asset, complete: { (minAmount, error) in

                        if let min = minAmount {
                            let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(address: address,
                                                                                    assetName: asset.displayName,
                                                                                    assetShort: asset.gatewayId ?? asset.displayName,
                                                                                    minAmount: min,
                                                                                    icon: asset.icon)
                            subscribe.onNext(ResponseType(output: displayInfo, error: nil))
                        }
                        else {
                            subscribe.onNext(ResponseType(output: nil, error: error))
                        }
                    })
                }
                else {
                    subscribe.onNext(ResponseType(output: nil, error: error))
                }
            })
            
            return Disposables.create()
        })
    }
    
    private func getMinAmount(asset: DomainLayer.DTO.Asset, complete:@escaping(_ minAmount: Money?, _ error: ResponseTypeError?) -> Void) {
        
        let params = ["f" : asset.wavesId ?? "",
                      "t" : asset.gatewayId ?? ""]
        
        //TODO: need change to Observer network
        NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getRate, parameters: params) { (info, error) in
            
            var min: Money?
            
            if let json = info {
                min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
            }
            
            complete(min, error)
        }
    }
    
  
    private func getAddress(asset: DomainLayer.DTO.Asset, complete:@escaping(_ address: String?, _ error: ResponseTypeError?) -> Void) {
    
        auth.authorizedWallet().subscribe(onNext: { signedWallet in

            let params = ["currency_from" : asset.gatewayId ?? "",
                          "currency_to" : asset.wavesId ?? "",
                          "wallet_to" : signedWallet.address]
            
            //TODO: need change to Observer network
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.createTunnel, parameters: params, complete: { (info, error) in
                
                guard let tunnel = info else {
                    complete(nil, error)
                    return
                }
                
                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getTunnel, parameters: params, complete: { (info, error) in
                    
                    guard let info = info else {
                        complete(nil, error)
                        return
                    }
                    
                    let json = info["tunnel"]
                    complete(json["wallet_from"].stringValue, nil)
                })
            })
            
        }).disposed(by: disposeBag)
    }
    
}
