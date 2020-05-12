//
//  UnrecognisedTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

final class UnrecognisedTransactionRealm: TransactionRealm {
    @objc dynamic var assetId: String = ""
}
