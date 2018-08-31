//
//  Transactions.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum TransactionsRepositoryError: Error {
    case fail
}

protocol TransactionsRepositoryProtocol {

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func transactions(by accountAddress: String, assetId: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]>

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> Observable<Bool>
}
