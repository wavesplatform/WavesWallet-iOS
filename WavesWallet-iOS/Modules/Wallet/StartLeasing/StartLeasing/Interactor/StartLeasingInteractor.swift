//
//  StartLeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift

final class StartLeasingInteractor: StartLeasingInteractorProtocol {
    private let transactionInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let aliasRepository = UseCasesFactory.instance.repositories.aliasesRepositoryRemote
    private let serverEnvironmentUseCase: ServerEnvironmentRepository = UseCasesFactory.instance.serverEnvironmentUseCase

    func createOrder(order: StartLeasingTypes.DTO.Order) -> Observable<SmartTransaction> {
        let sender = LeaseTransactionSender(recipient: order.recipient,
                                            amount: order.amount.amount,
                                            fee: order.fee.amount)
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { (wallet) -> Observable<SmartTransaction> in
                self.transactionInteractor
                    .send(by: .lease(sender), wallet: wallet)
            }
    }

    func getFee() -> Observable<Money> {
        return authorizationInteractor.authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<Money> in
                guard let self = self else { return Observable.empty() }
                return self.transactionInteractor.calculateFee(by: .lease, accountAddress: wallet.address)
            }
    }

    func validateAlis(alias: String) -> Observable<Bool> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(authorizationInteractor.authorizedWallet(), serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<Bool> in
                guard let self = self else { return Observable.never() }

                return self.aliasRepository.alias(serverEnvironment: serverEnvironment,
                                                  name: alias,
                                                  accountAddress: wallet.address)
                    .flatMap { (_) -> Observable<Bool> in
                        Observable.just(true)
                    }
            }
            .catchError { (_) -> Observable<Bool> in
                Observable.just(false)
            }
    }
}
