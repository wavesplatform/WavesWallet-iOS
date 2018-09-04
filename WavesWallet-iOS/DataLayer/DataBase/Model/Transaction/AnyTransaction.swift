//
//  AnyTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 03.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class AnyTransaction: Transaction {

    var unrecognisedTransaction: UnrecognisedTransaction?
    var issueTransaction: IssueTransaction?
    var transferTransaction: TransferTransaction?
    var reissueTransaction: ReissueTransaction?
    var leaseTransaction: LeaseTransaction?
    var leaseCancelTransaction: LeaseCancelTransaction?
    var aliasTransaction: AliasTransaction?
    var massTransferTransaction: MassTransferTransaction?
    var burnTransaction: BurnTransaction?
    var exchangeTransaction: ExchangeTransaction?
    var dataTransaction: DataTransaction?
}
