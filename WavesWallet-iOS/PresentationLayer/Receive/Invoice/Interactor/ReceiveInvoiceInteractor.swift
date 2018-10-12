//
//  ReceiveInvoiceInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constancts {
    static let baseUrl = "https://client.wavesplatform.com/"
    static let apiPath = "#send/"
}

final class ReceiveInvoiceInteractor: ReceiveInvoiceInteractorProtocol {
 
    func displayInfo(asset: DomainLayer.DTO.Asset, amount: Money) -> Observable<ReceiveInvoice.DTO.DisplayInfo> {

        let authAccount = FactoryInteractors.instance.authorization
        return authAccount.authorizedWallet()
        .flatMap({ signedWallet -> Observable<ReceiveInvoice.DTO.DisplayInfo> in
            
            var url = Constancts.baseUrl + Constancts.apiPath + asset.id
            url.append("?")
            url.append("recipient=" + signedWallet.wallet.address)
            url.append("&")
            url.append("amount=" + String(amount.doubleValue))
            
            let info = ReceiveInvoice.DTO.DisplayInfo(address: url, invoiceLink: "", assetName: asset.displayName)
            return Observable.just(info)
        })
    }
}

