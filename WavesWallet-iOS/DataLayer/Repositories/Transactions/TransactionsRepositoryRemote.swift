//
//  TransactionsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

//
//fileprivate enum TRANSACTION_TYPE_VERSION: Int {
//    case ISSUE = 2,
//    case TRANSFER = 2,
//    case REISSUE = 2,
//    case BURN = 2,
//    case EXCHANGE = 2,
//    case LEASE = 2,
//    case CANCEL_LEASING = 2,
//    case CREATE_ALIAS = 2,
//    case MASS_TRANSFER = 1,
//    case DATA = 1,
//    case SET_SCRIPT = 1,
//    case SPONSORSHIP = 1
//}

extension TransactionSenderSpecifications {

    var version: Int {
        switch self {
        case .createAlias:
            return 2
        }
    }

    var type: Int {
        switch self {
        case .createAlias:
            return 10
        }
    }
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    private let transactions: MoyaProvider<Node.Service.Transaction> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }

                let limit = min(Constants.maxLimit, offset + limit)

                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .list(accountAddress: accountAddress,
                                               limit: limit),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.TransactionContainers.self)
            .map { $0.anyTransactions() }
            .asObservable()        
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .leasingProvider
                    .rx
                    .request(.init(kind: .getActive(accountAddress: accountAddress),
                                   environment: environment),
                                   callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map([Node.DTO.LeaseTransaction].self)
            .map { $0.map { DomainLayer.DTO.LeaseTransaction(transaction: $0) } }
            .asObservable()
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        switch specifications {
        case .createAlias(let model):

//            let assetIdBytes = assetId.isEmpty ? [UInt8(0)] :  ([UInt8(1)] + Base58.decode(assetId))
//            let feeAssetIdBytes = [UInt8(0)]
//            let s1 = [transactionType] + senderPublicKey.publicKey
//            let s2 = assetIdBytes + feeAssetIdBytes + toByteArray(timestamp) + toByteArray(amount.amount) + toByteArray(fee.amount)
//            let s3 = Base58.decode(recipient) + attachment.arrayWithSize()
//            return s1 + s2 + s3

            let timestamp = Int64(Date().millisecondsSince1970)

            var signature: [UInt8] = [UInt8(specifications.type)]
            signature += [UInt8(specifications.version)]
            signature += wallet.publicKey.publicKey
            signature += model.alias.arrayWithSize()
            signature += toByteArray([UInt8(100000)])
            signature += toByteArray(timestamp)

            let parameter: [String: Any]  = ["version": specifications.version,
                                             "alias": model.alias,
                                             "fee": 100000,
                                             "timestamp": timestamp,
                                             "type": specifications.type,
                                             "senderPublicKey": wallet.seed.publicKey,
                                             "proofs": Base58.encode(signature)]



            return environmentRepository
                .accountEnvironment(accountAddress: wallet.wallet.address)
                .flatMap { [weak self] environment -> Single<Response> in

                    guard let owner = self else { return Single.never() }
                    return owner
                        .transactions
                        .rx
                        .request(.init(kind: .brodcast(parameter),
                                       environment: environment),
                                 callbackQueue: DispatchQueue.global(qos: .background))
                }
                .asObservable()
                .map { _ in [DomainLayer.DTO.AnyTransaction].init() }

            break


        default:
            break
        }

        return Observable.never()
    }

    func transactions(by accountAddress: String,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String, accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
