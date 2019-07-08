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

    @objc dynamic var unrecognisedTransaction: UnrecognisedTransaction?
    @objc dynamic var issueTransaction: IssueTransaction?
    @objc dynamic var transferTransaction: TransferTransaction?
    @objc dynamic var reissueTransaction: ReissueTransaction?
    @objc dynamic var leaseTransaction: LeaseTransaction?
    @objc dynamic var leaseCancelTransaction: LeaseCancelTransaction?
    @objc dynamic var aliasTransaction: AliasTransaction?
    @objc dynamic var massTransferTransaction: MassTransferTransaction?
    @objc dynamic var burnTransaction: BurnTransaction?
    @objc dynamic var exchangeTransaction: ExchangeTransaction?
    @objc dynamic var dataTransaction: DataTransaction?
    @objc dynamic var scriptTransaction: ScriptTransaction?
    @objc dynamic var assetScriptTransaction: AssetScriptTransaction?
    @objc dynamic var sponsorshipTransaction: SponsorshipTransaction?
    @objc dynamic var invokeScriptTransaction: InvokeScriptTransaction?
}
