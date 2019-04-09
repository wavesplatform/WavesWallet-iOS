//
//  ReceiveInvoiceInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension

private enum Constancts {
    static let baseUrl = "https://client.wavesplatform.com/"
    static let apiPath = "#send/"
}

final class ReceiveInvoiceInteractor: ReceiveInvoiceInteractorProtocol {
 
    func displayInfo(asset: DomainLayer.DTO.Asset, amount: Money) -> Observable<ReceiveInvoice.DTO.DisplayInfo> {

        let authAccount = FactoryInteractors.instance.authorization
        return authAccount.authorizedWallet()
        .flatMap({ signedWallet -> Observable<ReceiveInvoice.DTO.DisplayInfo> in
            
            let params = ["recipient" : signedWallet.address,
                          "amount" : String(amount.doubleValue)]
            
            let url = (Constancts.baseUrl + Constancts.apiPath + asset.id).urlByAdding(params: params)
                        
            let info = ReceiveInvoice.DTO.DisplayInfo(address: signedWallet.address,
                                                      invoiceLink: url,
                                                      assetName: asset.displayName,
                                                      icon: asset.iconLogo,
                                                      isSponsored: asset.isSponsored,
                                                      hasScript: asset.hasScript)
            
            return Observable.just(info)
        })
    }
}

