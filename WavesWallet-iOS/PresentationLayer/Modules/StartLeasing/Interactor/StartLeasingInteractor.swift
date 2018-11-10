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

    func createOrder(order: StartLeasing.DTO.Order) -> Observable<Bool> {

        let sender = LeaseTransactionSender(recipient: order.recipient,
                                            amount: order.amount.amount,
                                            fee: GlobalConstants.WavesTransactionFeeAmount)
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ (wallet) -> Observable<Bool> in
                return self.transactionInteractor
                    .send(by: .lease(sender), wallet: wallet)
                    .map { _ in true }
            })
    }
}
