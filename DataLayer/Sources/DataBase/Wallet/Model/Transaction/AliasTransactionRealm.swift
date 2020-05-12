//
//  AliasTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

final class AliasTransactionRealm: TransactionRealm {    
    @objc dynamic var alias: String = ""
}
