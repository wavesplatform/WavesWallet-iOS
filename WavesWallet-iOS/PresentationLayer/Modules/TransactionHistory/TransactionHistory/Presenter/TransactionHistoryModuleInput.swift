//
//  TransactionHistoryModuleInput.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol TransactionHistoryModuleInput {
    
    var transactions: [DomainLayer.DTO.SmartTransaction] { get }
    var currentIndex: Int { get }
    
}
