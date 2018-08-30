//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    enum AnyTransaction {
        case unrecognised
        case issue(DomainLayer.DTO.IssueTransaction)
        case transfer(DomainLayer.DTO.TransferTransaction)
        case reissue(DomainLayer.DTO.ReissueTransaction)
        case burn(DomainLayer.DTO.BurnTransaction)
        case exchange(DomainLayer.DTO.ExchangeTransaction)
        case lease(DomainLayer.DTO.LeaseTransaction)
        case leaseCancel(DomainLayer.DTO.LeaseCancelTransaction)
        case alias(DomainLayer.DTO.AliasTransaction)
        case massTransfer(DomainLayer.DTO.MassTransferTransaction)
        case data(DomainLayer.DTO.DataTransaction)
    }
}
