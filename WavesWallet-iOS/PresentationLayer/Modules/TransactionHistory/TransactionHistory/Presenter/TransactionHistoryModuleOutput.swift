//
//  TransactionHistoryModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Mac on 28/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol TransactionHistoryModuleOutput: AnyObject {

    typealias FinishedAddressBook = ((TransactionHistoryTypes.DTO.ContactState, Bool) -> Void)

    func transactionHistoryAddAddressToHistoryBook(address: String, finished: @escaping FinishedAddressBook)
    func transactionHistoryEditAddressToHistoryBook(contact: DomainLayer.DTO.Contact, finished: @escaping FinishedAddressBook)

    func transactionHistoryResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction)
    func transactionHistoryCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction)

    func transactionHistoryDidDismiss()
}
