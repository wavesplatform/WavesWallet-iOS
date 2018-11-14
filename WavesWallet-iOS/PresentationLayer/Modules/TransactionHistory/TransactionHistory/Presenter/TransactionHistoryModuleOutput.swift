//
//  TransactionHistoryModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Mac on 28/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol TransactionHistoryModuleOutput: class {
    
    func transactionHistoryAddAddressToHistoryBook(address: String)
    func transactionHistoryEditAddressToHistoryBook(address: String)
}
