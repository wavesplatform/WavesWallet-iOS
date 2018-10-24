//
//  TestInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

final class TestInteractor {
    
    func send() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
//            let authAccount = FactoryInteractors.instance.authorization
//
//            authAccount.authorizedWallet().flatMap { signedWallet -> Observable<String> in
//
//                return Observable.just(signedWallet.wallet.address)
//            }
            
//            3P4gDdkTQs71ZWzdkowju5Ka4cyD2VSLxz4
            
            let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
            auth.authorizedWallet().subscribe(onNext: { signedWallet in
                
                let transaction = Send.DTO.Transaction(senderPublicKey: signedWallet.publicKey, senderPrivateKey: signedWallet.privateKey, fee: GlobalConstants.WavesTransactionFee, recipient: "0x80ecc4c6aa2d785e2b3b9a5d0fa130531af30018", assetId: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", amount: Money(100000, 8), attachment: "", isAlias: false)
                
                
                let params = ["type" : transaction.type,
                              "senderPublicKey" : Base58.encode(transaction.senderPublicKey.publicKey),
                              "fee" : transaction.fee.amount,
                              "timestamp" : transaction.timestamp,
                              "proofs" : transaction.proofs,
                              "version" : transaction.version,
                              "recipient" : transaction.recipient,
                              "assetId" : transaction.assetId,
                              "feeAssetId" : transaction.feeAssetId,
                              "feeAsset" : transaction.feeAsset,
                              "amount" : transaction.amount.amount,
                              "attachment" : Base58.encode(Array(transaction.attachment.utf8))] as [String : Any]
                
                let url = Environments.current.servers.nodeUrl.appendingPathComponent("/transactions/broadcast")
                Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                    print(response.result.value)
                })
            })
        }

    }
}
