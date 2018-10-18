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
    
    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<Response<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.create({ (subscribe) -> Disposable in
            

            let params = ["currency_from" : asset.gatewayId ?? "",
                          "currency_to" : asset.wavesId ?? "",
                          "wallet_to" : WalletManager.currentWallet?.address ?? ""]
            
            let url = GlobalConstants.coinomatUrl + "api/v1/create_tunnel.php"
            NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                
                guard let info = info else {
                    subscribe.onNext(Response(output: nil, error: errorMessage))
                    return
                }
                
                let tunnel = JSON(info)

                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                let url = GlobalConstants.coinomatUrl + "api/v1/get_tunnel.php"
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                    
                    guard let info = info else {
                        subscribe.onNext(Response(output: nil, error: errorMessage))
                        return
                    }
                    
                    let json = JSON(info)["tunnel"]
                    
                    let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(address: json["wallet_from"].stringValue,
                                                                            assetName: asset.displayName,
                                                                            assetShort: asset.gatewayId ?? asset.displayName,
                                                                            fee: json["in_min"].doubleValue,
                                                                            icon: asset.icon)
                    
                    subscribe.onNext(Response(output: displayInfo, error: nil))
                })
                
               
            })
            
            return Disposables.create()
        })
    }
}
