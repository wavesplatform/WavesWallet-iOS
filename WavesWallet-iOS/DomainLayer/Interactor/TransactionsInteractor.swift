//
//  TransactionsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private struct Constants {
    static let durationInseconds: Double =  15
}

protocol TransactionsInteractorProtocol {
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]>
}

final class TransactionsInteractor: TransactionsInteractorProtocol {

    private var transactionsRepositoryLocal: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryLocal
    private var transactionsRepositoryRemote: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryRemote

    func transactions(by accountAddress: String,  specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {

        transactionsRepositoryLocal
            .isHasTransactions
            .flatMap { isHasTransactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                if isHasTransactions {
                    return Observable.never()
                } else {
                    return Observable.never()
                }
        }

        return transactionsRepositoryRemote.transactions(by: accountAddress,
                                                  offset: 0,
                                                  limit: 10000)
            .flatMap(weak: self) { owner, transactions -> Observable<[DomainLayer.DTO.AnyTransaction]> in

                let newTransaction = owner.setupTransactions(transactions)

                return owner
                    .transactionsRepositoryLocal
                    .saveTransactions(newTransaction)
                    .flatMap(weak: owner, selector: { owner, transaction -> Observable<[DomainLayer.DTO.AnyTransaction]> in
                        return owner
                            .transactionsRepositoryLocal
                            .transactions(by: accountAddress, specifications: specifications)
                })
            }
    }

    func setupTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> [DomainLayer.DTO.AnyTransaction] {

        var newTransactions: [DomainLayer.DTO.AnyTransaction] = .init()

        for tx in transactions {
            switch tx {

            case .transfer(let tx):
                let newTx = tx.mutate { $0.assetId = $0.assetId.normalizeAssetId }
                newTransactions.append(.transfer(newTx))
            case .massTransfer(let tx):
                let newTx = tx.mutate { $0.assetId = $0.assetId.normalizeAssetId }
                newTransactions.append(.massTransfer(newTx))
            case .exchange(let tx):

                let newTx = tx.mutate {
                    $0.order1 = $0.order1.mutate {
                        $0.assetPair.amountAsset = $0.assetPair.amountAsset.normalizeAssetId
                        $0.assetPair.priceAsset = $0.assetPair.priceAsset.normalizeAssetId
                    }
                    $0.order2 = $0.order2.mutate {
                        $0.assetPair.amountAsset = $0.assetPair.amountAsset.normalizeAssetId
                        $0.assetPair.priceAsset = $0.assetPair.priceAsset.normalizeAssetId
                    }

                }
                newTransactions.append(.exchange(newTx))
            default:
                newTransactions.append(tx)
            }
        }

        return newTransactions
    }
}

extension Optional where Wrapped == String {

    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return Environments.Constants.wavesAssetId
        }
    }
}

