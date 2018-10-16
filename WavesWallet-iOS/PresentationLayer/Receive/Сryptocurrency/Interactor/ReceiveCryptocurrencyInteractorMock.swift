//
//  ReceiveCryptocurrencyInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class ReceiveCryptocurrencyInteractorMock: ReceiveCryptocurrencyInteractorProtocol {
    
    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<Responce<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.create({ (subscribe) -> Disposable in
            

            let params = ["currency_from" : asset.gatewayId ?? "",
                          "currency_to" : asset.wavesId ?? "",
                          "wallet_to" : WalletManager.currentWallet?.address ?? ""]
            
            NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: "https://coinomat.com/api/v1/create_tunnel.php", complete: { (info, errorMessage) in
                
                guard let info = info else {
                    subscribe.onNext(Responce(output: nil, error: NSError(domain: "", code: 0, userInfo: nil)))
                    return
                }
                
                let tunnel = JSON(info)

                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: "https://coinomat.com/api/v1/get_tunnel.php", complete: { (info, errorMessage) in
                    
                    guard let info = info else {
                        subscribe.onNext(Responce(output: nil, error: NSError(domain: "", code: 0, userInfo: nil)))
                        return
                    }
                    
                    let json = JSON(info)["tunnel"]
                    
                    let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(address: json["wallet_from"].stringValue,
                                                                            assetName: asset.displayName,
                                                                            assetShort: asset.gatewayId ?? asset.displayName,
                                                                            fee: json["in_min"].doubleValue,
                                                                            icon: asset.icon)
                    
                    subscribe.onNext(Responce(output: displayInfo, error: nil))
                })
                
               
            })
            
            return Disposables.create()
        })
    }
}
