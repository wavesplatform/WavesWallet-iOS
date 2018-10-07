//
//  ReceiveCryptocurrencyInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveCryptocurrencyInteractorMock: ReceiveCryptocurrencyInteractorProtocol {
    
    func generateAddress(ticker: String, generalTicker: String) -> Observable<Responce<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let info = ReceiveCryptocurrency.DTO.DisplayInfo(address: "dsakdaskldaslkdj",
                                                                 assetName: "Bitcoin",
                                                                 assetTicker: "BTC",
                                                                 fee: "0.0001")
                
                subscribe.onNext(Responce(output: info, error: nil))
                subscribe.onCompleted()
            }
          
            return Disposables.create()
        })
        
//        example of request to coinmat.com
        
//        https://coinomat.com/api/v1/create_tunnel.php?currency_from=BTC&currency_to=WBTC&wallet_to=3PCAB4sHXgvtu5NPoen6EXR5yaNbvsEA8Fj
        
//        https://coinomat.com/api/v1/get_tunnel.php?xt_id=370624&k1=0b4d92046dba9dc4454f5d1e951794ca&k2=ca8b6c0aa9914541a2e7f2e186e88e16&history=0&lang=ru_RU
}
}
