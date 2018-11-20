//
//  SmartTransactionDomain+Assistants.swift
//  WavesWallet-iOS
//
//  Created by Mac on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO.SmartTransaction.Exchange {
    var myOrder: Order {
        if order1.sender.isMyAccount && order2.sender.isMyAccount {
            return order1.timestamp > order2.timestamp ? order1 : order2
        } else if order1.sender.isMyAccount {
            return order1
        } else if order2.sender.isMyAccount {
            return order2
        } else {
            return order1.timestamp > order2.timestamp ? order1 : order2
        }
    }
}
