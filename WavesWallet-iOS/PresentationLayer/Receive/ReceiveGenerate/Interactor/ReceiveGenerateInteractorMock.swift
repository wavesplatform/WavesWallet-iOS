//
//  ReceiveGenerateInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


final class ReceiveGenerateInteractorMock: ReceiveGenerateInteractorProtocol {
    
    func generateInvoiceAddress(_ info: ReceiveInvoive.DTO.GenerateInfo) -> Observable<Responce<ReceiveInvoive.DTO.DisplayInfo>> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                let assetName = info.balanceAsset.asset?.name ?? ""
                let info = ReceiveInvoive.DTO.DisplayInfo(address: "dsadsafaf", invoiceLink: "gfsgsgsg", assetName: assetName)
                subscribe.onNext(Responce(output: info, error: nil))

                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
}
