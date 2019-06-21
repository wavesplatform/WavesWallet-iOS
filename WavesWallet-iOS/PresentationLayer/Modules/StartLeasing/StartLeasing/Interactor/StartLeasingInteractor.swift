//
//  StartLeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import DomainLayer

final class StartLeasingInteractor: StartLeasingInteractorProtocol {

    private let transactionInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization

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
    
    func getFee() -> Observable<Money> {
        return authorizationInteractor.authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Money> in
                guard let self = self else { return Observable.empty() }
                return self.transactionInteractor.calculateFee(by: .lease, accountAddress: wallet.address)
            })
    }
}
