//
//  LeasingTransactionProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum LeasingTransactionRepositoryError: Error {
    case fail
}

protocol LeasingTransactionRepositoryProtocol {
    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]>

    func saveLeasingTransactions(_ transactions:[DomainLayer.DTO.LeaseTransaction], by accountAddress: String) -> Observable<Bool>
    func saveLeasingTransaction(_ transaction: DomainLayer.DTO.LeaseTransaction, by accountAddress: String) -> Observable<Bool>
}
