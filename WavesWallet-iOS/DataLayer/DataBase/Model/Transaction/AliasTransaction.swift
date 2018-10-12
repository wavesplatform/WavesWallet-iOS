//
//  AliasTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class AliasTransaction: Transaction {
    @objc dynamic var signature: String? = nil
    @objc dynamic var alias: String = ""
}

