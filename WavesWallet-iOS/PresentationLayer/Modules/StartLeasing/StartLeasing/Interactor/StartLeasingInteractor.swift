//
//  StartLeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class StartLeasingInteractor: StartLeasingInteractorProtocol {

    let transactionInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions
    let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    func createOrder(order: StartLeasingTypes.DTO.Order) -> Observable<DomainLayer.DTO.SmartTransaction> {

        let sender = LeaseTransactionSender(recipient: order.recipient,
                                            amount: order.amount.amount,
                                            fee: order.fee.amount)
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ (wallet) -> Observable<DomainLayer.DTO.SmartTransaction> in
                return self.transactionInteractor
                    .send(by: .lease(sender), wallet: wallet)
            })
    }
}
