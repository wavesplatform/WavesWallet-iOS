//
//  AnyTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 03.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

final class AnyTransactionRealm: TransactionRealm {

    @objc dynamic var unrecognisedTransaction: UnrecognisedTransactionRealm?
    @objc dynamic var issueTransaction: IssueTransactionRealm?
    @objc dynamic var transferTransaction: TransferTransactionRealm?
    @objc dynamic var reissueTransaction: ReissueTransactionRealm?
    @objc dynamic var leaseTransaction: LeaseTransactionRealm?
    @objc dynamic var leaseCancelTransaction: LeaseCancelTransactionRealm?
    @objc dynamic var aliasTransaction: AliasTransactionRealm?
    @objc dynamic var massTransferTransaction: MassTransferTransactionRealm?
    @objc dynamic var burnTransaction: BurnTransactionRealm?
    @objc dynamic var exchangeTransaction: ExchangeTransactionRealm?
    @objc dynamic var dataTransaction: DataTransactionRealm?
    @objc dynamic var scriptTransaction: ScriptTransactionRealm?
    @objc dynamic var assetScriptTransaction: AssetScriptTransactionRealm?
    @objc dynamic var sponsorshipTransaction: SponsorshipTransactionRealm?
    @objc dynamic var invokeScriptTransaction: InvokeScriptTransactionRealm?
}
