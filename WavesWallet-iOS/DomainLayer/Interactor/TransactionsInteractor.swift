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
    private var assetsInteractors: AssetsInteractor = FactoryInteractors.assetsInteractor

    func transactions(by accountAddress: String,  specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {

        return transactionsRepositoryLocal
            .isHasTransactions
            .flatMap(weak: self)  { owner, isHasTransactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                if isHasTransactions {
                    return owner.nextPage(accountAddress, specifications: specifications, currentOffset: 0, currentLimit: 50)
                } else {
                    return owner
                        .transactionsRepositoryRemote
                        .transactions(by: accountAddress, offset: 0, limit: 10000)
                }
        }
    }

    private func nextPage(_ accountAddress: String, specifications: TransactionsSpecifications, currentOffset: Int, currentLimit: Int) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {
        return transactionsRepositoryRemote
            .transactions(by: accountAddress,
                                                  offset: currentOffset,
                                                  limit: currentLimit)
            .flatMap(weak: self, selector: { owner, transactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in

                let idx = transactions
                    .sorted(by: { $0.timestamp > $1.timestamp })
                    .reduce([String](), { list, tx -> [String] in
                        var newList = list
                        newList.append(tx.id)
                        return newList
                })

                return owner
                    .transactionsRepositoryLocal
                    .isHasTransactions(by: idx)
                    .flatMap(weak: owner, selector: { onwer, isHasTransactions -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                        if isHasTransactions {
                            return owner.localTransactions(accountAddress, specifications: specifications)
                        } else {
                            return owner.saveTransactions(transactions)
                                .flatMap(weak: owner, selector: { onwer, _ -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> in
                                return owner.nextPage(accountAddress, specifications: specifications, currentOffset: currentOffset + currentLimit, currentLimit: currentLimit)
                            })
                        }
                })
            })
    }

    private func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) ->AsyncObservable<Bool> {

        let newTxs = normalizeTransactions(transactions)

        return transactionsRepositoryLocal
            .saveTransactions(newTxs)
    }

    private func localTransactions(_ accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {
        return transactionsRepositoryLocal.transactions(by: accountAddress, specifications: specifications)
    }

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

    func transactionKind(by accountAddress: String, assets: [String: DomainLayer.DTO.Asset], recipients: [String: DomainLayer.DTO.Recipient]) -> DomainLayer.DTO.Transaction.Kind? {

        switch self {

        case .unrecognised:
            return DomainLayer.DTO.Transaction.Kind.unrecognisedTransaction

        case .issue(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            return DomainLayer.DTO.Transaction.Kind.tokenGeneration(.init(asset: asset))

        case .transfer(let tx):
            guard let assetId = tx.assetId else { return nil }
            guard let asset = assets[assetId] else { return nil }
            guard let recipient = recipients[tx.recipient] else { return nil }

            let isSenderAccount = tx.sender.isMyAccount(accountAddress)
            let isRecipientAccount = tx.sender.isMyAccount(tx.recipient)

            let balance = Balance(currency: .init(title: asset.name,
                                                  ticker: asset.ticker),
                                  money: .init(tx.amount, asset.quantity))
            let transfer: DomainLayer.DTO.Transaction.Transfer = .init(asset: asset, recipient: recipient)

            if isSenderAccount && isRecipientAccount {
                return DomainLayer.DTO.Transaction.Kind.selfTransfer(transfer)
            } else if isSenderAccount {
                return DomainLayer.DTO.Transaction.Kind.sent(transfer)
            } else if isRecipientAccount {
                return DomainLayer.DTO.Transaction.Kind.receive(transfer)
            }

        case .reissue(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            let balance = Balance(currency: .init(title: asset.name,
                                                  ticker: asset.ticker),
                                  money: .init(tx.quantity, asset.quantity))
            return DomainLayer.DTO.Transaction.Kind.tokenReissue(.init(asset: asset, balance: balance))

        case .burn(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            let balance = Balance(currency: .init(title: asset.name,
                                                  ticker: asset.ticker),
                                  money: .init(tx.quantity, asset.quantity))
            return DomainLayer.DTO.Transaction.Kind.tokenBurn(.init(asset: asset, balance: balance))

        case .exchange(let exchange):
            break
//        case .lease(_):
//
//        case .leaseCancel(_):
//
//        case .alias(_):
//
//        case .massTransfer(_):
//
//        case .data(_):

        default:
            break
        }
        return nil
    }

    var transaction: DomainLayer.DTO.Transaction? = {

//        switch self {
//
//        case .unrecognised(_):
//
//
////            DomainLayer.DTO.Transaction.init(id: <#T##String#>, kind: <#T##DomainLayer.DTO.Transaction.Kind#>, date: <#T##Date#>)
//
//        case .issue(_):
//
//        case .transfer(_):
//
//        case .reissue(_):
//
//        case .burn(_):
//
//        case .exchange(_):
//
//        case .lease(_):
//
//        case .leaseCancel(_):
//
//        case .alias(_):
//
//        case .massTransfer(_):
//
//        case .data(_):
//
//        }

        return nil
    }
}


fileprivate extension Optional where Wrapped == String {

    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return Environments.Constants.wavesAssetId
        }
    }
}

fileprivate extension String {

    func isMyAccount(_ account: String) -> Bool {
        return self == account
    }
}

