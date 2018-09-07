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


fileprivate extension DomainLayer.DTO.Asset {

    func balance(_ amount: Int64) -> Balance {
        return balance(amount, precision: precision)
    }

    func balance(_ amount: Int64, precision: Int) -> Balance {
        return Balance(currency: .init(title: name, ticker: ticker), money: .init(amount, precision))
    }
}

fileprivate extension DomainLayer.DTO.AssetPair {

    var precisionDifference: Int {
        return (priceAsset.precision - amountAsset.precision) + 8
    }

    func priceBalance(_ amount: Int64) -> Balance {
        return priceAsset.balance(amount, precision: precisionDifference)
    }

    func amountBalance(_ amount: Int64) -> Balance {
        return amountAsset.balance(amount)
    }

    func totalBalance(priceAmount: Int64, assetAmount: Int64) -> Balance {
        return priceAsset.balance(priceAmount + assetAmount, precision: precisionDifference + priceAsset.precision)
    }
}



extension DomainLayer.DTO.ExchangeTransaction.Order {

    func exchangeOrder(assetPair: DomainLayer.DTO.AssetPair,
                       accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction.Exchange.Order? {

        guard let sender = accounts[self.sender] else { return nil }
        let kind: DomainLayer.DTO.Transaction.Exchange.Order.Kind = orderType == .sell ? .sell : .buy
        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        let total = assetPair.totalBalance(priceAmount: self.amount,
                                           assetAmount: self.price)

        return .init(timestamp: Date(milliseconds: timestamp),
                     expiration: Date(milliseconds: expiration),
                     sender: sender,
                     kind: kind,
                     pair: assetPair,
                     price: price,
                     amount: amount,
                     total: total)
    }
}

fileprivate extension DomainLayer.DTO.AnyTransaction {

    func transactionKind(by accountAddress: String, assets: [String: DomainLayer.DTO.Asset], accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction.Kind? {

        switch self {

        case .unrecognised:
            return .unrecognisedTransaction

        case .issue(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            let balance = asset.balance(tx.quantity)
            return .tokenGeneration(.init(asset: asset, balance: balance))

        case .transfer(let tx):
            guard let assetId = tx.assetId else { return nil }
            guard let asset = assets[assetId] else { return nil }
            guard let recipient = accounts[tx.recipient] else { return nil }

            let isSenderAccount = tx.sender.isMyAccount(accountAddress)
            let isRecipientAccount = tx.sender.isMyAccount(tx.recipient)

            let balance = asset.balance(tx.amount)
            let transfer: DomainLayer.DTO.Transaction.Transfer = .init(balance: balance,
                                                                       asset: asset,
                                                                       recipient: recipient)

            if isSenderAccount && isRecipientAccount {
                return .selfTransfer(transfer)
            } else if isSenderAccount {
                return .sent(transfer)
            } else if isRecipientAccount {
                if asset.isSpam {
                    return .spamReceive(transfer)
                } else {
                    return .receive(transfer)
                }
            }

        case .reissue(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            let balance = asset.balance(tx.quantity)
            return .tokenReissue(.init(asset: asset, balance: balance))

        case .burn(let tx):
            guard let asset = assets[tx.assetId] else { return nil }
            let balance = asset.balance(tx.amount)
            return .tokenBurn(.init(asset: asset, balance: balance))

        case .exchange(let exchange):

            guard let amountAssetId = exchange.order1.assetPair.amountAsset else { return nil }
            guard let priceAssetId = exchange.order1.assetPair.priceAsset else { return nil }
            guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
            guard let amountAsset = assets[amountAssetId] else { return nil }
            guard let priceAsset = assets[priceAssetId] else { return nil }
            let assetPair = DomainLayer.DTO.AssetPair(amountAsset: amountAsset,
                                                 priceAsset: priceAsset)

            let amount = assetPair.amountBalance(exchange.amount)
            let price = assetPair.priceBalance(exchange.price)
            let total = assetPair.totalBalance(priceAmount: exchange.amount,
                                               assetAmount: exchange.price)

            let buyMatcherFee = wavesAsset.balance(exchange.buyMatcherFee)
            let sellMatcherFee = wavesAsset.balance(exchange.sellMatcherFee)

            guard let order1 = exchange.order1.exchangeOrder(assetPair: assetPair,
                                                            accounts: accounts) else { return nil }
            guard let order2 = exchange.order2.exchangeOrder(assetPair: assetPair,
                                                             accounts: accounts) else { return nil }


            return .exchange(.init(price: price,
                                   amount: amount,
                                   total: total,
                                   buyMatcherFee: buyMatcherFee,
                                   sellMatcherFee: sellMatcherFee,
                                   order1: order1,
                                   order2: order2))

        case .lease(let tx):

            guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
            let balance = wavesAsset.balance(tx.amount)
            let isSenderAccount = tx.sender.isMyAccount(accountAddress)

            if isSenderAccount {
                guard let recipient = accounts[tx.recipient] else { return nil }
                return .startedLeasing(.init(asset: wavesAsset,
                                             balance: balance,
                                             account: recipient))
            } else {
                guard let sender = accounts[tx.sender] else { return nil }
                return .incomingLeasing(.init(asset: wavesAsset,
                                             balance: balance,
                                             account: sender))
            }

        case .leaseCancel(let tx):
            guard let lease = tx.lease else { return nil }
            guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
            guard let recipient = accounts[lease.recipient] else { return nil }
            let balance = wavesAsset.balance(lease.amount)

            return .canceledLeasing(.init(asset: wavesAsset,
                                        balance: balance,
                                        account: recipient))

        case .alias(let tx):
            return .createdAlias(tx.alias)

        case .massTransfer(let tx):

            
//
//        case .data(_):

        default:
            break
        }
        return nil
    }

//    var transaction: DomainLayer.DTO.Transaction? = {
//
////        switch self {
////
////        case .unrecognised(_):
////
////
//////            DomainLayer.DTO.Transaction.init(id: <#T##String#>, kind: <#T##DomainLayer.DTO.Transaction.Kind#>, date: <#T##Date#>)
////
////        case .issue(_):
////
////        case .transfer(_):
////
////        case .reissue(_):
////
////        case .burn(_):
////
////        case .exchange(_):
////
////        case .lease(_):
////
////        case .leaseCancel(_):
////
////        case .alias(_):
////
////        case .massTransfer(_):
////
////        case .data(_):
////
////        }
//
//        return nil
//    }
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

