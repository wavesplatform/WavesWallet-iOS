//
//  LeasingTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension LeasingTransaction {
    convenience init(model: Node.DTO.LeasingTransaction) {
        self.init()
        type = model.type
        id = model.id
        sender = model.sender
        senderPublicKey = model.senderPublicKey
        fee = model.fee
        timestamp = model.timestamp
        signature = model.signature
        version = model.version
        amount = model.amount
        recipient = model.recipient
        height = model.height
    }
}
