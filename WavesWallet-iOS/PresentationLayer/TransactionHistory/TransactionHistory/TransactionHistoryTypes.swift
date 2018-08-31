//
//  TransactionHistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 22/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

enum TransactionHistoryTypes {
    enum DTO {}
    enum ViewModel {}
    
    struct State: Mutating {
        
        var currentIndex: Int
        var displays: [DisplayState]
        var transactions: [DTO.Transaction]
        
        struct DisplayState: Mutating {
            var sections: [ViewModel.Section]
        }
        
    }
    
    enum Event {
        case readyView
    }
}

extension TransactionHistoryTypes {
    
    
    
}

