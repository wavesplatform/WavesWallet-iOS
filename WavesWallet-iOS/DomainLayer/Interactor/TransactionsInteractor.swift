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
    static let durationInseconds: Double = 15
}

protocol TransactionsInteractorProtocol {
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]>
}

final class TransactionsInteractor: TransactionsInteractorProtocol {

    private var transactionsRepositoryLocal: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryLocal
    private var transactionsRepositoryRemote: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryRemote
    private var assetsInteractors: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor

    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {

        return transactionsRepositoryLocal
            .isHasTransactions
            .flatMap(weak: self) { owner, isHasTransactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                if isHasTransactions {
                    return owner.nextPage(accountAddress, specifications: specifications, currentOffset: 0, currentLimit: 50)
                } else {
                    return owner.firstLoading(accountAddress, specifications: specifications)
                }
            }
    }

    private func firstLoading(_ accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {

        return transactionsRepositoryRemote
            .transactions(by: accountAddress, offset: 0, limit: 10000)
            .flatMap(weak: self, selector: { owner, transactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                return owner
                    .saveTransactions(transactions)
                    .flatMap(weak: self, selector: { owner, isOk -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                        return owner.localTransactions(accountAddress, specifications: specifications)
                    })
        })
    }

    private func nextPage(_ accountAddress: String, specifications: TransactionsSpecifications, currentOffset: Int, currentLimit: Int) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {
        return transactionsRepositoryRemote
            .transactions(by: accountAddress,
                          offset: currentOffset,
                          limit: currentLimit)
            .flatMap(weak: self) { owner, transactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in

                let idx = transactions
                    .sorted(by: { $0.timestamp > $1.timestamp })
                    .reduce([String]()) { list, tx -> [String] in
                        var newList = list
                        newList.append(tx.id)
                        return newList
                    }

                return owner
                    .transactionsRepositoryLocal
                    .isHasTransactions(by: idx)
                    .flatMap(weak: owner) { _, isHasTransactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                        if isHasTransactions {
                            return owner.localTransactions(accountAddress, specifications: specifications)
                        } else {
                            return owner.saveTransactions(transactions)
                                .flatMap(weak: owner) { _, _ -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                                    owner.nextPage(accountAddress, specifications: specifications, currentOffset: currentOffset + currentLimit, currentLimit: currentLimit)
                                }
                        }
                    }
            }
    }

    private func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> AsyncObservable<Bool> {

        let newTxs = normalizeTransactions(transactions)

        return transactionsRepositoryLocal
            .saveTransactions(newTxs)
    }

    private func localTransactions(_ accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {

        return transactionsRepositoryLocal
            .transactions(by: accountAddress, specifications: specifications)
            .do(onNext: { txs in

                let assetsId = txs.reduce(into: Set<String>(), { set, tx in
                    tx.assetsIds.forEach { set.insert($0) }
                })

                let newTransactions = txs.map({ tx -> DomainLayer.DTO.Transaction?  in
                    return tx.transaction(by: accountAddress, assets: [:], accounts: [:])
                })

                print(newTransactions)
            })
    }

//    private func convertToUniversalTransaction

    private func normalizeTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> [DomainLayer.DTO.AnyTransaction] {

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

fileprivate extension DomainLayer.DTO.AnyTransaction {

    var assetsIds:[String] {

        switch self {
        case .unrecognised:
            return [Environments.Constants.wavesAssetId]

        case .issue(let tx):
            return [tx.assetId]

        case .transfer(let tx):
            guard let assetId = tx.assetId else { return [] }
            return [assetId]

        case .reissue(let tx):
            return [tx.assetId]

        case .burn(let tx):
            return [tx.assetId]

        case .exchange(let tx):
            guard let amountAssetId = tx.order1.assetPair.amountAsset else { return [] }
            guard let priceAssetId = tx.order1.assetPair.priceAsset else { return [] }
            return [amountAssetId, priceAssetId]

        case .lease:
            return [Environments.Constants.wavesAssetId]

        case .leaseCancel:
            return [Environments.Constants.wavesAssetId]

        case .alias:
            return [Environments.Constants.wavesAssetId]

        case .massTransfer(let tx):
            guard let assetId = tx.assetId else { return [] }
            return [assetId]

        case .data:
            return [Environments.Constants.wavesAssetId]
        }
    }
}
