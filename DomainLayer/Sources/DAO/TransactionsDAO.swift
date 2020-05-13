//
//  TransactionsDAO.swift
//  DataLayer
//
//  Created by rprokofev on 12.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

public protocol TransactionsDAO {

    func transactions(serverEnvironment: ServerEnvironment,
                      address: Address,
                      offset: Int,
                      limit: Int) -> Observable<[AnyTransaction]>
    
    func transactions(by address: Address,
                      specifications: TransactionsSpecifications) -> Observable<[AnyTransaction]>
    
    func newTransactions(by address: Address,
                         specifications: TransactionsSpecifications) -> Observable<[AnyTransaction]>

    func activeLeasingTransactions(serverEnvironment: ServerEnvironment,
                                   accountAddress: String) -> Observable<[LeaseTransaction]>
    
    func saveTransactions(_ transactions: [AnyTransaction], accountAddress: String) -> Observable<Bool>

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>

    func send(serverEnvironment: ServerEnvironment,
              specifications: TransactionSenderSpecifications,
              wallet: DomainLayer.DTO.SignedWallet) -> Observable<AnyTransaction>
}
